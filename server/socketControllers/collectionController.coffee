models = require '../../models'
mail = require '../adapters/nodemailer'
async = require 'async'
coverColor = require '../modules/coverColor'
collectionRenderer = require '../modules/collectionRenderer'
# emailHtml = require '../modules/email/invite.html'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

inviteEmailHtml = (user, collection) ->
  creator = collection.Creator
  domain = 'http://tryScrap.com'
  collectionKey = collection.collectionKey
  title = "<a href=\"#{domain}/s/#{collectionKey}\">#{collection.name}</a>"
  subject = "#{creator.name} invited you to “#{collection.name}” on Scrap"  
  html = '''
  <!DOCTYPE html>
  <html>
      <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, maximum-scale=1, minimum-scale=1">
      </head>
      <body style="
          margin: 0;
          padding: 0;
      ">
          <article class="email" style="
              margin-top: 48pt;
              margin-bottom: 72pt;
              font-family: -apple-system, 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif;
          ">
              <section class="cards">
                  <header class="card" style="
                      padding: 4pt 4pt 120pt 4pt;
                      width: 320px;
                      border: 1px solid black;
                      position: relative;
                      left: 50%;
                      margin-left: -160px;
                      -webkit-transform: rotate(-3deg);
                         -moz-transform: rotate(-3deg);
                          -ms-transform: rotate(-3deg);
                              transform: rotate(-3deg);
                  ">
                      <h1 class="typeHeader" style="
                          font-size: 24px;
                          font-weight: 600;
                          letter-spacing: -.03215em;
                          margin: 0;
                          padding: 0;
                      ">
                          Joel Simon invited you to “<a href="http://tryscrap.com/" style="text-decoration: none; color: black; border-bottom: .125em solid black">Pack Name</a>” on <a href="http://tryscrap.com/" style="text-decoration: none; color: black; border-bottom: .125em solid black">Scrap</a>.
                      </h1>
                  </header>
                  <a href="#" style="
                      text-decoration: none;
                      color: black;
                      height: 480px;
                      width: 320px;
                      display: block;
                      position: relative;
                      left: 50%;
                      top: -72pt;
                      margin-left: -160px;
                  ">
                      <div style="
                          height: 480px;
                          width: 320px;
                          position: absolute;
                          border: 1px solid black;
                          background: white;
                          -webkit-transform: rotate(8deg);
                             -moz-transform: rotate(8deg);
                              -ms-transform: rotate(8deg);
                                  transform: rotate(8deg);
                          "></div>
                      <div style="
                          height: 480px;
                          width: 320px;
                          position: absolute;
                          border: 1px solid black;
                          background: white;
                          -webkit-transform: rotate(-6deg);
                             -moz-transform: rotate(-6deg);
                              -ms-transform: rotate(-6deg);
                                  transform: rotate(-6deg);
                          "></div>
                      <div style="
                          height: 480px;
                          width: 320px;
                          position: absolute;
                          border: 1px solid black;
                          background: white;
                          -webkit-transform: rotate(-4deg);
                             -moz-transform: rotate(-4deg);
                              -ms-transform: rotate(-4deg);
                                  transform: rotate(-4deg);
                          "></div>
                      <article class="card cover" style="
                          height: 100%;
                          width: 100%;
                          border: 1px solid black;
                          padding: 4pt;
                          background-color: hsl(100,100%,80%);
                          -webkit-transform: rotate(3deg);
                             -moz-transform: rotate(3deg);
                              -ms-transform: rotate(3deg);
                                  transform: rotate(3deg);
                      ">
                          <h1 class="typeTitle typeWeightBold typeOutlineClear typeOutlineBlackOnHover"
                              style="
                                  font-size: 48pt;
                                  line-height: 48pt;
                                  letter-spacing: -.03125em;
                                  margin: 0;
                                  -webkit-text-stroke: 1px black;
                                  -webkit-text-fill-color: transparent;
                              ">Pack Name</h1>
                          <div class="bottom" style="
                              position: absolute;
                              bottom: 4pt;
                              left: 4pt;
                              right: 4pt;
                          ">
                              <ul class="users typeSmall" style="
                                  list-style: none;
                                  margin: 0;
                                  padding: 0;
                                  font-size: 10pt;
                              ">
                                  <li>Name Name</li>
                                  <li>Name Name</li>
                                  <li>Name Name</li>
                                  <li>Name Name</li>
                              </ul>
                          </div>
                          </article>
                      </a>
              </section>
              <section class="card detail" style="
                  padding: 4pt 4pt 48pt 4pt;
                  border: 1px solid black;
                  font-size: 12pt;
                  background: white;
                  width: 240px;
                  position: relative;
                  left: 50%;
                  margin-left: -120px;
                  -webkit-transform: rotate(-8deg);
                     -moz-transform: rotate(-8deg);
                      -ms-transform: rotate(-8deg);
                          transform: rotate(-8deg);
                  
              ">
                  Scrap — save and share bits of the web. Get started.
              </section>
          </article>
      </body>
  </html>
'''
  return { html, subject }

