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
#' @examples 
#' jtrace_check_java()
jtrace_check_java <- function(){
  java_current_version <- system("java -version", intern = TRUE)
  if (is.null(java_current_version)) {
    install <- ui_oops(paste0("Java is not installed. You can download it here: ", ui_path("www.java.com")))
  } else {
    java_version <- as.numeric(substr(regmatches(
      java_current_version[1],
      regexpr("[0-9].*", java_current_version[1])), 1, 3)
    )
    is_valid <- java_version > 1.4
    if (!is_valid){
      install <- ui_oops(
        paste0(
          "Your Java version (", java_version, ") is too old (must be > 1.4).",
          " You can download a more recent version here: ", ui_path("www.java.com")
        )
      )
    }
  }
  return(is_valid)
}


#' Check if jTRACE is installed
#' @export jtrace_is_installed
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @details jTRACe website: \code{https://magnuson.psy.uconn.edu/jtrace/}
#' @importFrom usethis ui_line
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_done
#' @param check Should jTRACE installation be prompted if FALSE?
#' @returns A logical values indicating whether jTRACE has been already installed
#' @examples 
#' jtrace_is_installed()
jtrace_is_installed <- function(check = FALSE){
  exists <- dir.exists(system.file("jtrace", package = "jtracer"))
  if (check && !exists){
    install <- ui_yeah("jTRACE is not installed. Do you want to install jTRACE?")
    if (install){
      jtrace_install(overwrite = TRUE)
    }
  }
  return(exists)
}


#' Download and install jTRACE
#' @export jtrace_install
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_done
#' @param overwrite Logical value indicating whether to replace an existing jTRACE folder, in case there is
#' @param quiet Should downloading progress not be shown?
#' @examples
#' jtrace_install()
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
        ui_done("Removed previous jTRACE folder")
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
    ui_line(
      paste0(
        "Downloading jTRACE from ",
        ui_path("http://magnuson.psy.uconn.edu/wp-content/uploads/sites/1140/2015/01/jtrace-a64.zip")
      )
    )
    download.file(
      url = "http://magnuson.psy.uconn.edu/wp-content/uploads/sites/1140/2015/01/jtrace-a64.zip",
      destfile = temp_path, 
      quiet = quiet
    )
    ui_done("Downloaded successfully")
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
    
    file.copy(
      from = system.file("languages", "default.xml", package = "jtracer"),
      to = file.path(system.file("jtrace", "languages", package = "jtracer"), "default.xml"),
      overwrite = TRUE
    )
    
    ui_done("Installed sucessfully")
  }
  
}

