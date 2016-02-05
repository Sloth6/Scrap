models = require '../models'
request = require 'request'
newArticles = require './socketControllers/newArticles'

getType = (s, cb) ->
  jar = request.jar()
  options =
    url: s
    followAllRedirects: true
    jar: jar

  request.head options, (err, res) ->
    if err || !res
      return cb 'text'
    contentType = res.headers['content-type']
    host = res.socket._httpMessage._headers.host
    # return cb 'gif' if contentType.match /^image\/gif/
    return cb 'image' if contentType.match /^image\//
    return cb 'video' if contentType.match /^video\//
    if contentType.match /^text\/html/
      return cb 'soundcloud' if host is 'soundcloud.com'
      return cb 'youtube' if host is 'www.youtube.com'
      return cb 'website'
    return cb 'file'# if contentType.match /^application\//


module.exports = (rawContent, user, callback) ->
  getType rawContent, (contentType) ->
    console.log "\tcontentType: #{contentType}"
    
    newArticles[contentType] rawContent, (err, content) ->
      return callback err if err

      attributes = { creatorId: user.id, contentType, content }

      # models.Collection.find(where: { collectionKey }).done (err, collection) ->
      #   return callback err if err
        
      models.Article.create(attributes).done (err, article) ->
        return callback err if err
        
        user.addArticle(article).done (err) ->

          return callback err if err
          callback null, article