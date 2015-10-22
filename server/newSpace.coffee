models = require '../models'

module.exports = (params, callback) ->
  # root ?= false
  # { userId, spaceName, root } = params
  # spaceName ?= 'New Space'
  params.name ?= ''
  # params.spaceKey = uuid.v4().split('-')[0]
  # spaceKey = uuid.v4().split('-')[0]
  models.User.find(
    where: { id: params.UserId }
    # include: [ models.Space ]
  ).complete (err, user) ->
    return callback err if err?
    return callback('no user found') unless user?
    # params = { name: spaceName, spaceKey, root }
    models.Space.create( params ).complete (err, space) ->
      return callback err if err?
      space.addUser(user).complete (err) ->
        return callback err if err?
        space.setCreator(user).complete (err) ->
          return callback err if err?
          callback null, space
