# CV
Template for creating a data-driven Curriculum Vitae in two formats, as a website and as a PDF, using Quarto and HTML/CSS formatting.

I would like to acknowldge Cynthia A Huang for creating the initial Quarto CV template (https://www.cynthiahqy.com/posts/cv-html-pdf/). Furthermore, the icons that can be found in the pdf version of the CV are from:

* academicons (https://jpswalsh.github.io/academicons/)
* iconify (https://icon-sets.iconify.design/)



Rendering of the html/pdf files was done using the weasyprint engine, which requires the following software installations:

* quarto (installation instructions here: https://quarto.org/docs/download/)
* weasyprint (installation instructions here: https://doc.courtbouillon.org/weasyprint/v52.5/install.html#windows)


Rendering was done from the command line, following the activation of the Python Environment with Quarto. Use this command:
* quarto render index.qmd --output-dir docs

Instructions on how to host Quarto documents on Github Pages:
* https://quarto.org/docs/publishing/github-pages.html#render-to-docs


Note, when using RStudio as .qmd editor, do NOT use "Visual" Markdown editing mode to maintain HTML formatting.