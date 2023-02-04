library(sf)
library(cancensus)
library(tidyverse)

options(cancensus.api_key = "CensusMapper_ec721325d8f0b73622eb6a175f8de05a")
set_cancensus_cache_path(paste0(here::here(),"\\cache"))


# https://www12.statcan.gc.ca/census-recensement/2021/ref/dict/fig/index-eng.cfm?ID=F1_1
# https://www12.statcan.gc.ca/census-recensement/2021/ref/98-304/2021001/chap11-eng.cfm

#rm(boundaries21cma)
#unique(query21da$CMA_UID)

query21cma<-get_census(dataset='CA21',
                      regions= list(CMA=unique(query21da$CMA_UID)[c(1,3:153)]),
                      vector=query,
                      level="CMA",
                      use_cache = T)

query21csd<-get_census(dataset='CA21',
                      regions= list(CSD=unique(query21da$CSD_UID)),
                      vector=query,
                      level="CSD",
                      use_cache = T)

query21ct<-get_census(dataset='CA21',
                      regions= list(CT=unique(query21da$CT_UID)),
                      vector=query,
                      level="CT",
                      use_cache = T)

query21cd<-get_census(dataset='CA21',
                      regions= list(CT=unique(query21da$CD_UID)),
                      vector=query,
                      level="CD",
                      use_cache = T)


# Changing colnames names ----------------------------------------------------------


# Creating a function -----------------------------------------------------
#tail(colnames(query21csd))
#tail(sub(":.*", "", colnames(query21csd)),n=48)  

code_abvt<-data.frame(code=query,abbrvtn=nombres)

col_format<-function(x){
  code_abvt
  target<-tail(sub(":.*", "", colnames(x)),n=48)  
  code_rplcmnt<-code_abvt[match(target,code_abvt$code),]
  print(code_rplcmnt$code==target)
  code_rplcmnt$code
  a<-ncol(x)-48
  b<-a+48
  colnames(x)[a+1:b]<-code_rplcmnt$abbrvtn
  x
  return(x)
}

query21cd_form<-col_format(query21cd)
query21csd_form<-col_format(query21csd)
query21cma_form<-col_format(query21cma)
query21ct_form<-col_format(query21ct)
query21da_form<-col_format(query21da)


# Saving data -------------------------------------------------------------

#Raw Data

write.csv(query21cd,"output/rawdata/csv/query21cd.csv")
write.csv(query21csd,"output/rawdata/csv/query21csd.csv")
write.csv(query21cma,"output/rawdata/csv/query21cma.csv")
write.csv(query21ct,"output/rawdata/csv/query21ct.csv")
write.csv(query21da,"output/rawdata/csv/query21da.csv")

writexl::write_xlsx(query21cd,"output/rawdata/xlsx/query21cd.xlsx")
writexl::write_xlsx(query21csd,"output/rawdata/xlsx/query21csd.xlsx")
writexl::write_xlsx(query21cma,"output/rawdata/xlsx/query21cma.xlsx")
writexl::write_xlsx(query21ct,"output/rawdata/xlsx/query21ct.xlsx")
writexl::write_xlsx(query21da,"output/rawdata/xlsx/query21da.xlsx")


# Formated data

write.csv(query21cd_form,"output/formated/csv/query21cd_form.csv")
write.csv(query21csd_form,"output/formated/csv/query21csd_form.csv")
write.csv(query21cma_form,"output/formated/csv/query21cma_form.csv")
write.csv(query21ct_form,"output/formated/csv/query21ct_form.csv")
write.csv(query21da_form,"output/formated/csv/query21da_form.csv")

writexl::write_xlsx(query21cd_form,"output/formated/xlsx/query21cd_form.xlsx")
writexl::write_xlsx(query21csd_form,"output/formated/xlsx/query21csd_form.xlsx")
writexl::write_xlsx(query21cma_form,"output/formated/xlsx/query21cma_form.xlsx")
writexl::write_xlsx(query21ct_form,"output/formated/xlsx/query21ct_form.xlsx")
writexl::write_xlsx(query21da_form,"output/formated/xlsx/query21da_form.xlsx")

