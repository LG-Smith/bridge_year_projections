library(tidyverse)
data <- readRDS(file = "output/catch_proj_data.rds")
`%!in%` <- Negate(`%in%`)

source("R/simple_projection_fnc.R")

stock <- unique(data$STOCK_ID)


for (i in 1:length(stock)) {

  data_stock <- filter(data, STOCK_ID == stock[i])
  fishery_group <- unique(data_stock$FISHERY_GROUP)

  for (j in 1:length(fishery_group)) {

    assign(paste0(stock[i],"_",fishery_group[j]), simple_projection(data = data_stock
                                                                    , stock = stock[i]
                                                                    , fishery_group = fishery_group[j]))


  }

}

#### change plot in function to offset label by some % of ACL

