models   = require '../../models'
async    = require 'async'
s3 = require '../adapters/s3.coffee'
request = require 'request'

# webPreviews = require '../modules/webPreviews.coffee'
# thumbnails = require '../modules/thumbnails.coffee'
# videoScreenshot = require '../modules/videoScreenshot.coffee'

newElements = require './newElements'

element_jade = null
require('fs').readFile __dirname+'/../../views/partials/element.jade', 'utf8', (err, data) ->
  throw err if err
  element_jade = require('jade').compile data


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
    return cb 'gif' if contentType.match /^image\/gif/
    return cb 'image' if contentType.match /^image\//
    return cb 'video' if contentType.match /^video\//
    if contentType.match /^text\/html/
      return cb 'soundcloud' if host is 'soundcloud.com'
      return cb 'website'
    return cb 'file'# if contentType.match /^application\//

module.exports =
  # create a new element and save it to db
  newElement : (sio, socket, data, callback) =>
    spaceKey = data.spacekey
    data.content = decodeURIComponent data.content
    userId = socket.handshake.session.userId
    console.log 'Received content:'
    console.log "\tuserId: #{userId}"
    console.log "\tspaceKey: #{spaceKey}"
    console.log "\tcontent: #{data.content}"

    done = (err, attributes) ->
      return callback err if err
      models.Space.find(where: { spaceKey }).complete (err, space) =>
        return callback err if err?
        attributes.SpaceId = space.id
        models.Element.create(attributes).complete (err, element) =>
          return callback err if err?
          html = encodeURIComponent(element_jade({element, names:{}}))
          console.log 'emitting new element', element.content, spaceKey
          sio.to(spaceKey).emit 'newElement', { html, spaceKey }
          return callback null
    
    getType data.content, (contentType) ->
      console.log "\tcontentType: #{contentType}"
      attributes =
        creatorId: userId
        contentType: contentType
        content: data.content

      if contentType of newElements
        newElements[contentType] spaceKey, attributes, done
      else
        done null, attributes

  # delete the element
  removeElement : (sio, socket, data, callback) =>
    id = data.elementId
    spaceKey = data.spacekey
    # Post.destroy({
    #   where: {
    #     status: 'inactive'
    #   }
    # })

    query = "DELETE FROM \"Elements\" WHERE \"id\"=:id returning \"contentType\", content"

    elementShell = models.Element.build()
    models.sequelize.query(query, null, null, { id })
      .complete (err, results) ->
        return callback err if err?
        

        type = results[0].contentType
        content = results[0].content
        
        if type in ['gif', 'image']
          s3.deleteImage { spaceKey, key: content, type }, (err) ->
            console.log err if err
        if type in ['file', 'video']
          s3.delete {key: content}, (err) ->
            console.log err if err
          
        sio.to(spaceKey).emit 'removeElement', { id }
        callback()

  updateElement : (sio, socket, data, callback) =>
    spaceKey = data.spaceKey
    data.id = +data.elementId

    query = "UPDATE \"Elements\" SET"
    query += " \"content\"=:content" if data.content?
    # remove the trailing comma if necessary
    # query = query.slice(0,query.length - 1) if query[query.length - 1] is ","
    query += " WHERE \"id\"=:id RETURNING *"

    # new element to be filled in by update
    element = models.Element.build()
    models.sequelize.query(query, element, null, data).complete (err, result) ->
      return callback err if err?
      sio.to("#{spaceKey}").emit 'updateElement', { element, userId: data.userId }
