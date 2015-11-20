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
    models.Collection.create( params ).complete (err, collection) ->
      return callback err if err?
      async.parallel [
        (cb) -> collection.addUser(user).complete cb
        (cb) -> collection.setCreator(user).complete cb
        (cb) ->
          return cb(null) unless parent?
          collection.setParent(parent).complete cb
        (cb) ->
          return cb(null) unless parent?
          parent.addChildren(collection).complete cb
      ], (err) ->
        callback err, collection