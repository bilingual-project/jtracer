is_installed <- jtrace_is_installed()
if (!is_installed) ui_oops(paste0("jTRACE is not installed. Please, run ", ui_code("jtrace_install()")))
