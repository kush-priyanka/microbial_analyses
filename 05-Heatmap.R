## Load library
library(ggplot2)

## Set working directory to where the input data file is

## Import mean average proportion for selected microbial functions
func.melt<- read.table("Oak_Selected_Functions_AvgProportion_Heatmap_030222022.txt", 
                       sep = "\t", header = T) 

## Turn off scientific notation for numbers
options(scipen = 999)

## Set the order of labels backwards for correct order output
func.melt$variable <- factor(func.melt$variable,
                             levels = c("Wood.Saprotroph",
                                        "Soil.Saprotroph",
                                        "Plant.Saprotroph","Plant.Pathogen",
                                        "Litter.Saprotroph" ,
                                        "Leaf.Saprotroph", 
                                        "Fungal.Parasite", 
                                        "Epiphyte",
                                        "Endophyte",
                                        "Ectomycorrhizal",
                                        "AMF",
                                        "ureolysis",
                                        "nitrification",
                                        "ar_ammonia_oxidatn",
                                        "nitrate_respiration", 
                                        "fe_respiration",
                                        "phototrophy",
                                        "photoheterotrophy", 
                                        "a_chemoheterotrophy",
                                        "ar_hydroc_degrad",
                                        "ar_compd_degrad",
                                        "methylotrophy",
                                        "methanotrophy"))

func.melt$Treatment <- factor(func.melt$Treatment, 
                              levels = c("Q.rubra_O",
                                         "Q.rubra_A",
                                         "Con_O",
                                         "Con_A"))

pdf("Oak_Microbial_Function_heatmap_03022022.pdf", 
    width = 6, height = 6)
ggplot(func.melt, aes(x = Treatment, 
                      y = variable, 
                      fill = value)) +
  geom_tile(color = "lightgray") +
  geom_text(aes(x = Treatment, 
                y = variable, label = value))+
  coord_fixed(ratio = 0.2)+
  scale_fill_gradientn(colors = c( 
    "lightyellow",
    "yellow", 
    "orange", 
    "red"), 
    breaks = c(0,0.2, 0.5, 0.7))+
  scale_x_discrete(position = "top") +
  ylab("Selected Microbial Functions") +
  theme_minimal(base_size = 12) +
  theme(legend.title = element_blank()) +
  theme(axis.ticks = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_text(size = 10,  
                                   face = "bold", 
                                   color = "black"),
        axis.title.y = element_text(size = 12, 
                                    face = "bold"),
        axis.text.y = element_text(size = 10, 
                                   face = "bold", 
                                   color = "black"),
        legend.key.height = unit(0.3, 'cm'),
        legend.key.width = unit(0.5, 'cm'),
        legend.title = element_text(size = 7),
        legend.text = element_text(size = 6), 
        legend.position = "bottom",
        legend.direction = "horizontal", 
        legend.box = "horizontal",
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(-10,-10,-10,-10)) +
  guides(fill = guide_colorbar(title = "Average Proportion", 
                               title.position = "top"))
dev.off()