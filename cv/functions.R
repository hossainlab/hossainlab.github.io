library(pander)
library(stringr)
library(dplyr)
library(googlesheets4)
library(lubridate)
library(kableExtra)

gs4_deauth()

gscholar_stats <- function(url) {
  cites <- get_cites(url)
  return(paste(
    'Citations:', cites$citations, '•',
    'h-index:',   cites$hindex, '•',
    'i10-index:', cites$i10index
  ))
}

get_cites <- function(url) {
  html <- xml2::read_html(url)
  node <- rvest::html_nodes(html, xpath='//*[@id="gsc_rsb_st"]')
  cites_df <- rvest::html_table(node)[[1]]
  cites <- data.frame(t(as.data.frame(cites_df)[,2]))
  names(cites) <- c('citations', 'hindex', 'i10index')
  return(cites)
}

get_cv_sheet <- function(sheet) {
    return(read_sheet(
        ss = 'https://docs.google.com/spreadsheets/d/1uIJiRbVvBDzrB4QnrpHUmUOzB8rAjop5omtZBxVVE4Y/edit?usp=sharing',
        sheet = sheet
    ))
}

make_ordered_list <- function(x) {
    return(pandoc.list(x, style = 'ordered'))
}

make_bullet_list <- function(x) {
  return(pandoc.list(x, style = 'bullet'))
}

make_ordered_list_filtered <- function(df, cat) {
  return(df %>%
    filter(category == {{cat}}) %>%
    mutate(
      citation = str_replace_all(
        citation,
        "\\\\\\*(\\w+),",
        "\\\\*\\\\underline{\\1},"
      )
    ) %>%
    pull(citation) %>%
    make_ordered_list()
  )
}

na_to_space <- function(x) {
  return(ifelse(is.na(x), '', x))
}

enquote <- function(x) {
  return(paste0('"', x, '"'))
}

library(tidyr)
markdown_url <- function(url) {
  return(paste0('[', url, '](', url,')'))
}

# Entry header shared by all sections:
#   **Role**                                           Date
#   Institution                                        Location
cv_entry_head <- function(role, inst, date, where) {
    na_blank <- function(x) if (is.na(x)) "" else x
    role_text <- if (!is.na(role)) paste0("\\textbf{", role, "}") else ""
    paste0(
        "\\cvline{", role_text, "}{", na_blank(date), "}\n",
        "\\cvline{", na_blank(inst), "}{", na_blank(where), "}\n"
    )
}

make_cv_entries <- function(df, date_col, role_col, inst_col, where_col, details_col) {
    # Convert to character and escape special LaTeX characters
    df <- df %>%
        mutate(across(everything(), as.character)) %>%
        mutate(across(everything(), ~str_replace_all(., "&", "\\\\&"))) %>%
        mutate(across(everything(), ~str_replace_all(., "_", "\\\\_"))) %>%
        mutate(across(everything(), ~str_replace_all(., "%", "\\\\%"))) %>%
        mutate(across(everything(), ~str_replace_all(., "#", "\\\\#")))

    # Convert empty strings and "NULL" (list-column artifact) to NA so fill() works
    df <- df %>%
        mutate(across(everything(), ~na_if(., ""))) %>%
        mutate(across(everything(), ~na_if(., "NULL"))) %>%
        mutate(.row_id = row_number())

    # Fill in missing values for grouping
    df_filled <- df %>%
        fill({{date_col}}, {{role_col}}, {{inst_col}}, {{where_col}})

    # Identify grouping columns
    group_cols <- c(
        as_label(enquo(date_col)),
        as_label(enquo(role_col)),
        as_label(enquo(inst_col)),
        as_label(enquo(where_col))
    )

    # Group and nest details, preserving original sheet order
    df_nested <- df_filled %>%
        group_by(across(all_of(group_cols))) %>%
        summarize(bullets = list({{details_col}}), .row_id = min(.row_id), .groups = "drop") %>%
        arrange(.row_id)

    # Generate LaTeX code
    entries <- df_nested %>%
        rowwise() %>%
        mutate(latex = {
            # Format bullets
            bullet_list <- bullets
            bullet_list <- bullet_list[!is.na(bullet_list)]
            is_note <- grepl("^(Advisor|Supervisor|Collaborator)s?:", bullet_list)
            note_latex <- if (any(is_note)) paste0("\\noindent ", bullet_list[is_note], "\\par\n", collapse = "") else ""
            bullet_list <- sub("^([A-Z][^:]{1,30}:)", "\\\\textbf{\\1}", bullet_list[!is_note])

            if (length(bullet_list) > 0) {
                bullet_latex <- paste0(
                    "\\begin{itemize}\n",
                    paste0("  \\item ", bullet_list, collapse = "\n"),
                    "\n\\end{itemize}"
                )
            } else {
                bullet_latex <- ""
            }

            paste0(
                "\\begingroup\\setlength{\\parskip}{0pt}\n",
                cv_entry_head({{role_col}}, {{inst_col}}, {{date_col}}, {{where_col}}),
                note_latex,
                if (bullet_latex != "") paste0(bullet_latex, "\n") else "",
                "\\endgroup\\vspace{5pt}\n"
            )
        }) %>%
        pull(latex)

    cat(entries, sep = "\n")
}

