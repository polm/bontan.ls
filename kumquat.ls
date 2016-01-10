#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url

{render-summary, render-tweet} = require \./shared

main = ->
  url = process.argv.2
  domain = URL.parse(url).host
  request url, (error, response, body) ->
    if error
      console.error error
      process.exit 1
    win = domino.create-window body
    render-summary win
