# RStudio Background Jobs

[RStudio 1.2](https://www.rstudio.com/products/rstudio/) introduced the ability
to send long-running R scripts to [local and remote background
jobs](https://blog.rstudio.com/2019/03/14/rstudio-1-2-jobs/). This functionality
can dramatically improve the productivity of data scientists and analysts using
R since they can continue working in an unblocked R session in RStudio while
jobs are running in the background. Local background jobs are supported by all
versions of RStudio, server and desktop. Remote background jobs are a feature of
[RStudio Server Pro](https://www.rstudio.com/products/rstudio-server-pro/) and
are orchestrated by the [RStudio Job
Launcher](https://docs.rstudio.com/job-launcher/), which also supports running
interactive R sessions on remote resource managers like
[Kubernetes](https://kubernetes.io).

## Resources
### :eyes: [Slides from Webinar (2019-08-07)](slides.pdf)
### :computer: [Code Examples](https://github.com/sol-eng/background-jobs)

