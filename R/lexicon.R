#' Get jTRACE lexicon
#' @export jtrace_get_lexicon
#' @importFrom XML xmlToDataFrame
#' @param lexicon Character vector of length 1 indicating the jTRACE lexicon to import
jtrace_get_lexicon <- function(
  lexicon = NULL
){
  lexicon_dir <- paste0(.jtrace$PATH, "/lexicons")
  lexicon_list <- list.files(lexicon_dir, pattern = ".jt") 
  if(is.null(lexicon) || !(lexicon %in% lexicon_list)){
    stop(paste0("Please, specify a valid lexicon. Available lexica are: ", paste0(lexicon_list, collapse = ", ")))
  }
  if(length(lexicon) > 1) stop("Please, specify just one lexicon")
  lexicon <- xmlToDataFrame(paste0(lexicon_dir, "/", lexicon))
  return(lexicon)
}


#' Create jTRACE lexicon
#' @export jtrace_create_lexicon
#' @importFrom readr write_lines
#' @param phonology Character vector with the phonological transcription of the word forms
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
  
  output_path <- paste0(.jtrace$PATH, "/lexicons/", lexicon_name, ".jt")
  write_lines(c(header, body, footer), file = output_path)
  ui_done(paste0("Lexicon added as ", ui_code(lexicon_name)))
}
