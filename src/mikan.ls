#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url

url = process.argv.2
domain = URL.parse(url).host
request url, (error, response, body) ->
  if error
    console.error error
    process.exit 1
  win = domino.create-window body
  nodes = win.document.get-elements-by-tag-name \*
  maxkids = win.document.body
  for node in nodes
    if node.children?.length > maxkids.children.length
      maxkids = node

  # maxkids is the list top, now get children
  # find most common number of children
  grandcounts = {0: 0}
  commoncount = 0
  for kid in maxkids.children
    if not kid.children.length then continue
    if not grandcounts[kid.children.length]
      grandcounts[kid.children.length] = 0
    grandcounts[kid.children.length]++
    if grandcounts[kid.children.length] > grandcounts[commoncount]
      commoncount = kid.children.length

  for kid in maxkids.children
    if kid.children.length = commoncount
      console.log kid.text-content.split("\n").map(-> it.trim!).join(' ')

