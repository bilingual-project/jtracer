#' Launches jTRACE
#' @export jtrace_launch
#' @author Gonzalo Garcia-Castro <gonzalo.garciadecastro@upf.edu>
#' @references Strauss, T. J., Harris, H. D., & Magnuson, J. S. (2007). jTRACE: A reimplementation and extension of the TRACE model of speech perception and spoken word recognition. Behavior Research Methods, 39(1), 19-30.
#' @examples
#' jtrace_launch()
jtrace_launch <- function(){
  jtrace_check_java()
  jtrace_is_installed(check = TRUE)
  command <- paste0("java -jar ", system.file("jtrace", "jtrace.jar", package = "jtracer", mustWork = TRUE))
  system(command, show.output.on.console = FALSE)
}