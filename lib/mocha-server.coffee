express = require 'express'
fs = require 'fs'

server = express()

server.set "view engine", "jade"

server.get "/", (request, response)->
  response.render 'index'

server.get "/mocha.css", (request, response) ->
  css = fs.readFileSync "#{__dirname}/../node_modules/mocha/mocha.css"
  response.type 'text/css'
  response.send(200, css)

server.get "/mocha.js", (request, response) ->
  js = fs.readFileSync "#{__dirname}/../node_modules/mocha/mocha.js"
  response.type 'text/javascript'
  response.send(200, js)

server.listen 8888, ->
  console.log 'Tests available at http://localhost:8888'
