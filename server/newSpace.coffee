models = require '../models'
async = require 'async'

module.exports = (params, callback) ->
  params.name ?= ''
  parent = params.parent
  
  models.User.find(
    where: { id: params.UserId }
  ).complete (err, user) ->
    return callback err if err?
    return callback('no user found') unless user?
    models.Space.create( params ).complete (err, space) ->
      return callback err if err?
      async.parallel [
        (cb) -> space.addUser(user).complete cb
        (cb) -> space.setCreator(user).complete cb
        (cb) ->
          return cb(null) unless parent?
          space.setParent(parent).complete cb
        (cb) ->
          return cb(null) unless parent?
          parent.addChildren(space).complete cb
      ], (err) ->
        callback err, space