#' Launches jTRACE
#' @export jtrace_launch
#' @examples 
#' jtrace_launch()
jtrace_launch <- function(){
  jtrace_check_java()
  jtrace_is_installed(check = TRUE)
  command <- paste0("java -jar ", system.file("jtrace", "jtrace.jar", package = "jtracer", mustWork = TRUE))
  system(command, show.output.on.console = FALSE)
}