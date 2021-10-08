#' Check if Java is installed
#' @export jtrace_check_java
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @details jTRACE requires Java 1.4 or higher. This function checks if Java installed, and if the current
#' version is recent enough for Java to run. If not, you will be pointed to the Java
#' website where you can download the most recent version of Java. After installing it, you will 
#' be able to install and launch jTRACE.
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_oops
#' @importFrom usethis ui_path
#' @importFrom usethis ui_done
#' @returns TRUE if Java is installed and version is 1.4 or higher, FALSE otherwise
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
jtrace_check_java <- function(){
  java_current_version <- system("java -version", intern = TRUE)
  if (is.null(java_current_version)) {
    is_valid <- FALSE
  } else {
    java_version <- as.numeric(substr(regmatches(
      java_current_version[1],
      regexpr("[0-9].*", java_current_version[1])), 1, 3)
    )
    is_valid <- java_version > 1.4
  }
  return(is_valid)
}


#' Check if jTRACE is installed
#' @export jtrace_is_installed
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @details jTRACe website: \code{https://magnuson.psy.uconn.edu/jtrace/}
#' @returns A logical values indicating whether jTRACE has been already installed
#' @examples 
#' jtrace_is_installed()
jtrace_is_installed <- function(){
  exists <- dir.exists(system.file("jtrace", package = "jtracer"))
  return(exists)
}


#' Download and install jTRACE
#' @export jtrace_install
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @param overwrite Logical value indicating whether to replace an existing jTRACE folder, in case there is
#' @param quiet Should downloading progress not be shown?
jtrace_install <- function(
  overwrite = NULL,
  quiet = FALSE
){
  
  jtrace_check_java()
  
  # get path
  path <- file.path(system.file(package = "jtracer", mustWork = TRUE), "jtrace")
  
  # check if folder exists
  if (dir.exists(path)){
    # if exists, ask if re-install
    if (is.null(overwrite)){
      overwrite <- ui_yeah("jTRACE is already installed. Do you want to re-install it?")
      install <- overwrite
      if (install){
        unlink(path, recursive = TRUE, force = TRUE)
      } 
    } else if (!overwrite){
      install <- FALSE
    } else {
      install <- TRUE
    }
  } else {
    install <- TRUE
  }
  
  # download and unzip
  if (install){
    temp_path <- paste0(tempfile(), ".zip")
    download.file(
      url = "http://magnuson.psy.uconn.edu/wp-content/uploads/sites/1140/2015/01/jtrace-a64.zip",
      destfile = temp_path, 
      quiet = quiet
    )
    unzip(zipfile = temp_path, exdir = path, overwrite = TRUE)
    mid_dir <- list.dirs(path, full.names = TRUE, recursive = FALSE)
    internal_files <- list.files(mid_dir, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
    suppressWarnings(file.rename(internal_files, gsub("\\/jtrace-a64", "", internal_files)))
    unlink(mid_dir, recursive = FALSE, force = TRUE)
    
    # change .jt to .xml
    file_names <- list.files(system.file("jtrace", package = "jtracer", mustWork = TRUE), recursive = TRUE)
    file_names_new <- gsub(".jt", ".xml", file_names)
    file_paths <- list.files(system.file("jtrace", package = "jtracer", mustWork = TRUE), recursive = TRUE, full.names = TRUE)
    for (i in 1:length(file_paths)){
      suppressWarnings({
        file.rename(
          from = file_paths[i],
          to = file.path(system.file("jtrace", package = "jtracer"), file.path(file_names_new[i]))
        )
      })
    }
    
    # move custom languages to jTRACE folder
    dir.create(path = file.path(system.file("jtrace", package = "jtracer", mustWork = TRUE), "languages"), showWarnings = FALSE)
    language_paths <- list.files(system.file("languages", package = "jtracer"), pattern = ".xml", full.names = TRUE)
    language_names <- list.files(system.file("languages", package = "jtracer"), pattern = ".xml", full.names = FALSE)
    
    for (i in 1:length(language_paths)) {
      file.copy(
        from = language_paths[i],
        to = file.path(system.file("jtrace", "languages", package = "jtracer"), language_names[i]),
        overwrite = TRUE
      )
    }
    
    # move custom languages
    custom_languages <- list.files(file.path(system.file("languages", package = "jtracer")))
    for (i in custom_languages){
      file.copy(
        from = system.file("languages", i, package = "jtracer"),
        to = file.path(system.file("jtrace", "languages", package = "jtracer"), i),
        overwrite = TRUE
      )
    }
    # move custom lexicons
    custom_lexicons <- list.files(file.path(system.file("lexicons", package = "jtracer")))
    for (i in custom_lexicons){
      file.copy(
        from = system.file("lexicons", i, package = "jtracer"),
        to = file.path(system.file("jtrace", "lexicons", package = "jtracer"), i),
        overwrite = TRUE
      )
    }
  }
}


#' Launches jTRACE
#' @export jtrace_launch
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' \donttest{jtrace_launch()}
jtrace_launch <- function(){
  is_installed_java <- jtrace_check_java()
  if (!is_installed_java) stop("Java is not installed or need to be upgraded")  
  
  is_installed <- jtrace_is_installed()
  if (!is_installed) stop("jTRACE is not installed, please run jtrace_install()")
  command <- paste0("java -jar ", system.file("jtrace", "jtrace.jar", package = "jtracer", mustWork = TRUE))
  system(command, show.output.on.console = FALSE)
}
