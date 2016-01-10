#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url
{render-all, render-tweet} = require \./shared

main = ->
  url = process.argv.2
  domain = URL.parse(url).host
  request url, (error, response, body) ->
    if error
      console.error error
      process.exit 1
    win = domino.create-window body
    switch domain
    | \twitter.com => render-tweet win
    default => render-all win

main!
