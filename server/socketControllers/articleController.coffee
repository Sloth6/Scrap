models   = require '../../models'
async    = require 'async'
s3 = require '../adapters/s3.coffee'
request = require 'request'

articleRenderer = require '../modules/articleRenderer.coffee'
newArticles = require './newArticles'

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

module.exports =
  # create a new article and save it to db
  newArticle : (sio, socket, data, callback) =>
    collectionKey = data.collectionKey
    rawContent = decodeURIComponent data.content
    userId = socket.handshake.session.userId
    user = socket.handshake.session.user
    
    console.log 'newArticle:'
    console.log "\tuserId: #{userId}"
    console.log "\tcollectionKey: #{collectionKey}"
    console.log "\trawContent: #{rawContent}"

    getType rawContent, (contentType) ->
      console.log "\tcontentType: #{contentType}"
      
      newArticles[contentType] rawContent, (err, content) ->
        return callback err if err

        attributes = { creatorId: userId, contentType, content }

        models.Collection.find(where: { collectionKey }).done (err, collection) ->
          return callback err if err
          
          models.Article.create(attributes).done (err, article) ->
            return callback err if err
            
            user.addArticle(article).done (err) ->
              return callback err if err

              if collection?
                html = articleRenderer article, [collection]
                room = collection.collectionKey    
              else
                html = articleRenderer article, []
                room = "user:#{userId}"
              
              console.log 'emitting to ', room
              sio.to(room).emit 'newArticle', { html: encodeURIComponent(html) }
              callback null
        
          

  # delete the article
  deleteArticle : (sio, socket, data, callback) =>
    userId   = socket.handshake.session.currentUserId
    id       = data.articleId
    collectionKey = data.collectionKey

    return callback('no id passed to deleteArticle') unless id
    return callback('no collectionKey passed to deleteArticle') unless collectionKey
    
    console.log "Delete article #{id} in #{collectionKey}"
    q1 = "
        DELETE FROM \"Articles\"
        WHERE \"id\"=:id
        RETURNING \"contentType\", content, \"CollectionId\"
      "
    models.sequelize.query(q1, replacements: { id }).done (err, results) ->
      return console.log('error deleting article') if err?
      
      console.log 'emiting deleteArticle', { id, collectionKey }
      sio.to(collectionKey).emit 'deleteArticle', { id, collectionKey }
      { contentType, content } = results[0][0]
      # if contentType in ['gif', 'image']
      #   s3.deleteImage { collectionKey, key: content, contentType }, (err) ->
      #     console.log err if err
      if contentType in ['file', 'video', 'image']
        s3.delete content, (err) ->
          console.log err if err

  # moveToCollection: (sio, socket, data, callback) ->
  #   { elemId, collectionKey } = data
  #   return callback('no collectionKey in moveToCollection') unless collectionKey?
  #   return callback('no elemId in moveToCollection') unless elemId?
  #   console.log "move to collection data:", data
  #   models.Article.find(where: { id: elemId }).then (elem) ->
  #     oldCollectionId = elem.CollectionId
  #     console.log 'old collection id', oldCollectionId
  #     q = "
  #         UPDATE \"Articles\"
  #         SET \"CollectionId\" = (Select id from \"Collections\" WHERE \"collectionKey\"=:collectionKey)
  #         WHERE \"id\"=:elemId
  #         "
  #     models.sequelize.query(q, replacements :data).then (results) ->
  #       return callback err if err?
  #       sio.to("#{collectionKey}").emit 'moveToCollection', data 
  #       callback null
  
  updateArticle : (sio, socket, data, callback) =>
    userId = socket.handshake.session.currentUserId
    { collectionKey, content, articleId } = data
    console.log "update article"
    console.log "\t#{articleId}"
    console.log "\t#{content}"
    console.log "\t#{collectionKey}"
    id = +articleId
    models.Article.update({content}, where: {id}).done (err) ->
      return callback(err) if err?
      data.userId = userId
      sio.to("#{collectionKey}").emit 'updateArticle', data
      callback null
