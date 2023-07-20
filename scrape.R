library(rvest)
if(!dir.exists("data")) dir.create("data")

slugify_date <- function(x){
  x <- stringi::stri_replace_all_regex(x,"[^\\P{P}-]","")
  x <- gsub(x, pattern = " ", replacement = "-")
  x
}

start_time <- slugify_date(Sys.time())

targets <- state.abb

targets <- targets[!targets %in% c("AK", "FL")]

url1 <- sprintf("https://www.cdc.gov/surveillance/nrevss/images/rsvstate/RSV1PPCent3AVG_State%s.htm",targets)
url2 <- sprintf("https://www.cdc.gov/surveillance/nrevss/images/rsvstate/RSV4PPCent3AVG_State%s.htm",targets)
url3 <- sprintf("https://www.cdc.gov/surveillance/nrevss/images/rsvstate/RSV14NumCent5AVG_State%s.htm",targets)

pull_down_data <- function(x){
    Sys.sleep(rpois(1,3))
    d <- session(x)
    o <- html_table(d)[[1]]
    return(o)
}

table1 <- lapply(url1, pull_down_data)

table1_combined <- do.call(rbind, table1)

table1_combined[,1] <- NULL

names(table1_combined) <- c("week", "state", "percent_positive", "total_antigen_detection_tests")

table1_combined$week <- as.Date(table1_combined$week, "%Y-%m-%d")

table1_combined$update_dts <- start_time

# table 2------------------------------------------

table2 <- lapply(url2, pull_down_data)

table2_combined <- do.call(rbind, table2)

table2_combined[,1] <- NULL

names(table2_combined) <- c("week", "state", "percent_positive", "total_pcr_tests")

#table2_combined$week <- as.Date(table2_combined$week, "%m/%d/%y")

table2_combined$week <- as.Date(table2_combined$week, "%Y-%m-%d")

table2_combined$update_dts <- start_time

# third table ------------------------------------------

table3 <- lapply(url3, pull_down_data)

table3_combined <- do.call(rbind, table3)

table3_combined[,1] <- NULL

names(table3_combined) <- c("week", "state", "antigen_detections", "pcr_detections")

table3_combined$week <- as.Date(table3_combined$week, "%m/%d/%y")

table3_combined$update_dts <- start_time

data.table::fwrite(table1_combined, here::here("data", sprintf("%s-3wk-antigen.csv", start_time)))
data.table::fwrite(table2_combined, here::here("data", sprintf("%s-5wk-pcr.csv", start_time)))
data.table::fwrite(table3_combined, here::here("data", sprintf("%s-3wk-combined.csv", start_time)))
