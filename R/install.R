#' to be 1.4 or higher. This function checks if Java installed, and if the current
#' version is recent enough for Java to run. If not, you will be pointed to the Java
#' website where you can download the most recent version of Java. After installing it, you will
#' be able to install and launch jTRACE.
#' @export jtrace_check_java
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_oops
#' @importFrom usethis ui_path
#' @importFrom usethis ui_done
jtrace_check_java <- function(){
  java_current_version <- system("java -version", intern = TRUE)
  if (is.null(java_current_version)) {
    install <- ui_oops(paste0(
      "Java is not installed. You can download it here: ",
      ui_path("www.java.com")
    ))
  } else {
    java_version <- as.numeric(substr(regmatches(
      java_current_version[1],
      regexpr("[0-9].*", java_current_version[1])), 1, 3)
    )
    is_valid <- java_version > 1.4
    if (!is_valid){
      install <- ui_yeah(
        paste0(
          "Your Java version (", java_version, ") is too old (must be > 1.4).",
          " You can download a more recent version here: ", ui_path("www.java.com")
        )
      )
    } else {
      ui_done(
        paste0("Java (", java_version, ") is up and running!")
      )
    }
  }
}


#' Check if jTRACE is installed
#' @export jtrace_is_installed
#' @importFrom usethis ui_line
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_done
jtrace_is_installed <- function(){
  path <- set_jtrace_path()
  exists <- dir.exists(path)
  return(exists)
}

#' Set jRTACE path
#' @export set_jtrace_path
#' @importFrom usethis ui_line
#' @param path Character string indicating the path in which to install jTRACE
set_jtrace_path <- function(
  path = NULL
){
  if(is.null(path)) path <- file.path(Sys.getenv("HOME"), ".jtracer", fsep = "\\")
  ui_line(paste0("jtrace path has been set at ", ui_path(x = path)))
  .jtrace$PATH <- path
}

#' Download and install jTRACE
#' @export jtrace_install
#' @importFrom usethis ui_yeah
#' @importFrom usethis ui_done
#' @param path Character string indicating the path in which to install jTRACE
#' @param overwrite Logical value indicating whether to replace an existing jTRACE folder, in case there is
jtrace_install <- function(
  path = NULL,
  overwrite = NULL
){
  
  set_jtrace_path(path)
  # get path
  if(is.null(path)) path <- file.path(Sys.getenv("HOME"), ".jtracer", fsep = "\\")
  jtrace_check_java()
  
  # check if folder exists
  if (dir.exists(path)){
    # if exists, ask if re-install
    if (is.null(overwrite) || !overwrite){
      overwrite <- ui_yeah(".jtrace already exists. Do you want to re-install it?")
      install <- overwrite
      if (install){
        unlink(path, recursive = TRUE, force = TRUE)
        ui_done("Removed previous jTRACE folder")
      } 
    }
  } else {
    install <- TRUE
  }
  
  # download and unzip
  if (install){
    ui_line(paste0("jtrace will be installed in ", ui_path(x = path)))
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
      quiet = TRUE
    )
    ui_done("Downloaded successfully")
    unzip(
      zipfile = temp_path,
      exdir = path,
      overwrite = TRUE
    )
    mid_dir <- list.dirs(path, full.names = TRUE, recursive = FALSE)
    internal_files <- list.files(mid_dir, include.dirs = TRUE, full.names = TRUE, recursive = TRUE)
    suppressWarnings(file.rename(internal_files, gsub("\\/jtrace-a64", "", internal_files)))
    unlink(mid_dir, recursive = FALSE, force = TRUE)
    dir.create(path = paste0(path, "/languages"), showWarnings = FALSE)
    
    # change .jt to .xml
    file_names <- list.files(paste0(.jtrace$PATH, "/lexicons"), recursive = TRUE)
    file_names_new <- gsub(".jt", ".xml", file_names)
    file_paths <- list.files(paste0(.jtrace$PATH, "/lexicons"), recursive = TRUE, full.names = TRUE)
    for (i in 1:length(file_paths)){
      invisible(
        suppressWarnings(
          file.rename(from = file_paths[i], to = paste0(.jtrace$PATH, "/lexicons/", file_names_new[i]))
        )
      )
    }
    ui_done("Installed sucessfully")
  }
  
}
