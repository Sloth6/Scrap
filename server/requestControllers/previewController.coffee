models = require '../../models'
request = require 'request'
cheerio = require 'cheerio'

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
          title: $('meta[property="og:title"]').attr('content')
          type: $('meta[property="og:type"]').attr('content')
          image: $('meta[property="og:image"]').attr('content')
          url: $('meta[property="og:url"]').attr('content')
          description: $('meta[property="og:description"]').attr('content')
        res.json metadata
        callback()