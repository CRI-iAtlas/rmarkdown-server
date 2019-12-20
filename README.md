# RMarkdown Server

A simple HTTP server written in R that serves up parameterized RMarkdown files. They key difference compared to services like http://rpubs.com/ is the RMarkdown files are re-rendered with each unique set or parameter values passed in the query string.

Any Rmd file in `./public` can be served. Parameters are expressed in standard RMarkdown metadata (https://bookdown.org/yihui/rmarkdown/).

# Setup

Make sure you have R installed. RStudio is not strictly required, but we'll assume you are using it:

- R: [https://www.r-project.org/](https://www.r-project.org/) - v3.6.2

- RStudio: [https://rstudio.com/products/rstudio/download/](https://rstudio.com/products/rstudio/download/)

Git-clone this repository and then open rmarkdown-server.RProj.

Then install the required packages by executing this in the RSudio console:

```R
renv::restore()
```

# Start, Stop, Restart the Server

start or restart server:
```
source('./server.R')
```

stop server:
```
.GlobalEnv$runningServer$stopServer()
```

# Example

With the server running, open:

* http://localhost:5001/leaflet.Rmd?tiles=mono
* http://localhost:5001/leaflet.Rmd?tiles=normal

The .Rmd extension is optional:

* http://localhost:5001/leaflet
