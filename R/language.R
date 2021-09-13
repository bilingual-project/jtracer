
#' List jTRACE available languages
#' @export jtrace_list_languages
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @returns A character vector listing the available languages in the jTRACE folder
#' @seealso \code{\link{jtrace_get_language}} for importing a language, and \code{\link{jtrace_create_language}} for creating a new language.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' jtrace_list_languages()
jtrace_list_languages <- function(){
  jtrace_is_installed(check = TRUE)
  dir_path <- file.path(system.file("jtrace", package = "jtracer", mustWork = TRUE), "languages")
  x <- gsub(".xml", "", list.files(dir_path, pattern = ".xml"))
  return(x)
}

#' Get jTRACE language
#' @export jtrace_get_language
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom rlang .data
#' @importFrom stats setNames
#' @importFrom utils download.file
#' @importFrom utils unzip
#' @importFrom XML xmlToDataFrame
#' @importFrom stringr str_extract
#' @importFrom usethis ui_path
#' @seealso \code{\link{jtrace_list_languages}} for listing available languages, and \code{\link{jtrace_create_language}} for creating a new language.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @param language_name Character vector of length 1 indicating the jTRACE language to import. Defaults to "default".
#' @return A list of data frames containing a data frame for the phonemes and their
#'  scores across the seven features implemented in jTRACE (\code{features}),
#'  a data frame containing the duration scalars of each phoneme for the even features
#'  implemented in jTRACE (\code{duration_scalar}), and a data frame containing the
#'  allophonic relations between the phonemes (\code{allophonic_relations}).
#'  @examples 
#'  jtrace_get_language("default")
jtrace_get_language <- function(
  language_name = "default"
){
  jtrace_is_installed(check = TRUE)
  
  suppressWarnings({
    
    language_list <- jtrace_list_languages()
    if (length(language_list)<1) stop("There are no languages available")
    if (is.null(language_name) || !(language_name %in% gsub(".xml", "", language_list))){
      stop(paste0("Please, specify a valid language. Available languages are: ", paste0(language_list, collapse = ", ")))
    }
    if(length(language_name) > 1) stop("Please, specify just one lexicon")
    language_list <- paste0(system.file("jtrace", "languages", package = "jtracer", mustWork = TRUE), .Platform$file.sep, language_name, ".xml") %>%
      readLines(warn = FALSE) %>% 
      paste0(collapse = "") %>% 
      strsplit(split = "<phoneme>") %>%
      unlist() %>% 
      as.list()
    language_list[[1]] <- NULL
    
    # symbols
    phonemes <- lapply(language_list, function(x) {
      str_extract(x, "(?<=\\<symbol\\>)(.*)(?=\\<\\/symbol>)") %>% 
        strsplit(split = " ") %>% 
        unlist() 
    }) %>%
      unlist()
    phonemes <- phonemes[!is.na(phonemes)]
    
    # features
    feature_names <- c("bur","voi", "con", "grd", "dif", "voc", "pow")
    features <- lapply(language_list, function(x) {
      y <- str_extract(x, "(?<=\\<features\\>)(.*)(?=\\<\\/features>)") %>% 
        strsplit(split = " ") %>% 
        unlist() %>% 
        as.numeric()
      y <- as.data.frame(matrix(data = y[!is.na(y)], nrow = 9, ncol = 7))
      colnames(y) <- feature_names
      return(y)
    })
    features <- lapply(features, function(x) apply(X = x, MARGIN = 2, FUN = which.max))
    features <- do.call(rbind, features)
    row.names(features) <- phonemes
    
    # duration scalar
    duration_scalar <- lapply(language_list, function(x) {
      y <- str_extract(x, "(?<=\\<durationScalar\\>)(.*)(?=\\<\\/durationScalar>)") %>% 
        strsplit(split = " ") %>% 
        unlist() %>% 
        as.numeric()
      y <- as.data.frame(matrix(data = y[!is.na(y)], nrow = 1, ncol = 7))
    })
    duration_scalar <- do.call(rbind, duration_scalar)
    row.names(duration_scalar) <- phonemes
    colnames(duration_scalar) <- feature_names
    
    # allophonic relations
    allophonic_relations <- lapply(language_list, function(x) {
      y <- str_extract(x, "(?<=\\<allophonicRelations\\>)(.*)(?=\\<\\/allophonicRelations>)") %>% 
        strsplit(split = " ") %>% 
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
    
  })
  
  return(language)
}

#' Create jTRACE language (phonemic inventory)
#' @export jtrace_create_language
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom tidyr pivot_longer
#' @importFrom tidyr pivot_wider
#' @importFrom usethis ui_done
#' @importFrom usethis ui_code
#' @seealso \code{\link{jtrace_list_languages}} for listing available languages, and \code{\link{jtrace_get_language}} for importing a language.
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @param phonemes Character vector indicating the jTRACE notation of each phoneme. It must be the same length as the number of rows of the matrix or data frame introduced in \code{features}. This argument can be left NULL (default) if the matrix or data frame introduced in \code{features} has appropriate row names indicating the jTRACE notation of the phonemes.
#' @param features A M x N matrix or data frame (where M is the number of phonemes and N is 7, the number of features) that contains the values of the features (columns) for each phoneme (rows) with a score ranging from 0 to 9.
#' @param duration_scalar Matrix or data frame indicating the values of the duration scalar, with each phoneme as a row and each feature as a column. If NULL (default), all duration values are set to 1.
#' @param allophonic_relations Array or data frame with logical values indicating whether each combination of phonemes is an allophone, with phonemes are rows and columns. If NULL (default), no allophonic relations are specified.
#' @param language_name Name of the language that will be created.
#' @examples 
#' # first, we create a character vector with the phoneme symbols
#' p <- c("-", "a", "s", "d", "f", "g", "c") 
#' # then we create a the features matrix
#' f <- data.frame(
#'     bur = c(9, 6, 4, 3, 1, 1, 2),
#'     voi = c(7, 4, 3, 3, 3, 3, 4),
#'     con = c(8, 2, 4, 2, 5, 5, 6),
#'     grd = c(4, 6, 1, 4, 6, 8, 6),
#'     dif = c(6, 3, 2, 6, 6, 6, 7),
#'     voc = c(3, 8, 1, 6, 6, 7, 4),
#'     pow = c(6, 4, 1, 6, 1, 1, 5)
#' )
#' # now we create the language
#' jtrace_create_language(language_name = "my_language", phonemes = p, features = f)
jtrace_create_language <- function(
  phonemes = NULL,
  features,
  duration_scalar = NULL,
  allophonic_relations = NULL,
  language_name
){
  jtrace_is_installed(check = TRUE)
  # check params
  if (is.null(language_name)) language_name <- readline()
  if (is.null(duration_scalar)) duration_scalar <- matrix(1, nrow = nrow(features), ncol = 7)
  if (is.null(allophonic_relations)) allophonic_relations <- array("false", dim = c(nrow(features), nrow(features)))
  if (is.null(phonemes) & is.null(row.names(features))) {
    stop("Phoneme notations must be introduced in the phonemes argument or as row names in the features matrix")
  } else if (is.null(phonemes)) {
    phonemes <- row.names(features)
  }
  if (any(duplicated(phonemes))) {
    stop("Phonemes cannot be duplicated. Hint: sometimes, special characters are encoded into normal ones, leading to duplications.")
  }
  
  # headers
  header_1 <- paste0(
    "<?xml version='1.0' encoding='UTF-8'?><phonology xmlns='http://xml.netbeans.org/examples/targetNS'\nxmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'\nxsi:schemaLocation='http://xml.netbeans.org/examples/targetNS file:",
    system.file("jtrace", package = "jtracer"), "/Schema/jTRACESchema.xsd'>\n"
  )
  tag_name <- paste0("<languageName>", language_name, "</languageName>\n")
  header_2 <- "<phonemes>\n"
  
  # features
  f <- lapply(split.data.frame(features, 1:nrow(features)), t)
  f <- lapply(f, function(y){
    cbind(y, setNames(sapply(1:9, function(x) x = as.numeric(x==y[,1])), 1:9))[,-1]
  })
  f <- lapply(f, function(x) c(t(x)))
  
  # duration scalar
  d <- lapply(split.data.frame(duration_scalar, 1:nrow(duration_scalar)), t)
  d <- lapply(d, function(x) c(t(x)))
  
  # allophonic relations
  a <- lapply(split.data.frame(allophonic_relations, 1:nrow(allophonic_relations)), t)
  a <- lapply(a, function(x) c(t(x)))
  a <- lapply(a, function(x) ifelse(x, "true", "false"))
  
  body <- as.list(phonemes)
  s <- setNames(vector(mode = "list", length = length(phonemes)), phonemes)
  for (i in 1:length(f)){
    s[[i]]$symbol <- as.list(phonemes)[[i]]
    s[[i]]$features <- paste0(f[[i]], ".0")
    s[[i]]$duration_scalar <- ifelse(d[[i]] %in% c(0, 1), paste0(d[[i]], ".0"), d[[i]])
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
  output_path <- paste0(system.file("jtrace", "languages", package = "jtracer", mustWork = TRUE), .Platform$file.sep, language_name, ".xml")
  writeLines(text = paste0(x, collapse = ""), con = output_path)
  ui_done(paste0("Language added at ", ui_path(output_path)))
  
}


#' Transcribe phonology from IPA to jTRACE notation
#' @export ipa_to_jtrace
#' @importFrom mgsub mgsub
#' @param x A character vector with the phonological forms to be transcribed
#' @param keep_other Should symbols other than phonemes be kept in the
#' transcriptions? Defaults to FALSE
#' @details 1) If \code{keep_other}, special characters (symbols that do not 
#' correspond to phonemes in the \code{phonemes} data set, such as apostrophes 
#' or dots) are removed. 2) Colons (:) are replaced with the previous symbol, 
#' since they are interpreted as a modifier of the duration of the previous 
#' phoneme. 3) Pairwise replacements are performed according to the 
#' \code{phonemes} data set.
#' @return A character vector with the jTRACE transcriptions of the provided
#' phonological forms
ipa_to_jtrace <- function(
  x,
  keep_other = FALSE
){
  data(phonemes)
  if (!keep_other) x <- gsub("͡| |\\.|ˈ|'|\\\\|/", "", x)
  x <- lapply(
    as.list(x),
    function(y){
      y_split <- unlist(strsplit(y, split = ""))
      if (any(grepl(":|ː", y))){
        y_split[grep(":|ː", y_split)] <- y_split[grep(":|ː", y_split)-1]
      }
      y_collapsed <- paste0(y_split, collapse = "")
      y_collapsed <- mgsub(y_collapsed, phonemes$ipa, phonemes$trace)
      return(y_collapsed)
    }
  )
  x <- unlist(x)
  return(x)
}

