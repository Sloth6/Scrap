models   = require '../../models'
async    = require 'async'
webshot  = require 'webshot'
fs       = require 'fs'
Uploader = require('s3-streaming-upload').Uploader
request = require 'request'
cheerio = require 'cheerio'

memCache = {}
console.log 'sdsadasd'
module.exports =
  # create a new element and save it to db
  newElement : (sio, socket, data, spaceKey, callback) =>
    console.log 'newElement'
    attributes = {
      contentType: data.contentType
      content: data.content
      caption: data.caption
      x: data.x
      y: data.y
      z: data.z
      scale: data.scale
    }

    randString = () ->
      text = ""
      possible = "abcdefghijklmnopqrstuvwxyz0123456789"
      for i in [0..6]
        text += possible.charAt(Math.floor(Math.random() * possible.length))
      text

    createWebContent = (callback) ->
      if data.contentType isnt 'website'
        return callback null, null

      url = data.content
      request url, (error, response, body) ->
        if !error and response.statusCode is 200
          $ = cheerio.load body
          metadata =
            title: $('meta[property="og:title"]').attr('content')
            type: $('meta[property="og:type"]').attr('content')
            image: $('meta[property="og:image"]').attr('content')
            url: $('meta[property="og:url"]').attr('content')
            description: $('meta[property="og:description"]').attr('content')
          callback null, metadata
        else
          # console.log 'ERROR', error
          callback error
          
    models.Space.find(where: { spaceKey }).complete (err, space) =>
      return callback err if err?
      attributes.SpaceId = space.id
      if data.contentType is 'website'
        createWebContent (err, webContent) ->
          return callback err if err?
          attributes.content = JSON.stringify(webContent)
          models.Element.create(attributes).complete (err, element) =>
            return callback err if err?
            element.content = webContent
            sio.to(spaceKey).emit 'newElement', { element }
      else
        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?
          sio.to(spaceKey).emit 'newElement', { element }
        

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
    data.id = +data.elementId

    query = "UPDATE \"Elements\" SET"
    query += " \"x\"=:x," if data.x?
    query += " \"y\"=:y," if data.y?
    query += " \"z\"=:z," if data.z?
    query += " \"scale\"=:scale" if data.scale?
    # remove the trailing comma if necessary
    query = query.slice(0,query.length - 1) if query[query.length - 1] is ","
    query += " WHERE \"id\"=:id RETURNING *"

    # new element to be filled in by update
    element = models.Element.build()

    models.sequelize.query(query, element, null, data).complete (err, result) ->
      return callback err if err?
      sio.to("#{spaceKey}").emit 'updateElement', { element: result }
      callback()
