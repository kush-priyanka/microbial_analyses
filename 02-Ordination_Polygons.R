## Load libraries
library(dplyr)
library(ggplot2)
library(vegan)

### NMDS plots
## Calculate Bray-Curtis distance using the rarefied ASV read count (rar.asv)
bac.dist <- vegdist(rar.asv, method="bray")
bac.nmds <- metaMDS(bac.dist, k=2)
bac.nmds$stress #note stress value   

## Add NMDS axis values to the mapping file (map.wbl)
map.wbl$Axis01 <- bac.nmds$points[,1]
map.wbl$Axis02 <- bac.nmds$points[,2]

### Add polygons (hulls) on datapoints (requires dyplyr package)
hull_cyl <- map.wbl %>%
  group_by(Treatment) %>%
  slice(chull(Axis01, Axis02))

## Save an NMDS plot with Polygons
pdf("Oak_Bac_NMDS_Polygons_02162022.pdf", width=8)
ggplot(map.wbl, aes(Axis01, Axis02))+
  geom_point(aes(color = Treatment, shape = Horizon), 
             alpha = 0.8, size=4)+
  aes(fill = factor(Treatment)) + 
  geom_text(data = map.wbl,
            aes(Axis01, Axis02,
                label = Sample_name),
            size = 3,
            vjust = 0,
            hjust = 0) +
  geom_polygon(data = hull_cyl, 
               alpha = 0.3)+
  theme_bw()+
  theme(legend.position = "right")
dev.off()

## Save an NMDS plot with ellipse (alternative format)
pdf("Oak_Bac_NMDS_Ellipse_02162022.pdf", width=8)
ggplot(map.wbl, aes(Axis01, Axis02, 
                    color = Treatment, fill = Treatment)) +
  stat_ellipse(geom = "polygon",
               level = 0.8,
               alpha = 0.3) +
  geom_point(aes(shape = Horizon), 
             alpha = 0.8, 
             size = 4)+
  theme_bw() +
  theme(legend.position="right")
dev.off()

## Note: Add sample labels using geom_text
#geom_text(data = map.wbl,aes(Axis01, Axis02,label = Sample_name),
#size = 3, vjust = 0, hjust = 0)