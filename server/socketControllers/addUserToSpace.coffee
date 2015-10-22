models = require '../../models'
mail = require '../adapters/nodemailer'
elementRenderer = require '../modules/elementRenderer.coffee'
async = require 'async'
domain = 'http://tryScrap.com'
newSpace = require '../newSpace'

pipeline = (sio, user, spaceKey, callback) ->
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

      (cb) -> space.addUser(user).complete cb

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
        # console.log cover.dataValues, rootSpace.dataValues
        # try
        html = elementRenderer space, cover
        sio.to(rootSpace.spaceKey).emit 'newElement', { html, spaceKey }
        # catch e
        #   console.log 'e', e
        #   return cb(e)
        cb null
      
      (cb) ->
        title = "<a href=\"#{domain}s/#{spaceKey}\">#{space.name}</a>"
        subject = "#you were invited to #{space.name} on Scrap."
        
        html = "
            <h1>View #{title} on Scrap.</h1>
            <p>If you do not yet have an account, register with email '#{user.email}' to view.</p><br>
            <p><a href=\"#{domain}\">Scrap</a> is a simple visual organization tool.</p>"

        mail.send {
          to: user.email
          subject: subject
          text: html
          html: html
        }
    ], callback

module.exports = (sio, socket, data, callback) =>
  { email, spaceKey } = data
  console.log "Inviting #{email} to #{spaceKey}"
  return callback('invalid') unless email?
  return callback('invalid') unless spaceKey?

  models.User.find( where: { email }).success (user, created) ->
    return callback(err) if err?
    # return callback('no user found') unless user?
    if user?
      pipeline(sio, user, spaceKey, callback)
    else
      models.User.create({ email, name:email }).complete (err, user) ->
        return callback err if err?
        firstSpaceOptions =
          UserId: user.id
          name: user.name
          root: true
        newSpace firstSpaceOptions, (err) ->
          return callback err if err?
          pipeline(sio, user, spaceKey, callback)


# models.sequelize.query('delete from "Users" where password is null').complete (err) ->
#   console.log err
#   module.exports null, null, {email:'jssimon@andrew.cmu', spaceKey: 'f0dcd0fc'}, (err) ->
#     console.log err
# module.exports null, null, {email:'jssimon@andrew.cmu.edu', spaceKey:'6d4c94c1'}, (err) ->
#   console.log err