request = require 'request'
cheerio = require 'cheerio'

extractTitle = ($) ->
  title = $('meta[property="og:title"]').attr('content')
  return title if title? 

  title = $("title").text()
  return title if title? 
  return null

extractImage = ($) ->
  img = $('meta[property="og:image"]').attr('content')
  return img if img? 

  min = 200
  max = 0
  $('img').each () ->
    # console.log @attribs.src, @attribs
    # Take the first image larger than our min size,
    if @attribs.width >= min and @attribs.height >= min
      img = @attribs.src
      return
    # Or take the largest image
    size = @attribs.width * @attribs.height
    if size > max
      max = size
      img = @attribs.src

  return img if img?
  #if no images on page try the favicon... :(
  img = $('link[rel="shortcut icon"]')[0]?.href
  return img if img?
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

module.exports = (url, callback) ->
  request url, (error, response, body) ->
    if error or response.statusCode isnt 200
      # console.log 'Error in getting html for preview', response.statusCode,{error, body}
      callback error or response.statusCode
    else
      $ = cheerio.load body
      metadata =
        title: extractTitle($)
        image: extractImage($)
        url: extractUrl($) or url
        description: extractDescription($)
        domain: extractDomain url
      callback null, metadata