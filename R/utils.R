# utils

#' @importFrom rlang .data
#' @importFrom tidyr drop_na
#' @importFrom tibble as_tibble
#' @importFrom httr GET
#' @importFrom data.table fread
#' @importFrom janitor clean_names
import_subtlex <- function(){
  
  # english
  subtlex_eng_raw <- fread("http://crr.ugent.be/papers/SUBTLEX-UK.txt", verbose = FALSE, showProgress = FALSE) 
  subtlex_eng <- subtlex_eng_raw %>% 
    as_tibble() %>% 
    clean_names() %>% 
    filter(spelling!="") %>% 
    drop_na(spelling) %>% 
    select(spelling, freq_count, log_freq_zipf) %>% 
    mutate(freq_million = freq_count/length(unique(spelling))) %>% 
    select(word = spelling, frequency_abs = freq_count, frequency_rel = freq_million, frequency_zipf = log_freq_zipf)

  # spanish
  tf <- tempfile(fileext = "zip")
  GET("http://crr.ugent.be/papers/SUBTLEX-ESP.zip", write_disk(tf, overwrite = TRUE))
  subtlex_spa <- read_excel(unzip(tf)) %>% 
    clean_names() %>% 
    select(starts_with("word_"), starts_with("freq_count_"), starts_with("freq_per_")) %>% 
    rename_at(vars(starts_with("freq_count_")), function(x) gsub("_counts", "_abs", x)) %>% 
    rename_at(vars(starts_with("freq_per_")), function(x) gsub("_per_million", "_rel", x)) %>% 
    drop_na()
  colnames(subtlex_spa) <- paste(rep(c("word", "frequency_abs", "frequency_rel"), each = 3), 1:3, sep = "_")
  subtlex_spa <- bind_rows(
    rename_all(select(subtlex_spa, ends_with("_1")), function(x) gsub("_1", "", x)),
    rename_all(select(subtlex_spa, ends_with("_2")), function(x) gsub("_2", "", x)),
    rename_all(select(subtlex_spa, ends_with("_3")), function(x) gsub("_3", "", x)),
  ) 
  colnames(subtlex_spa) <- c("word", "frequency_abs", "frequency_rel")
  subtlex_spa$frequency_zipf <- log10(subtlex_spa$frequency_rel)+3
  
  # catalan
  tf <- tempfile(fileext = "xlsx")
  GET("https://psico.fcep.urv.cat/projectes/gip/papers/SUBTLEX-CAT.xlsx", write_disk(tf))
  subtlex_cat <- read_excel(tf, .name_repair = "check_unique") %>% 
    clean_names() %>% 
    select(word = words, frequency_abs = abs_wf, frequency_rel = rel_wf, frequency_zipf = zipf)
  
  # merge
  frequency <- list(English = subtlex_eng, Spanish = subtlex_spa, Catalan = subtlex_cat) %>% 
    bind_rows(.id = "language") %>% 
    select(word, language, frequency_abs, frequency_rel, frequency_zipf) %>% 
    filter(.data$word %in% word) %>%
    arrange(language, word, -frequency_zipf)

  return(frequency)
  
}
