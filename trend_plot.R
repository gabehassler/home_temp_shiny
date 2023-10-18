library(ggplot2)
library(readr)
library(stringr)
library(data.table)




get_log_paths <- function(dir) {
  matched <- str_match(list.files(dir), date_regex)
  df = data.frame(file= file.path(dir, matched[, 1]), date = parse_date(matched[, 2]))
  df = na.omit(df)
  df = df[order(df$date), ]
}

get_data_day <- function(dt) {
  dt = as.character(dt)
  if (is.null(DATASETS[[dt]])) {
    path = LOG_PATHS$file[LOG_PATHS$date == dt]
    cat(paste0("reading ", path, " ..."))
    cat(" done\n")
    DATASETS[[dt]] = fread(path)
  }
  DATASETS <<- DATASETS
  DATASETS[[dt]]
}


get_logs <- function(
                     min_date = parse_date("1900-01-01"), 
                     max_date = parse_date("2100-01-01")) {
  
  df = LOG_PATHS
  df = df[df$date >= min_date & df$date <= max_date, ]
  print(df)
  dfs = lapply(df$date, get_data_day)
  df_all = rbindlist(dfs)
  df_all$datetime = Reduce(c, lapply(df_all$datetime, function(dt) {
    attr(dt, "tzone") <- "America/Los_Angeles"
    dt
  }))
  df_all
}

plot_temp <- function(min_date, max_date, is_farenheit = TRUE) {
  print(min_date)
  print(max_date)
  # 
  # df = read_csv('/data/solar/power_temp_2023-10-14.csv',
  #               col_types = cols(datetime_column = col_datetime(format = "%Y-%m-%d %H:%M:%OS6")))
  df = get_logs(min_date = min_date, max_date = max_date)
  if (is_farenheit) {
    df$temp = convert_to_farenheit(df$temp)
  }
  ggplot(df, aes(x = datetime, y = temp)) + geom_point(size=0.1)
}

convert_to_farenheit <- function(t) {
  t * (9 / 5) + 32
}

get_current_temp <- function(is_farenheit = TRUE) {
  LOG_PATHS <<- get_log_paths(DATA_DIR)
  df = get_data_day(LOG_PATHS$date[nrow(LOG_PATHS)])
  n = nrow(df)
  temp = df$temp[n]
  dt = df$datetime[n]
  attr(dt, "tzone") <- "America/Los_Angeles"
  
  if (is_farenheit) temp = convert_to_farenheit(temp)
  list(time = dt, temp = temp)
}

LOG_PATHS = get_log_paths(DATA_DIR)

DATASETS = list()

date_regex <- regex("power_temp_(\\d{4}-\\d{2}-\\d{2}).csv")

DATA_DIR = "/data/solar"

# plot_temp()
# x = get_logs("/data/solar")
# print(x)

