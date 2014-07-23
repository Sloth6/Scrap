db = require '../../models'
async = require 'async'

module.exports =

  # create a new element and save it to db
  newElement : (sio, socket, data, spaceId, callback) =>

    options =
      contentType : data.contentType
      content : data.content
      x: data.x
      y: data.y
      z: data.z
      scale: data.scale

    db.Element.create(options).complete (err, element) =>
      return callback err if err?
      sio.to("#{spaceId}").emit 'newElement', { element }
      callback()

  # delete the element
  removeElement : (sio, socket, data, spaceId, callback) =>
    id = data.elementId

    # find/delete the element
    db.Element.find(where: { id } ).complete (err, element) =>
      return callback err if err?
      element.destroy().complete (err) =>
        return callback err if err?
        sio.to("#{spaceId}").emit 'removeElement', { element }
        callback()

  # moves an element from one column to another
  updateElement : (sio, socket, data, spaceId, callback) =>
    id = data.elementId
    
    toUpdate = {}
    toUpdate.x = data.x if data.x?
    toUpdate.y = data.y if data.y?
    toUpdate.z = data.z if data.z?
    toUpdate.scale = data.scale if data.scale?

    # find the element first
    db.Element.find(where: { id } ).complete (err, element) =>
      return callback err if err?
      element.updateAttributes(toUpdate).complete (err, element) =>   
        return callback err if err?
        # remove from the old column and add to new one    
        sio.to("#{spaceId}").emit 'updateElement', { element }
        callback()