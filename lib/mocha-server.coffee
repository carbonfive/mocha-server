express = require 'express'

server = express()

server.set "view engine", "jade"

server.get "/", (request, response)->
  response.send(200, "woot woot")

server.listen 8888, ->
  console.log 'Tests available at http://localhost:8888'
