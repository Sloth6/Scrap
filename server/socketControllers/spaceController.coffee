models = require '../../models'
mail = require '../adapters/nodemailer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )


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
    { email, name } = data
    name = toTitleCase name

    models.Space.find( where: { spaceKey }).complete (err, space) ->
      return callback err if err?
      models.User.find( where: { email }).complete (err, user) ->
        return callback err if err?

        hostUrl = "http://54.175.30.159:9001/"
        spaceNameWithLink = "<a href=\"#{hostUrl}s/#{spaceKey}\">#{space.name}</a>"
        subject = "#{name} invited you to #{space.name} on Scrap."
        html = "<h1>View #{spaceNameWithLink} on Scrap.</h1>
            <p>If you do not yet have an account, register with email '#{email}' to view.</p><br>
            <p><a href=\"#{hostUrl}\">Scrap</a> is a simple visual organization tool.</p>"

        mail.send {
          to: email
          subject: subject
          text: html
          html: html
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

