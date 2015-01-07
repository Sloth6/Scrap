request = require 'request'
cheerio = require 'cheerio'

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
  # console.log 'Got image from OG' if img?
  return img if isImage img
  
  min = 200
  max = 0
  $('img').each () ->
    # console.log @attribs.src, @attribs
    # Take the first image larger than our min size,
    if @attribs.width >= min and @attribs.height >= min
      img = @attribs.src
      # console.log 'Got large' if img?
      return if isImage img
    # Or take the largest image
    size = @attribs.width * @attribs.height
    if size > max and isImage @attribs.src
      max = size
      img = @attribs.src 

  # console.log 'Got largest' if img?
  return img if img?
  #if no images on page try the favicon... :(
  img = $('link[rel="shortcut icon"]')[0]?.href
  return img if isImage img
  console.log 'found none'
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
  if src.match /^/
    console.log domain, src
    'http://'+domain+src
  else
    src

module.exports = (url, callback) ->
  request url, (error, response, body) ->
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