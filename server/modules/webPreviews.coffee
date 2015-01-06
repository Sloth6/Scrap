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
      # console.log 'METADATA', metadata
      callback null, metadata