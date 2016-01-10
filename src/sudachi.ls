#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url
{get-printer} = require \./shared

print = get-printer process.argv[2 to]

[url, sel] = process.argv[-2 to]
domain = URL.parse(url).host
request url, (error, response, body) ->
  if error
    console.error error
    process.exit 1
  win = domino.create-window body
  nodes = win.document.query-selector-all sel
  for node in nodes
    print node
