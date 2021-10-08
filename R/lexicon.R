#' List jTRACE available lexicons
#' @export jtrace_list_lexicons
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @returns A character vector listing the available lexicons in the jTRACE folder
#' @seealso \code{\link{jtrace_get_lexicon}} for importing a lexicon, and \code{\link{jtrace_create_language}} for creating a new lexicon.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' \dontrun{jtrace_list_lexicons()}
jtrace_list_lexicons <- function(){
  is_installed <- jtrace_is_installed()
  if (!is_installed) stop("jTRACE is not installed, please run jtrace_install()")
  
  dir_path <- system.file("jtrace", "lexicons", package = "jtracer", mustWork = TRUE)
  x <- gsub(".xml", "", list.files(dir_path, pattern = ".xml"))
  return(x)
}

#' Get jTRACE lexicon
#' @export jtrace_get_lexicon
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom XML xmlToDataFrame
#' @param lexicon Character vector of length 1 indicating the jTRACE lexicon to import
#' @returns A data frame with the contents of the retrieved jTRACE lexicon.
#' This data frame will always contain a column for word forms (\code{phonology}).
#' Sometimes, it will also contain another column for lexical frequencies (\code{frequency}), 
#' depending on the information provided in that file in the jTRACE original implementation.
#' @seealso \code{\link{jtrace_list_lexicons}} for listing available lexicons, and \code{\link{jtrace_create_language}} for creating a new lexicon.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' \dontrun{jtrace_get_lexicon("sevenlex")}
jtrace_get_lexicon <- function(
  lexicon = NULL
){
  is_installed <- jtrace_is_installed()
  if (!is_installed) stop("jTRACE is not installed, please run jtrace_install()")
  
  lexicon_list <- jtrace_list_lexicons()
  if (length(lexicon_list)<1) stop("There are no lexicons available")
  if(is.null(lexicon) || !(lexicon %in% lexicon_list)){
    stop(paste0("Please, specify a valid lexicon. Available lexicons are: ", paste0(lexicon_list, collapse = ", ")))
  }
  if(length(lexicon) > 1) stop("Only one lexicon can be specified")
  lexicon <- xmlToDataFrame(paste0(system.file("jtrace", "lexicons", package = "jtracer", mustWork = TRUE), .Platform$file.sep, lexicon, ".xml"))
  if(is.null(lexicon$frequency)) lexicon$frequency <- NA
  lexicon$frequency <- as.numeric(lexicon$frequency)
  return(lexicon)
}


#' Create jTRACE lexicon
#' @export jtrace_create_lexicon
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom readr write_lines
#' @param phonology Character vector with the jTRACE phonological transcription of the word forms
#' @param frequency Numeric vector with the lexical frequencies of the word forms
#' @param lexicon_name Character string indicating the name of the lexicon that will be generated
#' @seealso \code{\link{jtrace_list_lexicons}} for listing available lexicons, and \code{\link{jtrace_get_lexicon}} for importing a lexicon.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' \dontrun{
#' my_phons <- c("plEIn", "kEIk", "taIɡ@", "ham", "sit")
#' my_freqs <- c(0.0483, 0.0804, 0.0288, 0.0282, 0.0767)
#' jtrace_create_lexicon(phonology = my_phons, frequency = my_freqs, lexicon_name = "my_lex")
#' }
jtrace_create_lexicon <- function(
  phonology,
  frequency,
  lexicon_name
){
  is_installed <- jtrace_is_installed()
  if (!is_installed) stop("jTRACE is not installed, please run jtrace_install()")
  
  header <- "<?xml version='1.0' encoding='UTF-8'?>\n<lexicon xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS file:/Ted/develop/cvs/sswr/code/WebTrace/Schema/WebTraceSchema.xsd'>"
  body <- paste0("<lexeme><phonology>", phonology, "</phonology><frequency>", frequency, "</frequency></lexeme>")
  footer <- "</lexicon>"
  output_path <- paste0(system.file("jtrace", "lexicons", package = "jtracer", mustWork = TRUE), .Platform$file.sep, lexicon_name, ".xml")
  # write_lines(c(header, body, footer), file = output_path)
}

#' Extract lexical frequencies
#' @export jtrace_get_frequency
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @import dplyr
#' @importFrom utils data
#' @importFrom rlang .env
#' @importFrom usethis ui_done
#' @importFrom readxl read_xlsx
#' @param word Character vector with the orthographic word form
#' @param language Character vector containing the language(s) to lookup the frequency of the words for. Must be one or more of "English", "Spanish, and/or "Catalan".
#' @param scale Character vector indicating the scale(s) of the frequency scores. Must be one or more of "frequency_abs" (absolute frequency), "frequency_rel", (relative frequency, \code{counts/1e6}, default), or "frequency_zipf" (\code{log10(counts*1e6)+3})"
#' @returns A data frame containing a column for the words and one column for the SUBTLEX frequencies in each language for the same word
#' @references
#' \describe{
#'     \item{English}{Van Heuven, W. J., Mandera, P., Keuleers, E., & Brysbaert, M. (2014). SUBTLEX-UK: A new and improved word frequency database for British English. Quarterly journal of experimental psychology, 67(6), 1176-1190.}
#'     \item{Spanish}{Cuetos, F., Glez-Nosti, M., Barbon, A., & Brysbaert, M. (2011). SUBTLEX-ESP: frecuencias de las palabras espanolas basadas en los subtitulos de las peliculas. Psicológica, 32(2), 133-144.}
#'     \item{Catalan}{Boada, R., Guasch, M., Haro, J., Demestre, J., & Ferré, P. (2020). SUBTLEX-CAT: Subtitle word frequencies and contextual diversity for Catalan. Behavior research methods, 52(1), 360-375.}
#' }
#' @examples 
#' \dontrun{
#' my_words <- c("plane", "cake", "tiger", "ham", "seat")
#' jtrace_get_frequency(word = my_words, language = "English", scale = "frequency_abs")
#' jtrace_get_frequency(word = my_words, language = c("Spanish", "Catalan"), scale = "frequency_zipf")
#' jtrace_get_frequency(word = my_words, language = c("Spanish"), scale = "frequency_rel")
#' }S
jtrace_get_frequency <- function(
  word,
  language = "English",
  scale = "frequency_abs"
){
  
  # to avoid issues with bindings in CMD CHECK
  .new_env <- new.env(parent = emptyenv())
  data("frequencies", envir = .new_env)
  frequencies <- .new_env[["frequencies"]]

    suppressMessages({
    if (!all(language %in% c("Spanish", "Catalan", "English"))) stop("Language must be English, Spanish, and/or Catalan")
    if (!all(scale %in% c("frequency_abs", "frequency_rel", "frequency_zipf"))) stop("Scale must be one of frequency_abs, frequency_rel, and/or frequency_zipf")
    f <- frequencies[frequencies$word %in% word & frequencies$language %in% language, c("word", "language", scale)]
    a <- expand.grid(word = word, language = language)
    x <- left_join(a, f)
    x <- mutate_at(x, vars(starts_with("frequency_")), function(x) ifelse(is.na(x), 0, x))
  })
  return(x)
}


