# create a new environment
.jtrace <- new.env(parent = emptyenv())
.jtrace$PATH <- NULL
set_jtrace_path()
