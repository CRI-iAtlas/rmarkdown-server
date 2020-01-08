# RMarkdown Server

WARNING: This is a proof of concept only. It is not ready for production.

A simple HTTP server written in R that serves up parameterized RMarkdown files. The key difference compared to services like http://rpubs.com is the RMarkdown files are re-rendered with each unique set of parameter-values passed in the query string.

Any Rmd file in `./public` can be served. Parameters are expressed in standard RMarkdown metadata. Read more about RMarkdown params here: https://bookdown.org/yihui/rmarkdown/.

The server translates any query-params passed in the URL to the RMarkdown file via the rmarkdown::render() params argument.

# Setup

Make sure you have R installed. RStudio is not strictly required, but we'll assume you are using it:

- R: [https://www.r-project.org/](https://www.r-project.org/) - v3.6.2

- RStudio: [https://rstudio.com/products/rstudio/download/](https://rstudio.com/products/rstudio/download/)

Git-clone this repository and then open rmarkdown-server.RProj. Install the required packages by executing this in the RSudio console:

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

# API

## `/` Get Rendered RMarkdown File with Params

Get a rendered rmarkdown file:

* http://localhost:5001/leaflet.Rmd

The .Rmd extension is optional:

* http://localhost:5001/leaflet

Pass params in the query string:

* http://localhost:5001/leaflet.Rmd?tiles=mono
* http://localhost:5001/leaflet.Rmd?tiles=normal


## `/params/` Get Params Metadata for RMarkdown File

Precede the path with `/params/` to get a JSON object directly derived from the `params` property in the Rmarkdown file's metadata:

* http://localhost:5001/params/leaflet.Rmd

leaflet.Rmd metadata:

```yaml
title: Leaflet Demo
output: html_document
params:
  tiles:
    label: "Tiles"
    value: "normal"
    input: "select"
    choices:
      - "normal"
      - "monochrome"
```

/params/leaflet.Rmd output:

```json
{
  "tiles": {
    "label": [
      "Tiles"
    ],
    "value": [
      "normal"
    ],
    "input": [
      "select"
    ],
    "choices": [
      "normal",
      "monochrome"
    ]
  }
}
```

The .Rmd extension is optional:

* http://localhost:5001/params/leaflet


# Production TODO

Currently a url could have "/../" in the path and give access outside `public/`.