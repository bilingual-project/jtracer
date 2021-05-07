#' Create jTRACE language (phonemic inventory)
#' @export get_jtrace_language
#' @importFrom tidyr pivot_longer
#' @importFrom tidyr pivot_wider
#' @param phonemes Character vector of length N with the phonemes to be implemented (in jTRACE notation)
#' @param features Data frame or matrix with N rows (phonemes) and 9 columns (acoustic features). Acoustic features are in the following order: burst (bur), voicing (voi), consonantal (con), acuteness (grd), diffuseness (dif), vocalic (voc), power (pow). See McClelland & Elman (1986).
#' @param language_name Name of the language that will be created
get_jtrace_language <- function(
  phonemes,
  features,
  language_name = NULL,
  output_path = NULL
){
  
  # headers
  header <- paste0(
    "<?xml version='1.0' encoding='UTF-8'?><phonology xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS file:",
    .jtrace$PATH, "/Schema/jTRACESchema.xsd'>\n"
  )
  
  tag_name <- paste0("<languageName>", language_name, "</languageName>\n")
  header_2 <- "<phonemes>\n"

  
  body <- as.list(phonemes)
  # features as vectors
  f_list <- lapply(split.data.frame(features, 1:nrow(features)), t)
  f_wide <- lapply(f_list, function(d){
    cbind(d, setNames(sapply(1:9, function(x) x = as.numeric(x==d[,1])), 1:9))[,-1]
  })
  f <-  lapply(f_wide, function(x) c(t(x)))
  
  
  body <- setNames(vector(mode = "list", length = length(phonemes)), phonemes)
  body$phonemes <- phonemes
  body <- mapply(function(x, y) x[["symbol"]] <- y, body, as.list(phonemes), SIMPLIFY = FALSE)
  body <- mapply(function(x, y) x[["features"]] <- y, body, f, SIMPLIFY = FALSE)
  
  bodybody <- lapply(body, function(x) x[["symbol"]] <- phonemes)
  body <- lapply(body, function(x) x[["features"]] <- f)
  
  # durations
  list(
    
  )
  

}
