#' Get jTRACE language
#' @export jtrace_get_language
#' @importFrom XML xmlToDataFrame
#' @importFrom stringr str_extract
#' @importFrom stringr str_split
#' @param language_name Character vector of length 1 indicating the jTRACE language to import
jtrace_get_language <- function(
  language_name = NULL
){
  language_dir <- paste0(.jtrace$PATH, "/languages")
  language_list <- list.files(language_dir, pattern = ".jt") 
  if(is.null(language_name) || !(language_name %in% gsub(".jt", "", language_list))){
    stop(paste0(
      "Please, specify a valid language Available languages are: ",
      paste0(c, collapse = ", "))
    )
  }
  if(length(language_name) > 1) stop("Please, specify just one lexicon")
  language_list <- paste0(language_dir, "/", language_name, ".jt") %>%
    readLines(warn = FALSE) %>% 
    paste0(collapse = "") %>%
    str_split("<phoneme>") %>%
    unlist() %>% 
    as.list()
  language_list[[1]] <- NULL
  
  # symbols
  phonemes <- lapply(language_list, function(x) {
    str_extract(x, "(?<=\\<symbol\\>)(.*)(?=\\<\\/symbol>)") %>% 
      str_split(pattern = " ") %>% 
      unlist() 
  }) %>%
    unlist()
  phonemes <- phonemes[!is.na(phonemes)]
  
  # features
  feature_names <- c("bur","voi", "con", "grd", "dif", "voc", "pow")
  features <- lapply(language_list, function(x) {
    y <- str_extract(x, "(?<=\\<features\\>)(.*)(?=\\<\\/features>)") %>% 
      str_split(pattern = " ") %>% 
      unlist() %>% 
      as.numeric()
    y <- y[!is.na(y)] %>% 
      matrix(data = ., nrow = 9, ncol = 7) %>% 
      as.data.frame()
    colnames(y) <- feature_names
    return(y)
  })
  features <- lapply(features, function(x) apply(X = x, MARGIN = 2, FUN = which.max))
  features <- do.call(rbind, features)
  row.names(features) <- phonemes
  
  # duration scalar
  duration_scalar <- lapply(language_list, function(x) {
    y <- str_extract(x, "(?<=\\<durationScalar\\>)(.*)(?=\\<\\/durationScalar>)") %>% 
      str_split(pattern = " ") %>% 
      unlist() %>% 
      as.numeric()
    y <- y[!is.na(y)] %>% 
      matrix(data = ., nrow = 1, ncol = 7) %>% 
      as.data.frame()
  })
  duration_scalar <- do.call(rbind, duration_scalar)
  row.names(duration_scalar) <- phonemes
  colnames(duration_scalar) <- feature_names

  # allophonic relations
  allophonic_relations <- lapply(language_list, function(x) {
    y <- str_extract(x, "(?<=\\<allophonicRelations\\>)(.*)(?=\\<\\/allophonicRelations>)") %>% 
      str_split(pattern = " ") %>% 
      unlist()
  })
  allophonic_relations <- do.call(rbind, allophonic_relations)
  allophonic_relations <- duration_scalar[!duration_scalar==""]
  allophonic_relations <- duration_scalar=="true"
  allophonic_relations <- array(allophonic_relations, dim = c(length(phonemes), length(phonemes)))
  colnames(allophonic_relations) <- phonemes
  row.names(allophonic_relations) <- phonemes

  # merge everything
  language <- list(
    features = features,
    duration_scalar = duration_scalar,
    allophonic_relations = allophonic_relations
  )
 
  return(language)
}

