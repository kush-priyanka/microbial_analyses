### List of folders and files in project ###
- Scripts
  - Stacked graphs
  - Ordination with polygons
- plots
  - Stacked graph at Cyanobacteria phylum
  - Stacked graph at Phylum sample level
  - Stacked graph at Phylum treatment level

### Instructions for Faprotax ###
- Download [python](https://www.python.org/downloads/)
- Download latest version of the [FAPROTAX](http://www.loucalab.com/archive/FAPROTAX/lib/php/index.php?section=Download) 
- Unzip the FAPROTAX folder
- Format  ASV + Taxonomy table as per the FAPROTAX.R script
- Go terminal on your laptop 
- Change the directory to FAPROTAX folder \n
`cd C:/Users/priya/Desktop/FAPROTAX_1.2.4`
- Run the following code
  ```
  python collapse_table.py -i C:/Users/priya/Desktop/16S_oak_asv_faprotax_01132022.txt -o oak_faprotax.txt -g FAPROTAX.txt -d "taxonomy" --omit_columns '0' -r report_16Soak.txt -v
  ```

- Descriptors of the files used in the code
  - input file location:      C:/Users/priya/Desktop/16S_oak_asv_faprotax_01132022.txt
  
  - output file (functional groups with counts/sample):      oak_faprotax.txt
  
  - output file (functional groups with taxa names that are associated with different functions): report_16Soak.txt
  
  - Faprotax database: FAPROTAX.txt

