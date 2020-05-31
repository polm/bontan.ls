#!/usr/bin/env lsc
#
# Shared functions for the various scrapers, including OEmbed and Open Graph
# handling.

request = require \request
domino = require \domino
URL = require \url
{filter} = require \prelude-ls
oembed = require \./oembed
iconv = require(\iconv).Iconv

export fix-encoding = (res, body) ->
  # check headers first
  charset = res.headers['content-type']?.split('charset=')?.1?.to-lower-case!
  if charset == \utf-8 or not charset
    return body # ok as is... hopefully
  # check body
  charset = body.to-string!.match(/charset=[-_A-z]*/).0?.split("=").1?to-lower-case!
  if !charset or charset == \utf-8
    return body
  iconv(charset, \utf-8//translit//ignore).convert(body).to-string!

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

# Ideally this would be broken up by domain and handle the common cases 
# that don't support oembed or open graph
export special-summary = (domain, url) ->
  if domain == \en.wikipedia.org
    pagename = url.split(\/)[*-1]
    api-url = ("https://en.wikipedia.org/w/api.php?" +
            "format=json&action=query&prop=extracts&" +
            "titles=" + pagename)
    request api-url, (error, response, body) ->
      if error
        console.error error
        process.exit 1
      data = JSON.parse(body).query.pages
      for key of pages # should be just one
        console.log jk

export render-summary = (win,domain=null) ->
  # summary should have keys {title, description, image}
  #TODO: support html output
  /*
  for key in <[ title image description ]>
    if summary[key]
      console.log summary[key]
  */
  scrape-summary win, domain, (summary) ->
    if summary.html
      console.log summary.html
      return
    out = "<div class=\"summary\">"
    if summary.image
      out += "<div class=\"imgwrapper\"  style=\"background: url(#{summary.image})\"></div>"
    out += "<h2><a href=\"#{win.url}\">#{summary.title}</a></h2>"
    out += "<p>#{summary.description}</p>"
    out += "</div>"
    console.log out

scrape-summary = (win, domain, cb) ->
  oembed.extract-html win, cb, ->
    get-twitter-or-facebook-meta win, cb, ->
      default-summary-scrape win, cb

meta-tag-info = (win, cb) ->
  cb do
    title: win.document.query-selector("title")?.text or "Untitled"
    description: win.document.query-selector("meta[name=\"description\"]")?.text or "Untitled"

default-summary-scrape = (win, cb) ->
  # lacking more sophisticated methods, try this
  res = {}
  res.title = win.document.title
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
  cb res

export render-tweet = (win) ->
  console.log win.document.query-selector(\p.TweetTextSize)?text-content

get-twitter-or-facebook-meta = (win, cb, fail) ->
  # twitter = twitter cards, which fall back to Facebook Open Graph
  # Twitter Card spec:
  # https://dev.twitter.com/cards/markup
  # Open graph:
  # http://ogp.me/

  # first declare some tools here to keep scope clean
  core-prop = (win, sel) ->
    # for some reason some sites have multiple meta tags with the same property
    # worse, the values aren't the same - some are empty
    # Example as of 2015-01-28: BoingBoing
    win.document.query-selector-all(sel) |>
      filter (-> it.attributes.content?.value?.length > 0) |>
      -> it.0?.attributes.content.value

  meta-selects = do
    title: \title
    description: 'meta[name="description"]'
    image: 'meta[name="image"]'

  prop = (win, p) ->
    # this is a wrapper that tries first for Twitter then for Open Graph tags
    core-prop(win, "meta[property=\"twitter:#p\"]") or core-prop(win, "meta[property=\"og:#p\"]") or core-prop(win, meta-selects[p])

  # first try for a title; if none, assume the other tags aren't there
  get-prop = -> prop win, it
  res = {}
  res.title = get-prop \title
  if not res.title then return fail! # probably not supported
  res.description = get-prop \description
  res.image = get-prop \image
  # there are some other attributes but they don't seem very useful
  cb res

get-oembed = (win) ->
  # See Discovery section of oembed docs: 
  # http://oembed.com/#section4
  #
  # For ease of use here we're only going to check for json, though
  # technically a site could offer just xml
  oembed-url = win.document.query-selector("link[type=\"application/json+oembed\"]")?.attributes.href
  request oembed-url, (error, response, body) ->
    data = JSON.parse body
    # we need to handle this differently for four types: photo, video, link, rich.
    # video and rich are the easiest since they include html.
    output = switch data.type
    | \rich, \video => # this is just some html to include, return as-is
      data.html
    | \photo => # just an image; width and height are available if needed
      "<div class=\"imgwrapper\" style=\"background: url(#{data.url})\" ></div>"
    | \link => # this means it only has the default parameters
      #TODO is this even useful?
    default throw "Unknown oembed type"