#' Create jTRACE language (phonemic inventory)
#' @export jtrace_create_language
#' @importFrom tidyr pivot_longer
#' @importFrom tidyr pivot_wider
#' @param features Data frame or matrix with N rows (phonemes) and 9 columns (acoustic features). Acoustic features are in the following order: burst (bur), voicing (voi), consonantal (con), acuteness (grd), diffuseness (dif), vocalic (voc), power (pow). See McClelland & Elman (1986).
#' @param duration_scalar Matrix or data frame indicating the values of the duration scalar, with each phoneme as a row and each feature as a column. If NULL (default), all duration values are set to 1.
#' @param allophonic_relations Array or data frame with logical values indicating whether each combination of phonemes is an allophone, with phonemes are rows and columns. If NULL (default), no allophonic relations are specified.
#' @param phonemes Character vector indicating the jTRACE notation of each phoneme. It must be the same length as the number of rows of the matrix or data frame introduced in \code{features}. This argument can be left NULL (default) if the matrix or data frame introduced in \code{features} has appropriate row names indicaitng the jTRACE notation of the phonemes.
#' @param language_name Name of the language that will be created.
jtrace_create_language <- function(
  features,
  duration_scalar = NULL,
  allophonic_relations = NULL,
  phonemes = NULL,
  language_name
){
  
  # check params
  if (is.null(language_name)) language_name <- readline()
  if (is.null(duration_scalar)) duration_scalar <- matrix(1, nrow = nrow(features), ncol = 7)
  if (is.null(allophonic_relations)) allophonic_relations <- array("false", dim = c(nrow(features), nrow(features)))
  if (is.null(phonemes) & is.null(row.names(features))){
    stop("Phoneme notations must be introduced in the phonemes argument or as row names in the features matrix")
  } else if (is.null(phonemes)) {
    phonemes <- row.names(features)
  }
  
  # headers
  header_1 <- paste0(
    "<?xml version='1.0' encoding='UTF-8'?><phonology xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS file:",
    .jtrace$PATH, "/Schema/jTRACESchema.xsd'>\n"
  )
  tag_name <- paste0("<languageName>", language_name, "</languageName>\n")
  header_2 <- "<phonemes>\n"
  
  # features
  f <- lapply(split.data.frame(features, 1:nrow(features)), t)
  f <- lapply(f, function(y){
    cbind(y, setNames(sapply(1:9, function(x) x = as.numeric(x==y[,1])), 1:9))[,-1]
  })
  f <-  lapply(f, function(x) c(t(x)))
  
  # duration scalar
  d <- lapply(split.data.frame(duration_scalar, 1:nrow(duration_scalar)), t)
  d <-  lapply(d, function(x) c(t(x)))
  
  # allophonic relations
  a <- lapply(split.data.frame(allophonic_relations, 1:nrow(allophonic_relations)), t)
  a <-  lapply(a, function(x) c(t(x)))
  a <- lapply(a, function(x) ifelse(x, "true", "false"))
  
  body <- as.list(phonemes)
  s <- setNames(vector(mode = "list", length = length(phonemes)), phonemes)
  for (i in 1:length(f)){
    s[[i]]$symbol <- as.list(phonemes)[[i]]
    s[[i]]$features <- paste0(f[[i]], ".0")
    s[[i]]$duration_scalar <- paste0(d[[i]], ".0")
    s[[i]]$allophonic_relations <- paste0(a[[i]])
    body[[i]] <- paste0(
      "<phoneme>\n",
      "\t<symbol>", s[[i]]$symbol, "</symbol>\n",
      "\t<features>", paste0(s[[i]]$features, collapse = " "), "</features>\n",
      "\t<durationScalar>", paste0(s[[i]]$duration_scalar, collapse = " "), "</durationScalar>\n",
      "\t<allophonicRelations>", paste0(s[[i]]$allophonic_relations, collapse = " "), "</allophonicRelations>\n",
      "</phoneme>\n",
      collapse = ""
    )
  }
  body <- paste0(unlist(body), collapse = "")
  
  # footer
  footer <- "</phonemes>\n</phonology>"
  
  # merge all
  x <- c(header_1, tag_name, header_2, body, footer)
  
  # output path
  output_path <- file(paste0(.jtrace$PATH, "/languages/", language_name, ".jt"))
  writeLines(text = paste0(x, collapse = ""), con = output_path)
  ui_done(paste0("Language (phonemes) added as ", ui_code(language_name)))
  
}
