# utils

#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom tidyr drop_na
#' @importFrom httr GET
#' @importFrom httr write_disk
#' @importFrom readxl read_excel
#' @importFrom data.table fread
#' @importFrom janitor clean_names
#' @importFrom utils data
#' @references
#' \describe{
#'     \item{English}{Van Heuven, W. J., Mandera, P., Keuleers, E., & Brysbaert, M. (2014). SUBTLEX-UK: A new and improved word frequency database for British English. Quarterly journal of experimental psychology, 67(6), 1176-1190.}
#'     \item{Spanish}{Cuetos, F., Glez-Nosti, M., Barbon, A., & Brysbaert, M. (2011). SUBTLEX-ESP: frecuencias de las palabras espanolas basadas en los subtitulos de las peliculas. Psicológica, 32(2), 133-144.}
#'     \item{Catalan}{Boada, R., Guasch, M., Haro, J., Demestre, J., & Ferré, P. (2020). SUBTLEX-CAT: Subtitle word frequencies and contextual diversity for Catalan. Behavior research methods, 52(1), 360-375.}
#' }
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
  
  # to avoid issues with bindings in CMD CHECK
  .new_env <- new.env(parent = emptyenv())
  data("frequencies", envir = .new_env)
  frequencies <- .new_env[["frequencies"]]
  
  # merge
  x <- bind_rows(list(English = subtlex_eng, Spanish = subtlex_spa, Catalan = subtlex_cat), .id = "language")
  x <- frequencies[x$word %in% word, c("word", "language", "frequency_abs", "frequency_rel", "frequency_zipf")] 
  x <- arrange(x, language, word, -frequency_zipf)
  
  return(x)
  
}

#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom utils data
#' @importFrom utils write.table
#' @importFrom rlang .env
export_phonemes <- function(...){
  # to avoid issues with bindings in CMD CHECK
  .new_env <- new.env(parent = emptyenv())
  data("phonemes", envir = .new_env)
  phonemes <- .new_env[["phonemes"]]  
  
  write.table(.env$phonemes, ..., row.names = FALSE)
}


#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom googlesheets4 range_read
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#' @importFrom dplyr select
import_phonemes <- function(){
  # get phonemes from Google spreadsheet and process them
  google_id <- "1iAK2zF84MqFwdLj-_CpWVC1O2xxmYDztc0Qe_2Sy0ww"
  
  suppressMessages({
    phonemes <- clean_names(range_read(ss = google_id, sheet = "(Serene coding)")) %>% 
      mutate(
        description = tolower(ifelse(type=="Consonant", paste(voicing, place, manner), paste(height, backness, roundedness))),
        bur = as.numeric(gsub("-", "0", bur))
      ) %>% 
      select(id = listing, ipa, trace = j_trace, description, is_english, is_spanish, is_catalan, type, pow, voc, dif, acu, con, voi, bur)
  })
  return(phonemes)
}