module.exports =
  reorderArticles: (sio, socket, data) ->
    { collectionKey, articleOrder } = data
    what = { articleOrder }
    models.Collection.update(what, where:{ collectionKey }).done () ->
      console.log 'Emit order to client'
      # sio.to("#{parentCollectionKey}").emit 'newCollection', emitData

  rename: (sio, socket, data, callback) ->
    { collectionKey, name } = data
    models.Collection.update({ name }, where: { collectionKey }).then () ->
      console.log "updated name of #{collectionKey} to #{name}"
      callback null
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

  newStack: (sio, socket, data, callback) ->
    # CollectionKey will be the parent of the new collection
    parentCollectionKey = data.collectionKey
    userId = socket.handshake.session.userId
    
    # Dragged and draggedOver and the articles that created the collection
    draggedId     = parseInt data.draggedId
    draggedOverId = parseInt data.draggedOverId
    
    console.log 'New collection data', data
    return console.log('no draggedId in newCollection') unless draggedId?
    return console.log('no draggedOverId in newCollection') unless draggedOverId?


    async.waterfall [
      # Get the parent collection
      (cb) ->
        options =
          where: { collectionKey: parentCollectionKey }
          include: [ model: models.User, as: 'Creator' ]
        models.Collection.find( options ).done cb

      # Create the new collection
      (parent, cb) ->
        user = parent.Creator
        options = { hasCover: false, CreatorId: userId }
        models.Collection.createAndInitialize options, user, parent, (err, collection) ->
          return cb(err) if err?
          return cb null, collection, parent

      # Move articles to the new collection
      (collection, parent, cb) -> 
        console.log 'Moving articles to the new collection'
        updateQuery = "UPDATE \"Articles\"
                      SET \"CollectionId\" = '#{collection.id}'
                      WHERE id = #{draggedId} or id = #{draggedOverId};
                      "
        collection.articleOrder = [draggedId, draggedOverId]
        collection.save().done (err) ->
          return cb(err) if err 
          models.sequelize.query(updateQuery).done (err) ->
            if err then cb err else cb null, collection, parent

      # Change article order
      (collection, parent, cb) ->
        console.log "Changing article order"
        order = parent.articleOrder
        # The position of the dragegdOverId becomes the cover id   
        draggedOverPosition = order.indexOf(draggedOverId)
        draggedPosition = order.indexOf(draggedId)
        order[draggedOverPosition] = collection.id
        order.splice(draggedPosition, 1)
        parent.save().done (err) ->
          return cb(err) if err?
          cb null, parent, collection
    
    ], (err, parent, collection) ->
      return console.log err if err
      
      collectionHTML = collectionRenderer(collection)
      emitData = {collectionHTML, draggedId, draggedOverId}
      sio.to("#{parentCollectionKey}").emit 'newCollection', emitData
      socket.join collection.collectionKey
      callback null

  newPack: (sio, socket, data, callback) ->
    { name } = data
    userId = socket.handshake.session.userId
    return console.log('no userid', res) unless userId?
    return console.log('no name sent', res) unless name?
    async.waterfall [
      # Get the parent collection
      (cb) ->
        options =
          where: { CreatorId:userId, root: true }
          include: [ model: models.User, as: 'Creator' ]
        models.Collection.find( options ).done cb
      
      # Create the new collection
      (parent, cb) ->
        user = parent.Creator
        options = { name, hasCover:true, CreatorId: userId }
        models.Collection.createAndInitialize options, user, parent, cb

    ], (err, collection) ->
      return callback(err) if err?
      console.log 'new pack', collection.collectionKey
      socket.emit 'newPack', { collectionHTML: collectionRenderer(collection) }
      socket.join collection.collectionKey
      callback null

  deleteCollection: (sio, socket, data, callback) ->
    collectionKey = data.collectionKey
    models.Collection.find({
      where: { collectionKey }, include:[ model:models.Collection, as: "parent" ]
    }).then ( collection) ->
      parentCollectionKey = collection.parent.collectionKey

      # TODO change location string of parent
      # draggedPosition = order.indexOf(draggedId)
      # order.splice(draggedPosition, 1)

      collection.destroy().done (err) ->
        sio.to("#{parentCollectionKey}").emit 'deleteCollection', { collectionKey }
        callback null
