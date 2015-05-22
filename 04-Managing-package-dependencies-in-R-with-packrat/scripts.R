# Initialize a Packrat project -- whether it's a completely new, fresh project
# or one that you've already been working on for some time...
packrat::init()

# Snapshot the project (save the current state of the private library)
packrat::snapshot()

# Restore the last snapshot (discard any unsaved changes in your private library)
packrat::restore()

# Temporarily step out of packrat mode with...
packrat::off()

# Step back into packrat mode with...
packrat::on()

# Set up a local repository, and install a package from it.
# Local repositories -- a folder of R package sources.
# Suppose I have the package sources for `data.table`, `pryr` in
# the folder `~/git`...
packrat::opts$local.repos("~/git")
packrat::install_local("pryr")
packrat::install_local("data.table")

# Using external, or user library, packages when within
# a Packrat project...
packrat::opts$external.packages(c("devtools"))
library(devtools) # loads devtools from the user / system library!

# Going from nothing (clean R session) to a restored Packrat project --
# Packrat will do this for you automatically! Details on the logistics:
#
# 1. Packrat projects have a '.Rprofile' file, which contains code that should
#    be run when the R session is started. It is this functionality that places
#    us in Packrat mode.
#
# 2. That same code understands how to re-install Packrat (the version specified
#    in the Packrat lockfile), without any other external dependencies.
#
# So, if you start from a fresh R installation and want to restore a Packrat
# project -- just launch R in that directory!