# Format one sheet date cell: Date/POSIXct -> "Jun 2020", bare year -> "2026",
# "Present"/text passes through, NA/NULL -> NA
fmt_cv_date <- function(x) {
    if (is.null(x) || length(x) == 0 || all(is.na(x))) return(NA_character_)
    if (inherits(x, c("Date", "POSIXt"))) return(format(as.Date(x), "%b %Y"))
    if (is.numeric(x)) {
        if (x < 3000) return(as.character(x))
        return(format(as.Date(as.POSIXct(x, origin = "1970-01-01", tz = "UTC")), "%b %Y"))
    }
    x <- as.character(x)
    if (grepl("^\\d{4}$", x)) return(x)
    d <- suppressWarnings(as.Date(x, optional = TRUE))
    if (!is.na(d)) return(format(d, "%b %Y"))
    x
}

escape_latex <- function(x) {
    x %>%
        str_replace_all("&", "\\\\&") %>%
        str_replace_all("_", "\\\\_") %>%
        str_replace_all("%", "\\\\%") %>%
        str_replace_all("#", "\\\\#") %>%
        str_replace_all("\u2019", "'")  # xeCJK spaces curly apostrophes oddly
}

# Research entries:
#   **Role**                                           Start – End
#   Institution                                        Where
#   Collaborator/Advisor line
#   **Project N:** title (paragraph)
#   bullets
# Each entry starts on a row with a role; following rows (role empty) add details.
make_research_entries <- function(df) {
    df <- df %>%
        mutate(
            start = sapply(start_date, fmt_cv_date),
            end   = sapply(end_date, fmt_cv_date),
            across(c(role, institution, where, details), ~escape_latex(as.character(.))),
            entry = cumsum(!is.na(role))
        )

    entries <- lapply(split(df, df$entry), function(e) {
        head <- e[1, ]
        date <- paste(na.omit(c(head$start, head$end)), collapse = " -- ")
        out <- paste0(
            "\\begingroup\\setlength{\\parskip}{0pt}\n",
            cv_entry_head(head$role, head$institution, date, head$where)
        )

        details <- e$details[!is.na(e$details) & e$details != ""]
        is_bullet <- !grepl("^(Project( \\d+)?|Collaborators?|Advisors?|Supervisors?|PI):", details)
        run <- character(0)
        flush <- function() {
            if (length(run) == 0) return("")
            s <- paste0(
                "\\begin{itemize}\n",
                paste0("  \\item ", run, collapse = "\n"),
                "\n\\end{itemize}\n"
            )
            run <<- character(0)
            s
        }
        for (i in seq_along(details)) {
            d <- details[i]
            if (is_bullet[i]) {
                run <- c(run, d)
                next
            }
            out <- paste0(out, flush())
            if (grepl("^Project", d)) {
                d <- sub("^(Project( \\d+)?:)\\s*", "\\\\textbf{\\1} ", d)
                out <- paste0(out, "\\vspace{3pt}\\noindent ", d, "\\par\n")
            } else {
                out <- paste0(out, "\\noindent ", d, "\\par\n")
            }
        }
        paste0(out, flush(), "\\endgroup\\vspace{5pt}\n")
    })

    cat(unlist(entries), sep = "\n")
}

