#' Open jTRACE
#' @export jtrace
jtrace <- function(){
  jtrace_check_java()
  command <- paste0("java -jar ", .jtrace$PATH, "/jtrace.jar")
  system(command, show.output.on.console = FALSE)
}