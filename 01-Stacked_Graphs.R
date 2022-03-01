## Load libraries
library(tidyverse)
library(ggplot2)

## See example code at the link:
## https://www.youtube.com/watch?v=NVym44SdcaE&ab_channel=RiffomonasProject

## Oak Study Data
## Import metadata and subset for Sample ID and Treatment or other variables of interest for plotting
metadata <- read.table("C:/Users/priya/Box/AZ_UA_Jan2022/2021_Ongoing_Projects/Oak_Study/bac_16S/Post_dada2_Files/Oak_16S_Mapping_File_woBlanks_11.16.2021.txt",
                       header=T,  sep="\t") %>%
  select(ID, Treatment) %>%
  drop_na(Treatment) %>%
filter(ID != "KP4480")

## Import ASV + taxa combined rarefied file
rar <- read.table("C:/Users/priya/Box/AZ_UA_Jan2022/2021_Ongoing_Projects/Oak_Study/bac_16S/Post_dada2_Files/Bac_Dec20_2021/Oak_16S_ASV_Rarefy_12172021.txt",
                 header=T,  sep="\t")
## Add asv number instead of sequences
rar <- cbind(rar, "asv"=1:nrow(rar)) 
rar$asv<-paste('asv', rar$asv, sep="_")

## Subset taxonomy data including asv number and taxonomy
taxa <- rar[, c(28, 21:27)]

## Convert taxonomy labels to lowercase (optional)
taxonomy <- taxa %>%
  select("asv", "Kingdom","Phylum", "Class", "Order", "Family",  "Genus","Species") %>%
  rename_all(tolower)


## Subset asv counts 
asv <- rar[, c(28,2:20)]

## manipulate dataframe to have asv numbers as column and sample id as rownames
rownames(asv) <- asv$asv
read <- t(asv[, 2:20])
ID <- rownames(read)
rownames(read) <- NULL
read <- cbind(ID, read)
read <- data.frame(read)

## Calculate asv counts per sample id
asv_counts <- read %>%
  select(ID, starts_with("asv"))%>%
  pivot_longer(-ID, names_to="asv", values_to = "count")  
asv_counts$count <- as.numeric(asv_counts$count)
  
## Join three datsets and calculate relative abundance
asv_rel_abund <- inner_join(metadata, asv_counts, by = "ID") %>%
  inner_join(., taxonomy, by="asv") %>%
  group_by(ID) %>%
  mutate(rel_abund = count / sum(count)) %>%
  ungroup() %>%
  select(-count) %>%
  pivot_longer(c("kingdom", "phylum", "class", "order", "family", "genus", "asv"),
               names_to="level",
               values_to="taxon")

## Subset dataframe at Phylum (average of relative abundance within a treatment)
phylum <- asv_rel_abund %>%
  filter(level =="phylum") %>%
  group_by(Treatment, ID, taxon)%>%
  summarize(rel_abund = sum(rel_abund), .groups = "drop") %>%
  group_by(Treatment, taxon) %>%
  summarize(mean_rel_abund = 100* mean(rel_abund), .groups = "drop") 