# Courses: one line each, newest first
#   **Title**, Host [Materials]                        Oct 2023
invited_hosts <- c(
    "Research Help Bangladesh",
    "Dept. of Pharmacy and CSE, Northern University Bangladesh",
    "Genetic Engineering Club, JnU",
    "Public Health Forum, Jahangirnagar University"
)

make_course_entries <- function(df) {
    df <- df %>%
        mutate(
            date    = as.Date(date),
            invited = host %in% invited_hosts,
            title   = ifelse(invited, paste0(title, ", \\textit{", escape_latex(host), "}"), title),
            host    = ifelse(invited, "Invited Lectures & Workshops", host)
        ) %>%
        group_by(host) %>%
        mutate(latest = max(date)) %>%
        ungroup() %>%
        arrange(desc(latest), host, desc(date)) %>%
        mutate(
            title = ifelse(invited, title, escape_latex(title)),
            link  = ifelse(
                is.na(url), "",
                paste0("\\enspace\\href{", str_replace_all(url, "([%#])", "\\\\\\1"),
                       "}{{\\color{cvlink}\\scriptsize\\faExternalLink*}}")
            ),
            line  = paste0("{\\leftskip=1.2em\\cvline{", title, link, "}{",
                           format(date, "%Y"), "}}")
        )
    groups <- split(df, factor(df$host, levels = unique(df$host)))
    entries <- vapply(names(groups), function(h) {
        paste0("\\noindent\\textbf{", escape_latex(h), "}\\par\n",
               paste(groups[[h]]$line, collapse = "\n"), "\n\\vspace{5pt}\n")
    }, character(1))
    cat("```{=latex}\n\\begingroup\\setlength{\\parskip}{1pt}\n",
        entries,
        "\\endgroup\n```\n", sep = "")
}

# Awards (sheet order):
#   **Award name**, *Organization*                     2026
#   Description (optional `description` column)
make_award_entries <- function(df) {
    if (!"description" %in% names(df)) df$description <- NA_character_
    df <- df %>%
        filter(!is.na(award_name)) %>%
        mutate(
            date  = ifelse(is.na(date), "", as.character(date)),
            title = paste0(
                "\\textbf{", escape_latex(award_name), "}",
                ifelse(is.na(organization), "", paste0(", \\textit{", escape_latex(organization), "}"))
            ),
            desc  = ifelse(is.na(description), "", paste0("\\noindent ", escape_latex(description), "\\par\n")),
            latex = paste0("\\cvline{", title, "}{", date, "}\n", desc)
        )
    cat("\\begingroup\\setlength{\\parskip}{3pt}\n",
        paste(df$latex, collapse = ""),
        "\\endgroup\n", sep = "")
}

# Certifications: same header as other sections, no bullets
#   **Program**                                        2026
#   Institution                                        Location
make_cert_entries <- function(df) {
    df <- df %>%
        filter(!is.na(program)) %>%
        mutate(
            across(c(program, institution, where), ~escape_latex(as.character(.))),
            program = str_replace_all(program, " [Xx] ", " \\\\texttimes{} "),
            year    = as.character(year)
        )
    entries <- vapply(seq_len(nrow(df)), function(i) {
        paste0(cv_entry_head(df$program[i], df$institution[i], df$year[i], df$where[i]), "\\vspace{5pt}\n")
    }, character(1))
    cat("\\begingroup\\setlength{\\parskip}{0pt}\n", entries, "\\endgroup\n", sep = "")
}

