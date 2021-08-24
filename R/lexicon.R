#' Get jTRACE lexicon
#' @export jtrace_get_lexicon
#' @return A data frame with the contents of the retrieved jTRACE lexicon.
#' This data frame will always contain a column for word forms (\code{phonology}).
#' Sometimes, it will also contain another column for lexical frequencies (\code{frquency}), 
#' depending on the information provided in that file in the jTRACE original implementation.
#' @importFrom XML xmlToDataFrame
#' @param lexicon Character vector of length 1 indicating the jTRACE lexicon to import
jtrace_get_lexicon <- function(
  lexicon = NULL
){
  lexicon_dir <- paste0(.jtrace$PATH, "/lexicons")
  lexicon_list <- gsub(".xml", "", list.files(lexicon_dir, pattern = ".xml"))
  if(is.null(lexicon) || !(lexicon %in% lexicon_list)){
    stop(paste0("Please, specify a valid lexicon. Available lexica are: ", paste0(lexicon_list, collapse = ", ")))
  }
  if(length(lexicon) > 1) stop("Please, specify just one lexicon")
  lexicon <- xmlToDataFrame(paste0(lexicon_dir, "/", lexicon, ".xml"))
  return(lexicon)
}


#' Create jTRACE lexicon
#' @export jtrace_create_lexicon
#' @importFrom readr write_lines
#' @importFrom usethis ui_done
#' @param phonology Character vector with the jTRACE phonological transcription of the word forms
#' @param frequency Numeric vector with the lexical frequencies of the word forms
#' @param lexicon_name Character string indicating the name of the lexicon that will be generated
jtrace_create_lexicon <- function(
  phonology,
  frequency,
  lexicon_name
){
  header <- "<?xml version='1.0' encoding='UTF-8'?>\n<lexicon xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS file:/Ted/develop/cvs/sswr/code/WebTrace/Schema/WebTraceSchema.xsd'>"
  body <- paste0(
    "<lexeme><phonology>",
    phonology,
    "</phonology><frequency>",
    frequency,
    "</frequency></lexeme>"
  )
  footer <- "</lexicon>"
  
  output_path <- paste0(.jtrace$PATH, "/lexicons/", lexicon_name, ".xml")
  write_lines(c(header, body, footer), file = output_path)
  ui_done(paste0("Lexicon added as ", ui_code(lexicon_name)))
}

#' Extract lexical frequencies
#' @export jtrace_get_frequency
#' @import dplyr
#' @importFrom rlang .data
#' @importFrom usethis ui_done
#' @importFrom readxl read_xlsx
#' @importFrom tibble as_tibble
#' @param word Character vector with the orthographic word form
#' @param language Character vector containing the language(s) to lookup the frequency of the words for. Must be one or more of "English", "Spanish, and/or "Catalan".
#' @param scale Character vector indicating the scale(s) of the frequency scores. Must be one or more of "frequency_abs" (absolute frequency), "frequency_rel", (relative frequency, \code{counts/1e6}, default), or "frequency_zipf" (\code{log10(counts*1e6)+3})"
#' @returns A data frame containing a column for the words and one column for the SUBTLEX frequencies in each language for the same word
jtrace_get_frequency <- function(
  word,
  language = "English",
  scale = "frequency_rel"
){
  suppressMessages({
    if (!all(language %in% c("Spanish", "Catalan", "English"))) stop("Language must be English, Spanish, and/or Catalan")
    if (!all(scale %in% c("frequency_abs", "frequency_rel", "frequency_zipf"))) stop("Scale must be one of frequency_abs, frequency_rel, and/or frequency_zipf")
    f <- frequency[frequency$word %in% word & frequency$language %in% language, c("word", "language", scale)]
    x <- left_join(data.frame(word = word, language = language), f) %>% 
      mutate_at(vars(starts_with("frequency_")), function(x) ifelse(is.na(x), 0, x)) %>% 
      as_tibble()
  })
  return(x)
}


