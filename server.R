library(httpuv)
library(rmarkdown)
library(urltools)
httd = function(...) {
  # httpuv uses Rook-style request handling:
  # https://github.com/jeffreyhorner/Rook
  app <- list(call = function(env){
    .params <- as.list(param_get(env$QUERY_STRING))
    rmarkdown::render('example.Rmd', params=.params)
    body = readFile('example.html')
    list(
      status = 200L,
      headers = list(
        'Content-Type' = 'text/html'
      ),
      body = body
    )
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
      id = startServer(host, port, app)
      server <<- id
      print(paste0('server started on port ',port))
      invisible(id)
    },
    stopServer = function() {
      if (is.null(server)) stop('The server has not been started yet.')
      stopServer(server)
    }
  )
}
