models   = require '../../models'
async    = require 'async'
s3 = require '../adapters/s3.coffee'
newArticle = require '../newArticle.coffee'
articleRenderer = require '../modules/articleRenderer.coffee'

getCollectionKeys = (articleId, callback) ->
  q = """
      SELECT "collectionKey" FROM "Collections" where "id" in
        (SELECT "CollectionId" from "ArticlesCollections"
        WHERE "ArticleId"=:articleId)
      """
  models.sequelize.query(q, replacements: { articleId }).done (err, results) ->
    return callback(err) if err?
    callback null, (res.collectionKey for res in results[0])

# getCollectionKeys 18, (a, b) ->
#   console.log a, b

module.exports =
  # create a new article and save it to db
  newArticle : (sio, socket, data, callback) =>
    collectionKey = data.collectionKey
    rawContent = decodeURIComponent data.content
    # userId = socket.handshake.session.userId
    user = socket.handshake.session.user

    console.log 'newArticle:'
    console.log "\tuserId: #{user.id}"
    console.log "\tcollectionKey: #{collectionKey}"
    console.log "\trawContent: #{rawContent}"

    newArticle rawContent, user, (err, article) ->
      return callback(err) if err
      # if collection?
      #   html = articleRenderer article, [collection]
      #   room = collection.collectionKey
      # else
      html = articleRenderer article, []
      room = "user:#{user.id}"

      console.log 'emitting to ', room
      sio.to(room).emit 'newArticle', { html: encodeURIComponent(html) }
      callback null

  # delete the article
  deleteArticle : (sio, socket, data, callback) =>
    userId   = socket.handshake.session.currentUserId
    id       = data.articleId
    return callback('no id passed to deleteArticle') unless id?
    console.log "Delete Article \n\tid:#{id}\n\tuserId:#{userId}"

    q1 = """
        DELETE FROM "Articles"
        WHERE "id"=:id
        RETURNING "contentType", content
      """

    models.sequelize.query(q1, replacements: { id }).done (err, results) ->
      return console.log('error deleting article'+err) if err?
      { contentType, content } = results[0][0]
      console.log "\t#{contentType}, #{content}"
      sio.to("user:#{userId}").emit 'deleteArticle', { id }

      # if contentType in ['file', 'video', 'image'] #, 'gif'
      #   s3.delete content, (err) ->
      #     console.log err if err

  updateArticle : (sio, socket, data, callback) =>
    userId = socket.handshake.session.currentUserId
    { content, articleId } = data
    console.log "update article"
    console.log "\t#{articleId}\n\t", content
    id = +articleId

    models.Article.update({ content }, where: { id }).done (err) ->
      getCollectionKeys id, (err, collectionKeys) ->
        return callback(err) if err?
        data.userId = userId
        for key in getCollectionKeys
          sio.to("#{key}").emit 'updateArticle', data
        callback null
