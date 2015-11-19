async = require 'async'
models = require '../models'
mail = require './adapters/nodemailer'
elementRenderer = require './modules/articleRenderer.coffee'
newSpace = require './newSpace'

module.exports = (user, spaceKey, callback) ->
  coverAttributes =
    SpaceId: null
    creatorId: null
    contentType: 'cover'
    content: spaceKey

  models.Space.find({
    where: { spaceKey }
    include:[ model:models.User]
  }).complete (err, space) ->
    return callback(err) if err?
    return callback('no space found for '+spaceKey) unless space?
    return callback('cant add user to root space') if space.root
    coverAttributes.SpaceId = space.id
    coverAttributes.creatorId = user.id
    async.waterfall [
      (cb) ->
        space.hasUser(user).complete (err, hasUser) ->
          if hasUser then cb('repeat add user to a space') else cb(null)

      (cb) ->
        space.addUser(user).complete cb

      (user, cb) -> # get the root space
        models.Space.find({ where: { root:true, UserId: user.id } }).complete cb
      
      # Create cover element
      (rootSpace, cb) ->
        return cb('no root collection found for invitee') unless rootSpace?
        coverAttributes.SpaceId = rootSpace.id
        models.Element.create(coverAttributes).complete (err, cover) ->
          if err then cb err else cb null, cover, rootSpace

      # Change element order
      (cover, rootSpace, cb) ->
        rootSpace.elementOrder.unshift(cover.id)
        rootSpace.save().complete (err) ->
          return cb(err) if err?
          cb null, cover, rootSpace

      (cover, rootSpace, cb) ->
        html = elementRenderer space, cover
        cb null, html, space
    ], callback