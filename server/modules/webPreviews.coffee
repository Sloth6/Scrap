request = require 'request'
cheerio = require 'cheerio'
urlUtil = require 'url'

http = require('http')
sizeOf = require('image-size')

async = require 'async'

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



imageSize = (url, callback) ->
  http.get urlUtil.parse(url), (response) ->
    chunks = []
    response.
      on('data', (chunk) -> chunks.push(chunk)).
      on 'end', () ->
        buffer = Buffer.concat(chunks)
        size   = sizeOf(buffer)
        callback null, {size, url}

extractImage = ($, callback) ->
  # img = $('meta[property="og:image"]').attr('content')
  # return img if img?

  # Look at only first n images.
  n = 5
  imgs = (img.attribs.src for img in $('img').toArray().slice(0,n))
  async.map imgs, imageSize, (err, mapped) ->

    mapped.sort (a, b) ->
      a.size.width*a.size.height < b.size.width*b.size.height

    callback mapped[0].url

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
      return callback error or response.statusCode
    $ = cheerio.load body

    extractImage $, (imgUrl) ->
      url = extractUrl($) or url
      metadata =
        title: extractTitle($)
        image: formatImageUrl(url, imgUrl)
        url: url
        description: extractDescription($)
        domain: urlUtil.parse(url).hostname.replace('www.', '')
      callback null, metadata

url = 'http://www.nytimes.com/2016/02/22/opinion/bernie-sanders-hits-a-roadblock.html'
module.exports url, (err, data) ->
  console.log data
