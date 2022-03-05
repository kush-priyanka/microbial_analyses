## Script to do the following:
## 1) Calculate relative abundance 
## 2) Create 1 taxonomy column by merging 7 columns into one with a separator '|'
## 3) Create a column with ASV numbers
## Note :The separator can be '|' or ';'depending on the requirement of the analysis

## Load library
library(vegan)

## Set the working directory

## Import the rarefied file with taxonomy info
bac.asv.taxa <- read.table("Oak_16S_ASV_Rarefy_12172021.txt", 
                           sep = "\t", header = T, row.names = 1)
dim(bac.asv.taxa) 

## Separate the dataframe into ASV counts + Taxonomy
## ASV counts
taxa <- bac.asv.taxa[,c(20:26)]
dim(taxa)

## Taxonomy 
bac.asv <- t(bac.asv.taxa[,-c(20:26)])
dim(bac.asv)

## Import mapping file
map.oak <- read.table("Oak_16S_MappingFile_12.19.2021.txt", 
                      sep = "\t", 
                      header = T, 
                      row.names = 1)
dim(map.oak)

## Match ASV sample names to the mapping file sample names
map.oak <- map.oak[rownames(bac.asv),]
dim(map.oak) 

## Check if sample names in asv file and mapping file are same
all(rownames(bac.asv) == rownames(map.oak)) #should be True

#### Calculate relative abundance ####
apply(bac.asv, 1, sum) #all samples should have the same number if rarefied
bac.oak <- decostand(bac.asv, 
                     method = "total")
apply(bac.oak, 1, sum) #1 for all samples

## Transpose the relative abundance dataframe to before adding taxonomy info
bac.oak.t <- as.data.frame(t(bac.oak))
all(rownames(bac.oak.t) == rownames(taxa)) #should be TRUE

#### Add the taxonomy column ####
## sep = "|" is used here
bac.oak.t$taxonomy<-paste(taxa$Kingdom, 
                          taxa$Phylum, 
                          taxa$Class,
                          taxa$Order, 
                          taxa$Family, 
                          taxa$Genus,
                          taxa$Species, 
                          sep = "|")

#### Append a column with ASV numbers ####
## First add column 'asv' with sequential numbers
bac.oak.t <- cbind(bac.oak.t, 
                   "asv" = 1:nrow(bac.oak.t)) 

## Create a column 'ID' with text 'bac' appended with numbers from asv column
bac.oak.t$ID <- paste('bac', 
                      bac.oak.t$asv, 
                      sep = "_") 

## Save the file
write.table(bac.oak.t, 
            file = "Oak_16S_Abundance_12172021.txt", 
            sep = "\t", 
            quote = F, 
            row.names = T, 
            col.names = NA)