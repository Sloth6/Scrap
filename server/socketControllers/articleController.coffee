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
    collectionKey = data.collectionkey
    data.content = decodeURIComponent data.content
    userId = socket.handshake.session.userId
    console.log 'Received content:'
    console.log "\tuserId: #{userId}"
    console.log "\tcollectionKey: #{collectionKey}"
    console.log "\tcontent: #{data.content}"

    done = (err, attributes) ->
      return callback err if err
      params =
        where: { collectionKey }
        include: models.User
      models.Collection.find( params ).done (err, collection) ->
        return callback err if err
        attributes.CollectionId = collection.id
        models.Article.create(attributes).done (err, article) ->
          return callback err if err
          collection.update({
            articleOrder: models.sequelize.fn( 'array_append', models.sequelize.col('articleOrder'), "#{article.id}")
          }).done (err) ->
            return callback err if err
            html = articleRenderer collection, article
            console.log 'emitting to ', collectionKey
            sio.to(collectionKey).emit 'newArticle', { html, collectionKey }
            callback null
    
    getType data.content, (contentType) ->
      console.log "\tcontentType: #{contentType}"
      attributes =
        creatorId: userId
        contentType: contentType
        content: data.content

      if contentType of newArticles
        newArticles[contentType] collectionKey, attributes, done
      else
        done null, attributes

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
    models.sequelize.query(q1, replacements: { id }).then (results) ->
      console.log 'emiting deleteArticle', { id, collectionKey }
      sio.to(collectionKey).emit 'deleteArticle', { id, collectionKey }
      callback null
      # type = results[0].contentType
      # content = results[0].content
      # if type in ['gif', 'image']
      #   s3.deleteImage { collectionKey, key: content, type }, (err) ->
      #     console.log err if err
      # if type in ['file', 'video']
      #   s3.delete {key: content}, (err) ->
      #     console.log err if err

  moveToCollection: (sio, socket, data, callback) ->
    { elemId, collectionKey } = data
    return callback('no collectionkey in moveToCollection') unless collectionKey?
    return callback('no elemId in moveToCollection') unless elemId?
    console.log "move to collection data:", data
    models.Article.find(where: { id: elemId }).then (elem) ->
      oldCollectionId = elem.CollectionId
      console.log 'old collection id', oldCollectionId
      q = "
          UPDATE \"Articles\"
          SET \"CollectionId\" = (Select id from \"Collections\" WHERE \"collectionKey\"=:collectionKey)
          WHERE \"id\"=:elemId
          "
      models.sequelize.query(q, replacements :data).then ( results) ->
        return callback err if err?
        sio.to("#{collectionKey}").emit 'moveToCollection', data 
        callback null
  
  updateArticle : (sio, socket, data, callback) =>
    userId = socket.handshake.session.currentUserId
    { collectionKey, content, articleId } = data
    id = +articleId
    models.Article.update({content}, where: {id}).then () ->
      data.userId = userId
      sio.to("#{collectionKey}").emit 'updateArticle', data
      callback null
