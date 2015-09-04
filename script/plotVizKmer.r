#!/usr/bin/env Rscript
# Usage: plotVizKmer.r <NUCLEOTIDES SCORES> <OUTPUT NAME>

library(ggplot2)
library(reshape2)

args <- commandArgs(TRUE)
if(length(args)!=2)
{
    print("Error. Usage: plotVizKmer.r <NUCLEOTIDES SCORES> <OUTPUT NAME>")
}

input  <- args[1]
output <- args[2]

data      <- read.table(file=input, header=TRUE, sep="\t")
data.melt <- melt(data, id=colnames(data)[1])
data.melt <- data.melt[!is.na(data.melt$value),]

step  <- geom_step(data=subset(data.melt,variable=="none.start.stop"), alpha=0.5, size=2)
face  <- facet_wrap(~variable, ncol=1, scale="free_y")
colo  <- scale_fill_brewer(palette="Set1")
smoot <- stat_smooth(data=subset(data.melt,variable!="none.start.stop"), method = "loess", se=FALSE, span=0.05)
addl  <- geom_hline(data=subset(data.melt,variable!="none.start.stop"), yintercept=0.5)
graph <- ggplot(data=data.melt, aes(x=nuc, y=value, colour=variable)) + colo + face + smoot + step + addl

ggsave(plot=graph, filename=output, scale=2, height=5, width=10, dpi=1000)
