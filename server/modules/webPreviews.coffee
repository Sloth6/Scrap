request = require 'request'
cheerio = require 'cheerio'
url = require 'url'

extractTitle = ($) ->
  title = $('meta[property="og:title"]').attr('content')
  return title if title? 

  title = $("title").text()
  return title if title? 
  return null

extractImage = ($) ->
  isImage = (url) -> 
    console.log url
    url? and url.match(/\.(jpeg|jpg|gif|png)$/)?

  img = $('meta[property="og:image"]').attr('content')
  return img if isImage img
  
  max = 0
  srcMax = ''
  for img in $('img')
  
    size = $(img).attr('width') * $(img).attr('height')
    src = $(img).attr('src')
    # console.log src, $(img).attr('width'), $(img).attr('height')
    continue unless isImage src
    # Take the first image larger than our min size,
    if size >= 40000
      return src
    # Or take the largest image
    if size > max
      max = size
      srcMax = src

  return srcMax if isImage srcMax
  #if no images on page try the favicon... :(
  img = $('link[rel="shortcut icon"]')[0]?.href
  return img if isImage img
  # console.log 'found none'
  return null

extractDescription = ($) ->
  $('meta[property="og:description"]').attr('content') or ''

extractUrl = ($) ->
  $('meta[property="og:url"]').attr('content')

extractDomain = (url) ->
  reg =  new RegExp("^(?:([^:/?#.]+):)?(?://)?(([^:/?#]*)(?::(\\d*))?)((/(?:[^?#](?![^?#/]*\\.[^?#/.]+(?:[\\?#]|$)))*/?)?([^?#/]*))?(?:\\?([^#]*))?(?:#(.*))?")
  parts = reg.exec url
  parts[2] or ''
  # http://www.gamasutra.com/view/feature/1419/designing_for_motivation.php?print=1

formatImage = (domain, src) ->
  return null unless src?
  url.resolve domain, src

module.exports = (url, callback) ->
  jar = request.jar()

  options =
    method: 'GET'
    url: url
    followAllRedirects: true
    jar: jar

  request options, (error, response, body) ->
    if error or response.statusCode isnt 200
      # console.log 'Error in getting html for preview', response.statusCode,{error, body}
      callback error or response.statusCode
    else
      $ = cheerio.load body
      domain = extractDomain url
      metadata =
        title: extractTitle($)
        image: formatImage(domain, extractImage($))
        url: extractUrl($) or url
        description: extractDescription($)
        domain: domain
      callback null, metadata