# Mentoring, one numbered list (newest first):
#   Name (year), Department, University: Research theme
# `department` is optional; omitted when the column is missing or empty.
make_advising_entries <- function(df) {
    if (!"department" %in% names(df)) df$department <- NA_character_
    df <- df %>%
        filter(!is.na(name)) %>%
        arrange(desc(date_start)) %>%
        mutate(
            year  = format(as.Date(date_start), "%Y"),
            where = paste0(
                ifelse(is.na(department), "", paste0(", ", escape_latex(department))),
                ifelse(is.na(institution), "", paste0(", ", escape_latex(institution)))
            ),
            theme = ifelse(is.na(title), "", paste0(": ", escape_latex(title))),
            latex = paste0("  \\item \\textbf{", escape_latex(name), "} (", year, ")", where, theme)
        )
    cat("\\begin{enumerate}\n", paste(df$latex, collapse = "\n"), "\n\\end{enumerate}\n", sep = "")
}

# Presentations, one numbered list per category (newest first):
#   1. Coauthors and *Hossain, M. J. Title. Host, Location,
#      Month, Year.
# `with` markup (same as the pubs sheet):
#   \*Name, I.          mentee        -> surname underlined
#   \*\*Name, I.        undergraduate -> ** + surname underlined
#   ***Hossain, M. J.** corresponding -> * + bold
# "Hossain, M. J." is always bold, and appended when missing from `with`.
# `undergrad_mark = FALSE` drops the ** before undergraduate mentees (underline only).
make_presentation_entries <- function(df, cat = NULL, undergrad_mark = TRUE) {
    me <- "Hossain, M. J."
    tidy_authors <- function(x) {
        x %>%
            # Corresponding author: keep a bare * before the name
            str_replace_all("\\*\\*\\*([^*]+)\\*\\*", "@CORR@\\1") %>%
            str_remove_all("(?<!\\\\)\\*\\*") %>%
            # Mentees; {*} keeps the stars literal and out of later patterns
            str_replace_all("\\\\\\*\\\\\\*([\\p{L}'-]+)", if (undergrad_mark) "{*}{*}\\\\uline{\\1}" else "\\\\uline{\\1}") %>%
            str_replace_all("\\\\\\*([\\p{L}'-]+)", "\\\\uline{\\1}") %>%
            # "Islam, MM" -> "Islam, M. M."
            str_replace_all(",\\s*([A-Z]{1,3})(?=,|$|\\s|&)", function(m) {
                ini <- str_extract(m, "[A-Z]+")
                paste0(", ", paste0(strsplit(ini, "")[[1]], ".", collapse = " "))
            }) %>%
            str_replace_all(",?\\s*&\\s*", " and ") %>%
            str_squish()
    }
    df <- df %>%
        filter(!is.na(title), is.null(cat) | category %in% cat) %>%
        arrange(desc(date)) %>%
        mutate(
            authors = tidy_authors(na_to_space(with)),
            authors = case_when(
                str_detect(authors, fixed(me)) ~ authors,
                authors == ""                  ~ me,
                TRUE                           ~ paste(authors, "and", me)
            ),
            authors = str_replace(escape_latex(authors), fixed(me), paste0("\\textbf{\\mbox{", me, "}}")),
            authors = str_replace(authors, fixed("@CORR@"), "{*}"),
            title   = escape_latex(str_squish(str_remove(title, "\\.$"))),
            where   = str_remove_all(paste(na_to_space(host), na_to_space(location), sep = ", "), "^, |, $"),
            when    = format(as.Date(date), "%B, %Y"),
            latex   = paste0("  \\item ", authors, " ", title, ". ", escape_latex(where), ", ", when, ".")
        )
    # Raw block so pandoc leaves the LaTeX markup alone
    cat("```{=latex}\n\\begin{enumerate}\n",
        paste(df$latex, collapse = "\n"),
        "\n\\end{enumerate}\n```\n", sep = "")
}

# ---- Resume helpers ----
# Bioinformatics/computational work, matched on title
is_bioinfo <- function(title) {
    str_detect(str_to_lower(title), paste(
        "bioinformatic", "omic", "transcriptom", "single-cell", "rna-seq", "genom",
        "computational", "deep learning", "atlas", "immune landscape", "biomarker",
        "prognostic", "cancer", "carcinoma", "sarcoma", "glioma", "melanoma", "tcr",
        "perturb", "-seq", "spatial", "immune", "neural network", "copy-number",
        sep = "|"
    ))
}

