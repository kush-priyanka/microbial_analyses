## Install package DESeq2 using BiocManager 
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("DESeq2")

## Load libraries
library(DESeq2)
library(ggplot2)
library(tidyverse)
library(ggtext)

## Set directory

## Import bacterial/archaeal or fungal ASV table and metadata file
bac.asv.tax <- read.table("Oak_16S_ASV_Rarefy_12172021.txt", 
                      sep = "\t", header = T, row.names=1)
metadata.deseq <- read.table("Oak_16S_MappingFile_Richness_Ordination_12.19.2021.txt", 
                             sep = "\t", header = T, row.names=1)


## Check if sample names in asv file and mapping file are same
all(colnames(bac.asv.tax[,1:19]) == rownames(metadata.deseq)) #should be True

## Metadata for DESeq analysis
metadata.deseq$Horizon <- factor(metadata.deseq$Horizon, 
                                   levels = c("O", "A"))
metadata.deseq$Species <- factor(metadata.deseq$Species, 
                                     levels = c("Q.rubra", "Con"))

#### Datasets with aggregated values per taxon group ####
## Taxa groups: Phylum, Class, Order, Family, Genus (columns 21:25)
taxa_list <- list()
for (i in 21:25){
  bac.taxa <- as.data.frame(bac.asv.tax[, 1:19]) #1:19 are the sample columns
  bac.taxa$Taxa <- bac.asv.tax[,i]
  bac.taxa <- aggregate(.~Taxa, 
                          data = bac.taxa, 
                          sum)
  rownames(bac.taxa) <- bac.taxa[,1]
  bac.taxa <- bac.taxa[,-1]
  taxa_list[[i - 20]] <- bac.taxa
}

#### DESeq2 at five Taxon Groups ####
## Taxa groups: Phylum, Class, Order, Family, Genus (columns 1:5)
deseq.sig <- list()
for(i in 1:5){
bac.dds <- DESeqDataSetFromMatrix(countData = taxa_list[[i]], 
                                         colData = metadata.deseq,
                                         design = ~ Species + Horizon) #Can be one variable too

bac.dds <- DESeq(bac.dds)

bac.deseq.res <- results(bac.dds)
bac.deseq.res <- results(bac.dds,
                                contrast = c("Horizon", "O","A")) #This can be Control versus Treatment

bac.deseq.res <- as.data.frame(bac.deseq.res)

bac.deseq.sig <- subset(bac.deseq.res, 
                               bac.deseq.res$padj < 0.05) #Look at taxa with adjusted p-values <0.05

bac.deseq.sig$Taxa <- rownames(bac.deseq.sig)
bac.deseq.sig$Horizon <- ifelse(bac.deseq.sig$log2FoldChange > 0 , "Horizon O", "Horizon A")
deseq.sig[[i]] <- bac.deseq.sig

write.table(deseq.sig[[i]], 
            file = paste0("bac.deseq.sig.",i,"_03042022.txt"), 
            sep = "\t", quote = F, row.names = T, col.names = NA)
}

#### Plot the LogFoldChange ####
## Taxa groups: Phylum, Class, Order, Family, Genus (columns 1:5)
deseq.plot <-list()
for(i in 1:5){
  deseq.plot[[i]]  <- ggplot(deseq.sig[[i]], 
       aes(x = log2FoldChange,
           y = Taxa,
           color = log2FoldChange >0)) +
  geom_point(size = 3) + 
  scale_y_discrete(limits = rev) +
  scale_colour_manual(name = 'log2FoldChange > 0', 
                      values = setNames(c('green','red'),
                                        c(T, F))) +
  theme(axis.text.x = element_text(angle = -90, 
                                   hjust = 0, 
                                   vjust = 0.5)) +
  theme_bw() + 
  ggtitle("Horizon O (>0, green) vs Horizon A (<0, red)") +
  guides(color = "none")
  
  ggsave(filename = paste0("bac_deseq2_", i, "_03042022.pdf"), 
         plot = deseq.plot[[i]],
         width = 7,
       height = 6,
         units ="in")
}

#### Better visual for DESeq2 Plots ####
## deseq.sig[[1]] is Phylum level
deseq.sig[[1]]$Horizon <- factor(deseq.sig[[1]]$Horizon, 
                                 levels = c("Horizon O", "Horizon A"))
deseq.sig[[1]] %>%
mutate(Taxa = str_replace(string = Taxa,
                           pattern="(.*)",
                           replacement = "*\\1*")) %>%
mutate(Taxa = fct_reorder(Taxa, log2FoldChange),
         label_x = if_else(Horizon == "Horizon O", -1, 1),
         label_hjust = if_else(Horizon == "Horizon O", 0.5, 0.5)) %>%
ggplot(aes(x = log2FoldChange,
           y = Taxa,
           label = Taxa, 
           fill = Horizon)) +
  geom_col() +
  geom_vline(xintercept = seq(-5, 5, by = 1),
             linetype = "dotted",
             color = "darkgray") +
  geom_richtext(aes(x = label_x,
                    hjust = label_hjust),
                fill = NA, 
                label.color = NA) +
  labs(y = NULL, x = "Log Fold Change") +
  scale_x_continuous(limits = c(-5, 5), breaks = seq(-5, 5, by = 1)) +
  scale_fill_manual(values = c("gray", "blue")) +
  theme_classic() +
  theme(axis.text.y = element_blank(),
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "top",
        legend.title = element_blank())

ggsave(filename = paste0("bac_deseq2_03052022.pdf"), 
           width = 7,
           height = 6,
        units ="in")