## Load libraries
library(vegan) 
library(ggplot2)
library(reshape)
library(gridExtra)

## Import Rarefied file: Bac/Arch rarefied file
bl.asv.tax <- read.table("Oak_16S_ASV_Rarefy_12172021.txt", 
                         sep = "\t", header = T, row.names = 1)
dim(bl.asv.tax)
colnames(bl.asv.tax)

## Subset asv read and taxonomy info into two variables
bac.asv <- bl.asv.tax[,-c(20:26)]
dim(bac.asv) 

tax.table <- bl.asv.tax[,c(20:26)]
dim(tax.table)

all(rownames(bac.asv)==rownames(tax.table))
bac.asv$taxonomy<-paste(tax.table$Kingdom, 
                        tax.table$Phylum, 
                        tax.table$Class,
                        tax.table$Order, 
                        tax.table$Family, 
                        tax.table$Genus,
                        tax.table$Species, sep=";")

## Save the file to use as FAPROTAX input file
write.table(bac.asv, file = "16S_oak_asv_faprotax_01132022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

## Run FAPROTAX in the terminal 

## Import faprotax output file with functional groups and read counts
faprotax <- t(read.table("oak_faprotax.txt",
                         sep = "\t", 
                         header = T, row.names = 1))
dim(faprotax)
faprotax.filter <- subset(faprotax,
                          select = colSums(faprotax)!= 0)
dim(faprotax.filter)

bac.asv.t <- bac.asv[,-20] #remove taxonomy column
bac.asv.t <- t(bac.asv.t)

## Calculate proportions for each function
faprotax.filter <- faprotax.filter/rowSums(bac.asv.t)
faprotax.filter <- subset(faprotax.filter, 
                          select=colSums(faprotax.filter)!= 0)

## Save a file with function proportion
write.table(faprotax.filter, file = "Oak_16S_faprotax_results_propor_01202022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

## import mapping file
map<-read.table(file.choose(), 
                sep = "\t", header = T, row.names = 1)
dim(map)

all(rownames(faprotax.filter) == rownames(map))

## Merge mapping file with function proportion
map.faprotax<-cbind(map, faprotax.filter)
map.fap <- map.faprotax[,c(1:9,27:76)]

## Save mapping file with function proportion
write.table(map.fap, 
            file="Oak_16S_Mapping_faprotax_results_propor_01202022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

## Subset the maping file to plot selected functions
map.fap.kw <- melt(map.fap[,c(8,7,33,40,39,43,10,15,48,58)])

pdf("faprotax_oak_01202022.pdf", width=10)
ggplot(data = map.fap.kw, 
       aes(x = variable, y = value, fill = Species))+
  geom_boxplot(alpha = 0.7, outlier.shape = NA)+
  geom_jitter(aes(color = Species, shape=Horizon), 
              alpha = 0.8, 
              position=position_jitterdodge(dodge.width = 0.50))+
  xlab(NULL)+
  ylab("Proportion")+
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, 
                                   hjust = 1))
dev.off()

map.fap$Treatment <- factor(map.fap$Treatment, 
                            levels = c("Q.rubra_O", "Q.rubra_A", "Con_O", "Con_A"))
map.fap$Species <- factor(map.fap$Species, 
                          levels = c("Q.rubra", "Con"))

## Plot functions individually
pdf("faprotax_oak_aerobic_chemoheterotrophy_01202022.pdf", 
    width = 10, height = 8)
ggplot(data = map.fap, 
       aes(x = Treatment, y = aerobic_chemoheterotrophy))+
  geom_boxplot(alpha = 0.7, outlier.shape = NA)+
  geom_jitter(aes(color = Species, shape = Horizon), 
              alpha = 0.8, 
              position = position_jitter(width = 0.05), 
              size = 2)+
  xlab(NULL)+
  ylab("Proportion")+
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  ggtitle("aerobic_chemoheterotrophy")
dev.off()
