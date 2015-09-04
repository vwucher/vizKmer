#!/usr/bin/env Rscript
# Usage: plotVizKmer.r <NUCLEOTIDES SCORES FRAME 0> <NUCLEOTIDES SCORES FRAME 1> <NUCLEOTIDES SCORES FRAME 2> <OUTPUT NAME>

library(ggplot2)
library(reshape2)

args <- commandArgs(TRUE)
if(length(args)!=4)
{
    print("Error. Usage: plotVizKmer.r <NUCLEOTIDES SCORES FRAME 0> <NUCLEOTIDES SCORES FRAME 1> <NUCLEOTIDES SCORES FRAME 2> <OUTPUT NAME>")
}

input0 <- args[1]
input1 <- args[2]
input2 <- args[3]
output <- args[4]

data0      <- cbind(read.table(file=input0, header=TRUE, sep="\t"), frame=as.factor(0))
data1      <- cbind(read.table(file=input1, header=TRUE, sep="\t"), frame=as.factor(1))
data2      <- cbind(read.table(file=input2, header=TRUE, sep="\t"), frame=as.factor(2))
data.melt  <- melt(rbind(data0,data1,data2), id=c("nuc","frame"))
data.melt  <- data.melt[!is.na(data.melt$value),]

###line  <- geom_line(data=subset(data.melt,variable=="none.start.stop"), alpha=0.5, size=2)
step  <- geom_step(data=subset(data.melt,variable=="none.start.stop"), alpha=0.5, size=2)
face  <- facet_wrap(~variable, ncol=1, scale="free")
colo  <- scale_fill_brewer(palette="Set1")
smoot <- stat_smooth(data=subset(data.melt,variable!="none.start.stop"), method = "loess", se=FALSE, span=0.05, size=2)
addl  <- geom_hline(data=subset(data.melt,variable!="none.start.stop"), yintercept=0.5)
graph <- ggplot(data=data.melt, aes(x=nuc, y=value, colour=frame)) + colo + face + smoot + step + addl

ggsave(plot=graph, filename=output, scale=2, height=5, width=10, dpi=1000)


### Pas mal
## point <- geom_point(data=subset(data.melt,variable=="none.start.stop"), aes(shape=frame), size=3)
## face  <- facet_wrap(~variable, ncol=1, scale="free")
## colo  <- scale_fill_brewer(palette="Set1")
## smoot <- stat_smooth(data=subset(data.melt,variable!="none.start.stop"), mapping=aes(linetype=frame), method = "loess", se=FALSE, span=0.05)
## graph <- ggplot(data=data.melt, aes(x=nuc, y=value, colour=variable)) + colo + face + smoot + point

## ggsave(plot=graph, filename=output, scale=2, height=5, width=10, dpi=1000)



## #line  <- geom_line(aes(linetype=frame))
## point <- geom_point(data=subset(), aes(type=frame), size=3)
## face  <- face  <- facet_wrap(~variable, ncol=1, scale="free")
## colo  <- scale_fill_brewer(palette="Set1")
## smoot <- stat_smooth(mapping=aes(linetype=frame), method = "loess", se=FALSE, span=0.05)
## graph <- ggplot(data=data.melt[!is.na(data.melt$value),], aes(x=nuc, y=value, colour=variable))  + colo + face + smoot

## ###graph <- ggplot(data=data.melt[!is.na(data.melt$value),], aes(x=nuc, y=value, colour=variable))  + colo + face + line

## ggsave(plot=graph, filename=output, scale=2, height=5, width=10, dpi=1000)


###graph <- ggplot(data=data.melt[!is.na(data.melt$value),], aes(x=nuc, y=value, colour=variable))  + colo + face + line
###line  <- geom_line(aes(linetype=frame))


