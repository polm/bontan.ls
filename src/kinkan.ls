#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url

{render-summary, render-tweet, fix-encoding} = require \./shared

main = ->
  url = process.argv.2
  domain = URL.parse(url).host
  # some urls need to be treated differently
  #if special-handler domain, url
  #  return
  request {url: url, encoding: null}, (error, response, body) ->
    if error
      console.error error
      process.exit 1
    body = fix-encoding response, body
    win = domino.create-window body
    win.url = url
    render-summary win, domain

main!
