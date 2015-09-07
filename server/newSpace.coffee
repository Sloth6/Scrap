uuid = require 'node-uuid'
models = require '../models'

module.exports = ({ userId, spaceName, root }, callback) ->
  root ?= false
  spaceName ?= 'New Space'
  spaceKey = uuid.v4().split('-')[0]
  models.User.find(
    where: { id: userId }
    include: [ models.Space ]
  ).complete (err, user) ->
    return callback err if err?
    attributes = { name: spaceName, spaceKey, root }
    models.Space.create( attributes ).complete (err, space) ->
      return callback err if err?
      space.addUser(user).complete (err) ->
        return callback err if err?
        space.setCreator(user).complete (err) ->
          return callback err if err?
          callback null
