library(showtext)
## Loading Google fonts (http://www.google.com/fonts)
font_add_google("Gochi Hand", "gochi")
## Automatically use showtext to render text for future devices
showtext_auto()

## use the ggplot2 example
sticker(p, package="hexSticker", p_size=22, s_x=1, s_y=.75, s_width=1.3, s_height=1,
        p_family = "gochi", filename="inst/figures/ggplot2-google-font.png")
