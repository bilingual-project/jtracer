#' Open jTRACE
#' @export jtrace_launch
jtrace_launch <- function(){
  jtrace_check_java()
  installed <- jtrace_is_installed()
  if (!installed){
    install <- ui_yeah("jTRACE is not installed. Do you want to install it?")
    if (install) jtrace_install()
  }
  command <- paste0("java -jar ", .jtrace$PATH, "/jtrace.jar")
  system(command, show.output.on.console = FALSE)
}