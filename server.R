# libraries: httpuv, rmarkdown
library(urltools)

# FUTURE:
# We should be able to return the params metadata structure via a custom
# HTTP header using something like this:
#   jsonlite::toJSON(rmarkdown::metadata$params, auto_unbox = TRUE)

httd = function(...) {
  # httpuv uses Rook-style request handling:
  # https://github.com/jeffreyhorner/Rook
  app <- list(call = function(env){
    public_root <- "./public"
    file_name <- paste(public_root, env$PATH_INFO, sep = "")
    if (!file.exists(file_name)) {
      file_name <- paste(public_root, env$PATH_INFO, ".Rmd", sep = "")
    }
    if (file.exists(file_name)) {
      .params <- as.list(param_get(env$QUERY_STRING))
      
      # render to temp file
      output_file_name <- paste(stringi::stri_rand_strings(1,20),'.html', sep = "")
      rmarkdown::render(file_name, params=.params, output_file=output_file_name)
      
      # read temp file
      output_file_path <- paste(public_root, output_file_name, sep="/")
      body <- readFile(output_file_path)
      
      # delete the temp file
      unlink(output_file_path)
      
      params <- rmarkdown::yaml_front_matter(file_name)$params
      
      list(
        status = 200L,
        headers = list(
          'Content-Type' = 'text/html',
          'Cache-Control' = 'max-age=3600',
          'x-rmarkdown-params' = jsonlite::toJSON(params)
        ),
        body = body
      )
    } else {
      list(
        status = 404L
      )
    }
  })
  server <- createServer(app = app, ...)
  server$startServer()
  invisible(server)
}

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
if (!is.null(.GlobalEnv$runningServer)) {
  .GlobalEnv$runningServer$stopServer()
}

runningServer <- httd()