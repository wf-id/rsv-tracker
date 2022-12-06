
library(data.table)

data.table::rbindlist(lapply(fs::dir_ls("data", glob = "*5wk-pcr.csv"), data.table::fread))->combined


data.table::setorderv(combined, c("state", "week"))

combined[,update_dts := as.Date(substr(update_dts,1,10))]

combined_latest <- combined[order(state, week)][,.SD[tail(1)], by = c("week", "state")]

fwrite(combined_latest, here::here("output", "rsv_5wk_pcr_latest.csv"))


combined_combined <- data.table::rbindlist(lapply(fs::dir_ls("data", glob = "*3wk-combined.csv"), data.table::fread))


data.table::setorderv(combined_combined, c("state", "week"))

combined_combined[,update_dts := as.Date(substr(update_dts,1,10))]

combined_combined <- combined_combined[order(state, week)][,.SD[tail(1)], by = c("week", "state")]


combined_combined_all <- merge(combined, combined_combined)

fwrite(combined_combined_all, here::here("output", "rsv_all_combined_latest.csv"))