models   = require '../../models'
async    = require 'async'
memCache = {}

module.exports =
  # create a new element and save it to db
  newElement : (sio, socket, data, spaceKey, callback) =>
    if typeof data.content is 'object'
      data.content = JSON.stringify data.content
    attributes = {
      contentType: data.contentType
      content: data.content
      caption: data.caption
      x: data.x
      y: data.y
      z: data.z
      scale: data.scale
    }

    models.Space.find(where: { spaceKey }).complete (err, space) =>
      return callback err if err?
      attributes.SpaceId = space.id
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