## Example color palette to use for the taxa color
mypalette2  <- c("#40004b","#ffffbf","#762a83","#fdbf6f","#9970ab","#ccebc5","#c2a5cf","#e7d4e8","#b8e186","#bebada",
                 "#de77ae","#f46d43","#f7f7f7","#d9f0d3","#a6dba0","#4d9221","#2166ac","#5aae61","#1b7837","#d73027",
                 "#00441b","#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#b2182b","#de77ae",
                 "#bc80bd","#f5f5f5","#c7eae5","#80cdc1","#35978f","#003c30",
                 "#8e0152","#fb8072","#c51b7d","#f1b6da","#fde0ef","#fdb462","#b3de69","#7fbc41","#276419",
                 "#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#ff7f00","#cab2d6","#6a3d9a","#ffff99",
                 "#8dd3c7","#ffffb3","#80b1d3","#fdb462","#01665e","#fccde5","#d9d9d9",
                 "#40004b","#762a83","#fdbf6f","#9970ab","#ccebc5","#c2a5cf","#e7d4e8","#b8e186","#bebada",
                 "#de77ae","#f7f7f7","#d9f0d3","#a6dba0","#4d9221","#5aae61","#1b7837"
                 ,"#00441b","#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#bc80bd","#f5f5f5","#c7eae5","#80cdc1","#35978f","#003c30",
                 "#8e0152","#fb8072","#c51b7d","#f1b6da","#fde0ef","#fdb462","#b3de69","#7fbc41","#276419",
                 "#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#ff7f00","#cab2d6","#6a3d9a","#ffff99",
                 "#8dd3c7","#ffffb3","#80b1d3","#fdb462","#01665e","#fccde5","#d9d9d9","#bc80bd","#f5f5f5","#c7eae5","#80cdc1","#35978f","#003c30",
                 "#8e0152","#fb8072","#c51b7d","#f1b6da","#fde0ef","#fdb462","#b3de69","#7fbc41","#276419",
                 "#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#ff7f00","#cab2d6","#6a3d9a","#ffff99",
                 "#8dd3c7","#ffffb3","#80b1d3","#fdb462","#01665e","#fccde5","#d9d9d9",
                 "#40004b","#762a83","#fdbf6f","#9970ab","#ccebc5","#c2a5cf","#e7d4e8","#b8e186","#bebada",
                 "#de77ae","#f7f7f7","#d9f0d3","#a6dba0","#4d9221","#5aae61","#1b7837"
                 ,"#00441b","#543005","#8c510a","#bf812d","#dfc27d","#f6e8c3","#bc80bd","#f5f5f5","#c7eae5","#80cdc1","#35978f","#003c30",
                 "#8e0152","#fb8072","#c51b7d","#f1b6da","#fde0ef","#fdb462","#b3de69","#7fbc41","#276419",
                 "#a6cee3","#1f78b4","#b2df8a","#33a02c","#fb9a99","#e31a1c","#ff7f00","#cab2d6","#6a3d9a","#ffff99",
                 "#8dd3c7","#ffffb3","#80b1d3","#fdb462","#01665e","#fccde5","#d9d9d9")

## Plot relative abundance at Phylum level
phylum_plot <- ggplot(data = phylum, 
                      aes(x = Treatment, 
                          y = mean_rel_abund, 
                          fill = taxon)) +
 geom_col()+
 scale_fill_manual(values = mypalette2) +
 labs(x = NULL, 
      y = "Mean Relative Abundnace (%") +
theme_bw()

ggsave(plot = phylum_plot, 
       file = "Phylum_treatments.pdf", 
       width = 8, height = 4)


## Plot taxa single taxa of interest Cyanobacteria (average of relative abundance within a treatment)
cyanobac <- asv_rel_abund %>%
  filter(taxon =="Cyanobacteria") %>%
  group_by(Treatment, ID, taxon)%>%
  summarize(rel_abund = sum(rel_abund), .groups = "drop") %>%
  group_by(Treatment, taxon) %>%
  summarize(mean_rel_abund = 100* mean(rel_abund), .groups = "drop") %>%
ggplot(aes(x = Treatment, y = mean_rel_abund, fill = taxon)) +
  geom_col()+
  scale_fill_manual(values = mypalette2) +
  labs(x = NULL, y = "Mean Relative Abundnace (%") +
  theme_bw()

ggsave(plot = cyanobac, 
       file ="Cynobacteria_treatments.pdf", 
       width = 5, height = 4)

## Plot relative abundance at sample level
phylum_sample <- asv_rel_abund %>%
  filter(level =="phylum") %>%
  group_by(Treatment, ID, taxon) %>%
  ggplot(aes(x = ID, y = 100 * rel_abund, fill = taxon)) +
  geom_col()+
  scale_fill_manual(values = mypalette2) +
  labs(x = NULL, y = "Relative Abundnace (%)") +
  theme_bw() +
  theme(
        axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file = "Phylum_sample.pdf", 
       plot = phylum_sample, 
       width = 8, height = 4)
