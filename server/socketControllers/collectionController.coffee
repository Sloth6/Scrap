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
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <title>Blah</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    </head>
    <body style="
        margin: 48pt 0 48pt 0;
        padding: 0;
    ">
        <table border="0" cellpadding="0" cellspacing="0" width="320" align="center" style="
            font-family: -apple-system, 'Helvetica Neue', 'Helvetica', 'Arial', sans-serif;
            ">
            <tr>
                <td style="
                    font-size: 24px;
                    font-weight: 600;
                    line-height: 28px;
                    letter-spacing: -.03215em;
                    padding: 4pt 4pt 36pt 4pt;
                    text-align: center;
                ">
                    #{creator.name} shared <br>“<a href="http://tryscrap.com/" style="text-decoration: none; color: black; border-bottom: 0 solid black">#{collection.name}</a>”<br> with you on <a href="http://tryscrap.com/" style="text-decoration: none; color: black; border-bottom: 0 solid black">Scrap</a>.
                </td>
            </tr>
            <tr>
                <td height=480 width=320 style="
                    vertical-align: top;
                    border: 1px solid black;
                    padding: 2pt;
                    background: #7bffc8 !important;
                    -webkit-transform: rotate(3deg);
                       -moz-transform: rotate(3deg);
                        -ms-transform: rotate(3deg);
                            transform: rotate(3deg);
                ">
                    <a href="#" style="
                        display: block;
                        height: 100%;
                        width: 100%;
                        color: black !important;
                        text-decoration: none;
                    ">
                        <table border="0">
                            <tr>
                                <td style="
                                    vertical-align: top;
                                ">
                                    <h1 class="typeTitle typeWeightBold typeOutlineClear typeOutlineBlackOnHover"
                                        style="
                                            font-size: 48pt;
                                            line-height: 48pt;
                                            letter-spacing: -.03125em;
                                            margin: 0;
                                            -webkit-text-stroke: 1px black;
                                            -webkit-text-fill-color: transparent;
                                        ">#{collection.name}</h1>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <ul class="users typeSmall" style="
                                        list-style: none;
                                        margin: 0;
                                        margin-top: 12pt;
                                        padding: 2pt;
                                        font-size: 8pt;
                                        line-height: 1.5em;
                                        color: black;
                                    ">
                                        <li style="
                                            padding: 0;
                                            margin: 0;
                                            font-size: 6pt;
                                            text-transform: uppercase;
                                            letter-spacing: .125em;
                                            font-weight: 600;
                                        ">Members</li>
                                        <li style="padding: 0; margin: 0;">Name Name</li>
                                        <li style="padding: 0; margin: 0;">Name Name</li>
                                        <li style="padding: 0; margin: 0;">Name Name</li>
                                        <li style="padding: 0; margin: 0;">Name Name</li>
                                    </ul>
                                </td>
                            </tr>
                        </table>
                    </a>
                </td>
            </tr>
            <tr>
                <td style="
                    font-size: 12pt;
                    font-weight: 400;
                    letter-spacing: -.03215em;
                    padding: 48pt 4pt 4pt 4pt;
                    text-align: center;
                ">
                    <a href="#" style="text-decoration: none; color: black; border-bottom: 0 solid black">Check it out ›</a>
                </td>
            </tr>
        </table>
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