# Resume selection: optional sheet column `resume` (1 = include, 0 = exclude)
# overrides the title keyword match; blank cells fall back to is_bioinfo().
pick_for_resume <- function(df) {
    auto <- is_bioinfo(df$title)
    if (!"resume" %in% names(df)) return(auto)
    flag <- suppressWarnings(as.numeric(as.character(unlist(lapply(df$resume, function(x) if (is.null(x)) NA else x)))))
    ifelse(is.na(flag), auto, flag == 1)
}

# DOI cells may hold a bare DOI or a full doi.org URL; keep the bare DOI
clean_doi <- function(x) str_remove(x, "^https?://(dx\\.)?doi\\.org/")

# Preprint server names as spelled by the servers
fmt_venue <- function(x) {
    x %>%
        str_replace(regex("^biorxiv$", ignore_case = TRUE), "bioRxiv") %>%
        str_replace(regex("^medrxiv$", ignore_case = TRUE), "medRxiv") %>%
        str_replace(regex("^arxiv$", ignore_case = TRUE), "arXiv")
}

# "Jun 2020 -- Present" from sheet start/end cells (list columns allowed)
resume_dates <- function(start, end) {
    s <- vapply(start, fmt_cv_date, character(1))
    e <- vapply(end, fmt_cv_date, character(1))
    ifelse(is.na(s), NA, ifelse(is.na(e), s, paste(s, "--", e)))
}

# Entries without bullets:
#   **Role**, Collaborator, Ph.D., Institution, Where           Date
#      *Project title*              (indented; "Project N:" label dropped)
#   Only detail lines matching `keep` are shown.
# A Collaborator/Advisor/Supervisor/PI detail line is folded into the
# header line, label dropped.
# An entry starts on each row with a role; `date` is a ready-made string.
make_resume_entries <- function(df, keep = "^(Project( \\d+)?|Thesis|Collaborators?|Advisors?|Supervisors?|PI):", relabel = NULL) {
    df <- df %>%
        mutate(
            across(c(role, institution, where, details), ~escape_latex(as.character(.))),
            entry = cumsum(!is.na(role))
        )
    entries <- lapply(split(df, df$entry), function(e) {
        head <- e[1, ]
        lines <- e$details[!is.na(e$details) & grepl(keep, e$details)]
        is_person <- grepl("^(Collaborators?|Advisors?|Supervisors?|PI):", lines)
        inst <- head$institution
        if (any(is_person)) {
            person <- sub("^[^:]+:\\s*", "", lines[is_person][1])
            inst <- if (is.na(inst)) person else paste0(person, ", ", inst)
        }
        lines <- lines[!is_person]
        if (!is.null(relabel)) lines <- str_replace(lines, relabel[1], relabel[2])
        is_project <- grepl("^Project( \\d+)?:", lines)
        lines <- ifelse(
            is_project,
            paste0("\\textit{", sub("^Project( \\d+)?:\\s*", "", lines), "}"),
            sub("^([^:]{1,20}:)\\s*", "\\\\textbf{\\1} ", lines)
        )
        paste0(
            # Two columns: long headers wrap on the left, date stays top-right
            "\\noindent\\begin{tabularx}{\\linewidth}{@{}>{\\raggedright\\arraybackslash}X@{\\hspace{1em}}r@{}}",
            paste(c(paste0("\\textbf{", head$role, "}"), na.omit(c(inst, head$where))), collapse = ", "),
            " & ", ifelse(is.na(head$date), "", head$date), "\\end{tabularx}\\par\n",
            # Details indented under the header, hanging so wrapped lines align
            if (length(lines)) paste0(
                "{\\leftskip=1.2em\\noindent ", lines, "\\par}\n", collapse = ""
            ) else "",
            "\\vspace{5pt}\n"
        )
    })
    # Raw block so pandoc passes the tabularx rows through untouched
    cat("```{=latex}\n\\begingroup\\setlength{\\parskip}{0pt}\n", unlist(entries), "\\endgroup\n```\n", sep = "")
}
