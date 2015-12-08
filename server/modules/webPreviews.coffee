request = require 'request'
cheerio = require 'cheerio'
urlUtil = require 'url'

extractTitle = ($) ->
  title = $('meta[property="og:title"]').attr('content')
  if title?
    console.log 'Got title from meta tag:', title
    return title
  
  title = $("title").text()
  if title?
    console.log 'Got title from title:', title
    return title 
  
  console.log 'Did not find a title'
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

formatImageUrl = (domain, src) ->
  return null unless src?
  urlUtil.resolve domain, src

module.exports = (url, callback) ->
  jar = request.jar()

  options =
    method: 'GET'
    url: url
    followAllRedirects: true
    jar: jar

  request options, (error, response, body) ->
    if error or response.statusCode isnt 200
      callback error or response.statusCode
    else
      $ = cheerio.load body
      url = extractUrl($) or url
      metadata =
        title: extractTitle($)
        image: formatImageUrl(url, extractImage($))
        url: url
        description: extractDescription($)
        domain: urlUtil.parse(url).hostname.replace('www.', '')
      callback null, metadata