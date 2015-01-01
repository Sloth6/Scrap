models = require '../../models'
mail = require '../adapters/nodemailer'
module.exports =
  
  # update the space name and save it to the db
  updateSpace : (sio, socket, data, spaceKey, callback) ->
    name = data.name

    query = "UPDATE \"Spaces\" SET"
    query += " \"name\"=:name"
    query += " WHERE \"spaceKey\"=:spaceKey RETURNING *"

    # new space to be filled in by update
    space = models.Space.build()
    
    models.sequelize.query(query, space, null, { name, spaceKey }).complete (err, res) ->
      return callback err if err?
      sio.to(spaceKey).emit 'updateSpace', { name: res.name, spaceKey }
      callback()

  addUserToSpace : (sio, socket, data, spaceKey, callback) ->
    email = data.email

    models.Space.find( where: { spaceKey }).complete (err, space) ->
      return callback err if err?
      models.User.find( where: { email }).complete (err, user) ->
        return callback err if err?
        mail.send {
          to: email
          subject: 'scrap'
          text: 'You have been invited to scrap!'
          html: '<b><p>You have been invited to scrap!<p></b>'
        }
        if user?
          add user, space
        else # no user
          models.User.create({ email }).complete (err, user) ->
            return callback err if err?   
            add user, space

    add = (user, space) ->
      space.hasUser(user).complete (err, hasUser) ->
        # make sure we don't add the user twice
        if not hasUser
          space.addUser(user).complete (err) ->
            return callback err if err?
            sio.to(spaceKey).emit 'addUserToSpace', { name: user.name }
            callback()
        else
          callback()

  removeUserFromSpace : (sio, socket, data, spaceKey, callback) ->
    id = data.id

    models.Space.find( where: { spaceKey }).complete (err, space) ->
      return callback err if err?
      models.User.find( where: { id }).complete (err, user) ->
        return callback err if err?
        if user?
          space.removeUser(user).complete (err) ->
            return callback err if err?
            sio.to(spaceKey).emit 'removeUserFromSpace', { id }
            callback()

