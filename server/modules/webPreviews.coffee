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
  
  img = $('meta[property="og:image"]').attr('content')
  return img if img?
  
  max = 0
  srcMax = ''
  for img in $('img')
  
    size = $(img).attr('width') * $(img).attr('height')
    src = $(img).attr('src')
    # console.log src, $(img).attr('width'), $(img).attr('height')
    # Take the first image larger than our min size,
    if size >= 40000
      return src
    # Or take the largest image
    if size > max
      max = size
      srcMax = src

  return srcMax if max > 0
  # console.log 'found none'
  return null

extractDescription = ($) ->
  $('meta[property="og:description"]').attr('content') or ''

extractUrl = ($) ->
  $('meta[property="og:url"]').attr('content')

extractDomain = (url) ->
  reg =  new RegExp("^(?:([^:/?#.]+):)?(?://)?(([^:/?#]*)(?::(\\d*))?)((/(?:[^?#](?![^?#/]*\\.[^?#/.]+(?:[\\?#]|$)))*/?)?([^?#/]*))?(?:\\?([^#]*))?(?:#(.*))?")
  parts = reg.exec url
  if parts[2]
    parts[2].split('www.')[1]
  else
    console.log 'failed to extract domain', url
    url
  # http://www.gamasutra.com/view/feature/1419/designing_for_motivation.php?print=1

formatImageUrl = (domain, src) ->
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
      url = extractUrl($) or url
      domain = extractDomain url
      metadata =
        title: extractTitle($)
        image: formatImageUrl(url, extractImage($))
        url: url
        description: extractDescription($)
        domain: domain
      callback null, metadata