#!/usr/bin/env lsc
request = require \request
domino = require \domino
URL = require \url
{filter} = require \prelude-ls

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
  summary = scrape-summary win
  # summary should have keys {title, description, image}
  #TODO: support html output
  for key in <[ title image description ]>
    if summary[key]
      console.log summary[key]

scrape-summary = (win) ->
  res = get-twitter-or-facebook-meta win
  if res then return res
  #TODO: oembed
  # mostly dead, but seems popular with newspapers maybe?
  # Much more annoying than twitter/open graph
  #TODO: special cases
  #- individual tweets
  #- wikipedia
  #
  #- ???
  return  default-summary-scrape win

default-summary-scrape = (win) ->
  # lacking more sophisticated methods, try this
  res = {}
  res.title win.document.title
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
    res.image = imgs.0.src
  ps = nodes.filter -> it.tag-name == \P
  if ps.length > 0
    res.description = ps.0.text-content

export render-tweet = (win) ->
  console.log win.document.query-selector(\p.TweetTextSize)?text-content

get-twitter-or-facebook-meta = (win) ->
  # twitter = twitter cards, which fall back to Facebook Open Graph
  # Twitter Card spec:
  # https://dev.twitter.com/cards/markup
  # Open graph:
  # http://ogp.me/

  # first declare some tools here to keep scope clean
  core-prop = (win, p) ->
    # for some reason some sites have multiple meta tags with the same property
    # worse, the values aren't the same - some are empty
    # Example as of 2015-01-28: BoingBoing
    win.document.query-selector-all("meta[property=\"#p\"]") |>
      filter (-> it.attributes.content?.value?.length > 0) |>
      -> it.0?.attributes.content.value

  prop = (win, p) ->
    # this is a wrapper that tries first for Twitter then for Open Graph tags
    core-prop(win, "twitter:#p") or core-prop(win, "og:#p")

  # first try for a title; if none, assume the other tags aren't there
  get-prop = -> prop win, it
  res = {}
  res.title = get-prop \title
  if not res.title then return null # probably not supported
  res.description = get-prop \description
  res.image = get-prop \image
  # there are some other attributes but they don't seem very useful
  return res

