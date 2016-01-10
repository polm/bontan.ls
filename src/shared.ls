#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url

export get-printer = (opts) ->
  if opts.0 == \-r # raw output
    return -> console.log it.innerHTML
  return -> console.log it.textContent.trim!

export render-all = (win) ->
  nodes = win.document.query-selector-all "H1, H3, P, IMG, LI"
  for node in nodes
    console.log switch node.tag-name
    | \H1 => '# ' + node.text-content + "\n"
    | \H3 => '### ' + node.text-content + "\n"
    | \IMG => node.src + "\n"
    | \LI => node.text-content
    | \P => node.text-content + "\n"
    default => node.text-content

export render-summary = (win) ->
  console.log win.document.title
  nodes = win.document.query-selector-all "H1, P, IMG"
  # good stuff is always after first H1
  while nodes.0 and nodes.0.tag-name != \H1
    nodes.shift!
  if nodes.length == 0 then return
  nodes.shift!
  if nodes.length == 0 then return
  imgs = nodes.filter -> it.tag-name == \IMG
  if imgs.length > 0
    # TODO don't print tiny images
    console.log imgs.0.src
  ps = nodes.filter -> it.tag-name == \P
  if ps.length > 0
    console.log ps.0.text-content

export render-tweet = (win) ->
  console.log win.document.query-selector(\p.TweetTextSize)?text-content

