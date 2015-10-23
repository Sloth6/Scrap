models = require '../models'

module.exports = (params, callback) ->
  params.name ?= ''
  models.User.find(
    where: { id: params.UserId }
  ).complete (err, user) ->
    return callback err if err?
    return callback('no user found') unless user?
    models.Space.create( params ).complete (err, space) ->
      return callback err if err?
      space.addUser(user).complete (err) ->
        return callback err if err?
        space.setCreator(user).complete (err) ->
          return callback err if err?
          callback null, space
