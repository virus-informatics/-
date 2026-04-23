library(tidyverse)
library(stats)
library(base)
library(circlize)
library(ComplexHeatmap)
library(data.table)
library(datasets)
library(grDevices)
library(patchwork)
library(RColorBrewer)
library(cmdstanr)

args = commandArgs(trailingOnly=T)

set_cmdstan_path("/home/kaho/Applications/cmdstan-2.34.1") 
cmdstan_path()

########## args ##########
#Change when using new input
out_prefix <- "2024_12_28" #out_prefix <- args[1]
download_date <- gsub("_", "-", out_prefix)
date_w_space <- gsub("_", "", out_prefix)

##YURINCHI
metadata.name <- paste("/Users/okumurakaho/Downloads/nextstrain_ncov_open_global_all-time_metadata.tsv",sep = "")
country.info.name <- paste("/Users/okumurakaho/Downloads/2604_vm_lecture/country_info.txt",sep = "")
dir <- paste("/Users/okumurakaho/Downloads/2604_vm_lecture")
setwd(dir)

##period to be analyzed
date.start <- as.Date("2026-03-31")
date.end <- as.Date("2025-10-01")

#read input country info
country.info <- read.table(country.info.name,header=T,sep="\t",quote="")
country.info <- country.info %>% select(-region)

#read input metadata
metadata <- fread(metadata.name,header=T,sep="\t",quote="",check.names=T)

#filtering
metadata.filtered <- metadata %>%
  distinct(strain,.keep_all=T) %>%
  filter(host == "Homo sapiens",
         str_length(date) == 10,
         pango_lineage != "",
         pango_lineage != "None",
         pango_lineage != "?")


#converting an object to a date
metadata.filtered <- metadata.filtered %>%
  mutate(date = as.Date(date))

# #merge country name and country info
# metadata.filtered <- merge(metadata.filtered,country.info,by="country")
# metadata.filtered <- metadata.filtered %>% mutate(region_analyzed = ifelse(country %in% country.interest.v,
#                                                                           as.character(country),
#                                                                           as.character(sub_region)))

#region of interest
region.interest <- "USA"
#filter region
metadata.filtered <- metadata.filtered %>% filter(country == region.interest)

#filter the period of analysis
metadata.filtered.analyzed <- metadata.filtered %>% filter(date >= date.start, date <= date.end)

#write output
write.table(metadata.filtered.analyzed.region,"input/metadata_filtered_USA_230701_231130.txt",col.names=T,row.names=F,sep="\t",quote=F)
