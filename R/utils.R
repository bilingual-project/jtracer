# utils

#' @importFrom tidyr drop_na
#' @importFrom httr GET
#' @importFrom httr write_disk
#' @importFrom readxl read_excel
#' @importFrom data.table fread
#' @importFrom janitor clean_names
import_subtlex <- function(){
  
  # english
  subtlex_eng_raw <- fread("http://crr.ugent.be/papers/SUBTLEX-UK.txt", verbose = FALSE, showProgress = FALSE) 
  subtlex_eng <- clean_names(subtlex_eng_raw)
  subtlex_eng <- subtlex_eng[subtlex_eng$spelling != "", c("spelling", "freq_count", "log_freq_zipf")]
  subtlex_eng$freq_million <- subtlex_eng$freq_count/length(unique(subtlex_eng$spelling)) 
  subtlex_eng <- subtlex_eng[, c("spelling", "freq_count", "freq_million", "log_freq_zipf")]
  colnames(subtlex_eng) <- c("word", "frequency_abs", "frequency_rel", "frequency_zipf")
  
  # spanish
  tf <- tempfile(fileext = "zip")
  GET("http://crr.ugent.be/papers/SUBTLEX-ESP.zip", write_disk(tf, overwrite = TRUE))
  subtlex_spa <- clean_names(read_excel(unzip(tf)))
  subtlex_spa <- subtlex_spa[, colnames(subtlex_spa)[grepl("word_|freq_count_|freq_per_", colnames(subtlex_spa))]]
  colnames(subtlex_spa) <- gsub("_count_", "_abs_", colnames(subtlex_spa))
  colnames(subtlex_spa) <- gsub("_per_million_", "_rel_", colnames(subtlex_spa))
  subtlex_spa <- drop_na(subtlex_spa)
  colnames(subtlex_spa) <- paste(rep(c("word", "frequency_abs", "frequency_rel"), times = 3), rep(1:3, each = 3), sep = "_")
  subtlex_spa <- bind_rows(
    rename_all(select(subtlex_spa, ends_with("_1")), function(x) gsub("_1", "", x)),
    rename_all(select(subtlex_spa, ends_with("_2")), function(x) gsub("_2", "", x)),
    rename_all(select(subtlex_spa, ends_with("_3")), function(x) gsub("_3", "", x)),
  ) 
  subtlex_spa$frequency_zipf <- log10(subtlex_spa$frequency_rel)+3
  
  # catalan
  tf <- tempfile(fileext = "xlsx")
  GET("https://psico.fcep.urv.cat/projectes/gip/papers/SUBTLEX-CAT.xlsx", write_disk(tf))
  subtlex_cat <- clean_names(read_excel(tf, .name_repair = "check_unique"))
  subtlex_cat <- subtlex_cat[, c("words", "abs_wf", "abs_wf", "zipf")]
  colnames(subtlex_cat) <- c("word", "frequency_abs", "frequency_rel", "frequency_zipf")

  # merge
  frequency <- bind_rows(list(English = subtlex_eng, Spanish = subtlex_spa, Catalan = subtlex_cat), .id = "language")
  frequency <- frequency[frequency$word %in% word, c("word", "language", "frequency_abs", "frequency_rel", "frequency_zipf")] 
  frequency <- arrange(frequency, language, word, -frequency_zipf)

  return(frequency)
  
}
