models   = require '../../models'
async    = require 'async'
webPreviews = require '../modules/webPreviews.coffee'
thumbnails = require '../modules/thumbnails.coffee'
memCache = {}

module.exports =
  # create a new element and save it to db
  newElement : (sio, socket, data, spaceKey, callback) =>
    console.log 'Received content', data.contentType
    done = (attributes) ->
      models.Space.find(where: { spaceKey }).complete (err, space) =>
        return callback err if err?
        attributes.SpaceId = space.id
        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?
          sio.to(spaceKey).emit 'newElement', { element }
    
    newImage = () ->
      original_url = data.content

      models.Space.find(where: { spaceKey }).complete (err, space) =>
        return callback err if err?
        attributes.SpaceId = space.id
        
        key = Math.random().toString(36).slice(2)
        attributes.content = key

        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?

          element.contentType = 'temp_image'
          element.content = original_url
          sio.to(spaceKey).emit 'newElement', { element }

          thumbnails { url: original_url, spaceKey, key }, (err) -> 
            return callback err if err?
            attributes.content = key
          



    attributes =
      creatorId: data.userId
      contentType: data.contentType
      content: data.content
      caption: data.caption
      x: data.x
      y: data.y
      z: data.z
      scale: data.scale

    if data.contentType is 'website'
      url = decodeURIComponent data.content
      webPreviews url, (err, pageData) ->
        if err?
          console.log url, err, pageData
          attributes.content = JSON.stringify { 
            title: url.match(/www.([a-z]*)/)[1]
            url: encodeURIComponent(url)
            description: ''
          }
        else
          pageData.url = encodeURIComponent pageData.url
          attributes.content = JSON.stringify pageData
        done attributes
    
    if data.contentType is 'image'
      newImage()
    else
      done attributes
        

  # delete the element
  removeElement : (sio, socket, data, spaceKey, callback) =>
    id = data.elementId

    query = "DELETE FROM \"Elements\" WHERE \"id\"=:id"

    elementShell = models.Element.build()
    models.sequelize.query(query, null, null, { id })
      .complete (err, result) ->
        return callback err if err?
        sio.to(spaceKey).emit 'removeElement', { id }
        callback()

  updateElement : (sio, socket, data, spaceKey, callback) =>
    # console.log data
    data.id = +data.elementId
    data.final = JSON.parse(data.final or 'false')
    query = "UPDATE \"Elements\" SET"
    query += " \"x\"=:x," if data.x?
    query += " \"y\"=:y," if data.y?
    query += " \"z\"=:z," if data.z?
    query += " \"scale\"=:scale" if data.scale?
    # remove the trailing comma if necessary
    query = query.slice(0,query.length - 1) if query[query.length - 1] is ","
    query += " WHERE \"id\"=:id RETURNING *"

    # new element to be filled in by update
    # console.log data
    if data.final
      element = models.Element.build()
      models.sequelize.query(query, element, null, data).complete (err, result) ->
        return callback err if err?
        sio.to("#{spaceKey}").emit 'updateElement', {
          element: result
          userId: data.userId
          final: true
        }
        callback()
    else
      userId = data.userId
      element = { id: data.id }
      element.x = parseInt data.x if data.x
      element.y = parseInt data.y if data.y
      element.z = parseInt data.z if data.z
      element.scale = parseFloat data.scale if data.scale
      # console.log element.scale
      sio.to("#{spaceKey}").emit 'updateElement', { element, userId: data.userId }
