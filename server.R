# install libraries if not already installed
renv::restore()

# libraries: httpuv, rmarkdown
library(urltools)
library(stringr)

# FUTURE:
# We should be able to return the params metadata structure via a custom
# HTTP header using something like this:
#   jsonlite::toJSON(rmarkdown::metadata$params, auto_unbox = TRUE)


readFile = function(
  fileName
) {
  invisible(readChar(fileName, file.info(fileName)$size))
}

createServer = function(
  host = '127.0.0.1',
  port = 5001,
  app
) {
  port = as.integer(port)

  server = NULL
  list(
    host = host,
    port = port,
    startServer = function() {
      id = httpuv::startServer(host, port, app)
      server <<- id
      print(paste0('server started on port ',port))
      invisible(id)
    },
    stopServer = function() {
      if (is.null(server)) stop('The server has not been started yet.')
      try(httpuv::stopServer(server))
    }
  )
}

httd = function(...) {
  # httpuv uses Rook-style request handling:
  # https://github.com/jeffreyhorner/Rook
  app <- list(call = function(env){
    if (env$REQUEST_METHOD == "OPTIONS") {
      list(
        status = 200L,
        headers = list(
          'Access-Control-Allow-Origin' =  "*",
          'Access-Control-Allow-Methods' = "GET, POST, PUT, UPDATE, DELETE",
          'Access-Control-Allow-Headers' = "",
          'Cache-Control' = 'max-age=3600',
          'Content-Type' =  "text/html; charset=utf-8"
        ),
        body = ''
      )
    } else if (env$REQUEST_METHOD == "GET") {
      public_root <- "./public"
      base_file_name <- env$PATH_INFO
      returnParams <- FALSE
      if (str_detect(base_file_name, "^/params/")) {
        base_file_name <- str_replace(base_file_name, "^/params", "")
        returnParams <- TRUE
      }

      file_name <- paste(public_root, base_file_name, sep = "")

      if (!file.exists(file_name)) {
        file_name <- paste(public_root, base_file_name, ".Rmd", sep = "")
      }

      if (file.exists(file_name)) {
        if (returnParams) {
          params <- rmarkdown::yaml_front_matter(file_name)$params

          list(
            status = 200L,
            headers = list(
              'Content-Type' = 'application/json',
              'Cache-Control' = 'max-age=3600',
              'Access-Control-Allow-Origin' = '*'
            ),
            body = jsonlite::toJSON(params)
          )

        } else {
          .params <- as.list(param_get(env$QUERY_STRING))

          # render to temp file
          output_file_name <- paste(stringi::stri_rand_strings(1,20),'.html', sep = "")
          rmarkdown::render(file_name, params=.params, output_file=output_file_name)

          # read temp file
          output_file_path <- paste(public_root, output_file_name, sep="/")
          body <- readFile(output_file_path)

          # delete the temp file
          unlink(output_file_path)

          list(
            status = 200L,
            headers = list(
              'Content-Type' = 'text/html',
              'Cache-Control' = 'max-age=3600',
              'Access-Control-Allow-Origin' = '*'
            ),
            body = body
          )
        }
      } else {
        list(
          status = 404L
        )
      }
    }
  })
  server <- createServer(app = app, ...)
  server$startServer()
  invisible(server)
}

try(if (!is.null(.GlobalEnv$runningServer)) {
  .GlobalEnv$runningServer$stopServer()
}, silent=TRUE)

.GlobalEnv$runningServer <- httd()