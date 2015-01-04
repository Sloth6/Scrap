models = require '../../models'
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

  min = 300
  $('img').each () ->
    if @attribs.width >= min and @attribs.height >= min
      img = @attribs.src
      return
  return img if img?

  img = $('link[rel="shortcut icon"]')[0].href
  return img if img?
  return null

extractDescription = ($) ->
  $('meta[property="og:description"]').attr('content') or ''

extractUrl = ($) ->
  $('meta[property="og:url"]').attr('content')


module.exports =
  web: (req, res, callback) ->
    url = req.query.url
    request url, (error, response, body) ->
      if error or response.statusCode isnt 200
        res.send 400
        callback()
      else
        $ = cheerio.load body
        metadata =
          title: extractTitle($)
          image: extractImage($)
          url: extractUrl($) or url
          description: extractDescription($)
        console.log 'METADATA', metadata
        res.json metadata
        callback()