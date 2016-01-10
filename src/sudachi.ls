#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url

# by default print just the text content
print = -> console.log it.textContent.trim!

# optionally print raw html
if process.argv.2 == \-r
  process.argv.shift!
  print = -> console.log it.innerHTML

url = process.argv.2
sel = process.argv.3
domain = URL.parse(url).host
request url, (error, response, body) ->
  if error
    console.error error
    process.exit 1
  win = domino.create-window body
  nodes = win.document.query-selector-all sel
  for node in nodes
    print node
