## Load libraries
library(vegan) #for multivariate statistics
library(ggplot2)
library(reshape)
library(gridExtra)
library(ggbiplot)

## Import Rarefied file
asv.tax <- read.table("Oak_ITS_ASV_Rarefy_12202021.txt", sep="\t", header=T, row.names=1)
dim(asv.tax)
colnames(asv.tax)

## Subset asv read and taxonomy info into two variables
fun.asv<-asv.tax[,-c(21:27)]
dim(fun.asv) 

tax.table<-asv.tax[,c(21:27)]
dim(tax.table)

all(rownames(fun.asv)==rownames(tax.table))
fun.asv$taxonomy<-paste(tax.table$Kingdom, tax.table$Phylum, tax.table$Class,
                        tax.table$Order, tax.table$Family, tax.table$Genus,
                        tax.table$Species, sep=";")

## Save the file to use as FUnGuild input file
write.table(fun.asv, file = "ITS_oak_asv_funguild_01202022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

#Run FUNGuild script in your Terminal (using python)
#python Guilds_v1.1.py -otu C:\Users\priya\Box\AZ_UA_Jan2022\2021_Ongoing_Projects\Oak_Study\fun_ITS\FUNGuild_Jan2022\ITS_oak_asv_funguild_01202022.txt -db fungi -m -u

## Upload the file with Funguild assignments (.guilds.matched file)
funguild <- t(read.table("ITS_oak_asv_funguild_01202022.guilds_matched.txt", 
                         sep = "\t", header = T, row.names = 1))
dim(funguild)
colnames(funguild)
rownames(funguild)

## Check if Funguild and ASV samples are matched
fun.asv.t<-t(fun.asv)
rownames(fun.asv.t[1:20,])==rownames(funguild[1:20,])


fun.asv.t<-as.data.frame(funguild[1:20,])
fun.asv.t<-apply(fun.asv.t, 2, function (x) {as.numeric(as.character(x))})
rownames(fun.asv.t)<-rownames(funguild[1:20,])

## Calculate proportion for guilds
## Note change column number 25 to Guilds for your dataset
guilds <- as.data.frame(apply((apply(fun.asv.t, 1, function (x) by(x, as.factor(funguild[25,]), sum))), 2, function (x) {x/sum(x)}))
dim(guilds) 

#Save the file
write.table(guilds, file = "Oak_ITS_funguild_results_propor_01202022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

#Check for columns with many zeroes
guilds.t <- t(guilds)
guilds.t <- subset(guilds.t, 
                   select=  colSums(guilds.t)!= 0)

## Import mapping file
metadata<- read.table("Oak_ITS_Mapping_File_woBlank_11.16.2021.txt", 
                      sep = "\t", header = T, row.names =1)
dim(metadata) 

## Merge mapping file with function proportion
map.funguild <- cbind(metadata, guilds.t)
map.guild <- map.funguild[,c(1:9, 21:98)] #remove soil data

## Save mapping file with function proportion
write.table(map.guild, 
            file = "Oak_ITS_Mapping_funguild_propor_01202022.txt", 
            sep = "\t", quote = F, row.names = T, col.names = NA)

## Subset the maping file to plot selected functions
map.fun.kw <- melt(map.funguild[,c(8,7,26,60,68,86,88,96)])

pdf("funguild_kruskalwallis_oak_species_01202022.pdf", 
    height = 8, width = 10)
ggplot(data = map.fun.kw, 
       aes(x = variable, y = value, fill = Species))+
  geom_jitter(aes(color = Species, shape = Horizon), 
              alpha = 0.8, position = position_jitter())+
  geom_boxplot(alpha = 0.7, outlier.shape = NA)+
  xlab(NULL)+
  ylab("Proportion")+
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
dev.off()

## Plot at function/guild level
map.funguild$Treatment <- factor(map.funguild$Treatment, 
                                 levels = c("Q.rubra_O", "Q.rubra_A", "Con_O", "Con_A"))
map.funguild$Species <- factor(map.funguild$Species, 
                               levels = c("Q.rubra","Con"))

## Note funguild groups have space in their names so cannot be selcted by data$group
## Use column number instead
pdf("faprotax_oak_aerobic_Arbuscular Mycorrhizal_01202022.pdf", 
    width = 10, height = 8)
ggplot(data = map.funguild, 
          aes(x= Treatment, y = map.funguild[,24]))+
  geom_boxplot(alpha = 0.7, outlier.shape = NA)+
  geom_jitter(aes(color = Species, shape = Horizon), 
              alpha = 0.8, 
              position = position_jitter(width=0.05), 
              size = 2)+
  xlab(NULL)+
  ylab("Proportion")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 45, 
                                   hjust = 1))+
  ggtitle("Arbuscular Mycorrhizal")