library(readxl)
library(ggplot2)
library(ggrepel)
setwd("C:/Users/ngoca/Dropbox/Pubs_since_2018/2018-Intra-Asian-FDI/Economic-Modelling/2nd submission")
df <- read_excel("2012data.xls")
str(df)

myPlot <- ggplot(df, aes(x=loutward, y = linward, group =factor(netsender))) + 
    geom_point(aes(shape=factor(netsender)), size =3) + geom_text_repel(label = df$countryiso) +
    geom_abline(intercept = 0, slope = 1) +
    xlim(0,13) +
    ylim(0,13) +
    labs(y = "ln(inward stock)", x = "ln(outward stock)") +
    scale_fill_discrete(name = "Country groups", labels = c("Net receiver", "Net sender"))+
    theme_minimal() +
    theme(legend.position = c(0.5,1), legend.direction = "horizontal", legend.title = element_blank(), legend.text = element_text(size = 12))

myPlot
ggsave("myPlot2.png", width = 8, height =6.8)
myPlot
# pdf("myPlot2.pdf")
# print(myPlot2)
# dev.off()
