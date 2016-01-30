models = require '../../models'
mail = require '../adapters/nodemailer'
async = require 'async'
coverColor = require '../modules/coverColor'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

inviteEmailHtml = (user, collection) ->
  creator = collection.Creator
  domain = 'http://tryScrap.com'
  collectionKey = collection.collectionKey
  title = "<a href=\"#{domain}/s/#{collectionKey}\">#{collection.name}</a>"
  subject = "#{creator.name} invited you to #{collection.name} on Scrap."
  
  html = "
    <h1>View #{title} on Scrap.</h1>
    <p>If you do not yet have an account, register with email '#{user.email}' to view.</p><br>
    <p><a href=\"#{domain}\">Scrap</a> is a simple visual organization tool.</p>
  "
  return { html, subject }

module.exports =
  reorderCollection: (sio, socket, data) ->
    { collectionKey, articleOrder } = data
    what = { articleOrder }
    models.Collection.update(what, where:{ collectionKey }).done () ->
      console.log 'Emit order to client'
      # sio.to("#{parentcollectionKey}").emit 'newcollection', emitData

  # rename: (sio, socket, data, callback) ->
  #   { collectionKey, name } = data
  #   models.Collection.update({ name }, where: { collectionKey }).then () ->
  #     console.log "updated name of #{collectionKey} to #{name}"
  #     callback null
        # sio.to("#{collectionKey}").emit 'updateArticle', data
  
  inviteToCollection: (sio, socket, data, callback) =>
    { email, collectionKey } = data
    console.log "Inviting #{email} to #{collectionKey}"
    return callback('invalid email') unless email?
    return callback('invalid collectionKey') unless collectionKey?
    
    done = (user, collection) ->
      collection.addUser(user).done (err) ->
        return callback(err) if err?
        { html, subject } = inviteEmailHtml user, collection
        mail.send { to: email, subject: subject, text: html, html: html }
        callback null

    params = 
      where: { collectionKey }
      include: [{ model: models.User, as: 'Creator' }]

    models.Collection.find( params ).done (err, collection) ->
      return callback(err) if err?
      return callback('cannot invite to stack') unless collection.hasCover
      models.User.find( where: { email }).done (err, user) ->
        return callback(err) if err?
        return done user, collection if user?
        # Else no user
        console.log "\tCreating new user"
        models.User.createAndInitialize { email, name:email }, (err, user) ->
          return callback(err) if err?
          done user, collection

  addCollection: (sio, socket, data, callback) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
  
    options = { name }
    models.Collection.create({ name }).done (err, collection) ->
      return callback(err) if err?
      models.User.find( where: { id: userId }).done (err, user) ->
        return callback(err) if err?
        collection.addUser(user).done (err) ->
          return callback(err) if err?
          console.log 'new collection', collection.collectionKey
          socket.emit 'newcollection', collection.dataValues
          socket.join collection.collectionKey
          callback null

  removeCollection: (sio, socket, data, callback) ->
    collectionKey = data.collectionKey
    models.Collection.find( where: { collectionKey }).done (err,  collection ) ->
      return callback(err) if err?
      collection.destroy().done (err) ->
        return callback(err) if err?
        sio.to("#{collectionKey}").emit 'deletecollection', { collectionKey }
        callback null
