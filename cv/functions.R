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
        mutate(across(everything(), ~na_if(., "NULL")))

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

    # Group and nest details
    df_nested <- df_filled %>%
        group_by(across(all_of(group_cols))) %>%
        summarize(bullets = list({{details_col}}), .groups = "drop")

    # Generate LaTeX code
    entries <- df_nested %>%
        rowwise() %>%
        mutate(latex = {
            # Format bullets
            bullet_list <- bullets
            bullet_list <- bullet_list[!is.na(bullet_list)]

            if (length(bullet_list) > 0) {
                bullet_latex <- paste0(
                    "\\begin{itemize}[nosep,topsep=2pt,leftmargin=1em]\n",
                    paste0("  \\item ", bullet_list, collapse = "\n"),
                    "\n\\end{itemize}"
                )
            } else {
                bullet_latex <- ""
            }

            # Role (bold) \hfill Location (italic)
            role_text  <- if (!is.na({{role_col}}))  paste0("\\textbf{", {{role_col}}, "}") else ""
            where_text <- if (!is.na({{where_col}})) paste0("\\textit{", {{where_col}}, "}") else ""

            # Institution (plain) \hfill Date
            inst_text <- if (!is.na({{inst_col}})) {{inst_col}} else ""
            date_text <- if (!is.na({{date_col}})) {{date_col}} else ""

            paste0(
                "\\noindent\\begin{tabular*}{\\linewidth}{@{}l@{\\extracolsep{\\fill}}r@{}}\n",
                role_text, " & ", where_text, " \\\\\n",
                inst_text, " & ", date_text, " \\\\\n",
                "\\end{tabular*}\n",
                if (bullet_latex != "") paste0(bullet_latex, "\n") else "",
                "\\vspace{5pt}\n"
            )
        }) %>%
        pull(latex)

    cat(entries, sep = "\n")
}
