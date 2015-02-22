models   = require '../../models'
async    = require 'async'
webPreviews = require '../modules/webPreviews.coffee'
thumbnails = require '../modules/thumbnails.coffee'
request = require 'request'

memCache = {}

getType = (s, cb) ->
  jar = request.jar()
  options =
    url: s
    followAllRedirects: true
    jar: jar

  request.head options, (err, res) ->
    # console.log err, res?.statusCode
    if err || res.statusCode != 200
      return cb 'text'
    contentType = res.headers['content-type']
    return cb 'gif' if contentType.match /^image\/gif/
    return cb 'image' if contentType.match /^image\//
    return cb 'website' if contentType.match /^text\/html/
    return 'text'

module.exports =
  # create a new element and save it to db
  newElement : (sio, socket, data, spaceKey, callback) =>
    console.log 'Received content', data.content

    done = (attributes) ->
      models.Space.find(where: { spaceKey }).complete (err, space) =>
        return callback err if err?
        attributes.SpaceId = space.id
        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?
          sio.to(spaceKey).emit 'newElement', { element }
          return callback()
    
    newImage = (attributes) ->
      original_url = data.content
      models.Space.find(where: { spaceKey }).complete (err, space) =>
        return callback err if err?
        attributes.SpaceId = space.id
        
        key = Math.random().toString(36).slice(2)
        attributes.content = key

        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?

          # element.contentType = 'temp_image'
          element.content = original_url
          sio.to(spaceKey).emit 'newElement', { element }

          options =
            url: original_url
            contentType: element.contentType
            spaceKey: spaceKey
            key: key

          thumbnails options, (err) -> 
            return callback err if err?
            attributes.content = key
            return callback()
            
    newWebsite = (attributes) ->
      # url = decodeURIComponent data.content
      webPreviews attributes.content, (err, pageData) ->
        if err?
          attributes.content = JSON.stringify { 
            title: url.match(/www.([a-z]*)/)[1]
            url: encodeURIComponent(url)
            description: ''
          }
        else
          pageData.url = encodeURIComponent pageData.url
          attributes.content = JSON.stringify pageData
        done attributes
    
    # console.log data.content
    data.content = decodeURIComponent data.content
    # console.log data.content, '\n'
    getType data.content, (contentType) ->
      console.log {contentType}
      attributes =
        creatorId: data.userId
        contentType: contentType
        content: data.content
        caption: data.caption
        x: data.x
        y: data.y
        z: data.z
        scale: data.scale

      if contentType is 'website'
        newWebsite attributes
      else if contentType in ['image', 'gif']
        newImage attributes
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
    query += " \"content\"=:content" if data.content?
    # remove the trailing comma if necessary
    query = query.slice(0,query.length - 1) if query[query.length - 1] is ","
    query += " WHERE \"id\"=:id RETURNING *"

    # new element to be filled in by update
    # console.log data.final
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
      element.content = data.content if data.content
      sio.to("#{spaceKey}").emit 'updateElement', { element, userId: data.userId }
