models = require '../../models'
collectionController = require './collectionController'

module.exports =
  updateUser: (req, res, app)  ->
    { userId, name, email, password } = req.body
    attributes = { userId }
    attributes.name = name if name
    attributes.email = email if email
    attributes.password = password if password
    models.User.find(where: { id: userId }).then (user) ->
      return res.send(400) unless user?
      user.updateAttributes(attributes).then () ->
        # return res.send 400 if err?
        return res.send 200

  # create a new user and default collection, redirect to collection
  newUser : (req, res, app, callback) ->
    { name, email, password } = req?.body
    attributes = { name, email, password }

    models.User.find(where: { email }).done (err, user) ->
      console.log err, !!user
      if user?
        if user.name? and user.password?
          return res.status(400).send 'Duplicate email'
        # if name and password are not send the user was unvited by email.
        user.updateAttributes({name, password}).then () ->
          done user
      else
        models.User.createAndInitialize attributes, (err, user) ->
          if err?
            if 'email' of err # not a valid email
              return res.status(400).send 'Not a valid email'
            if err.code == '23505' # not a unique email
              return res.status(400).send 'Not a unique email'
            return res.status(400).send err
          else
            done user
      done = (user) ->
        req.session.currentUserId = user.id
        req.session.userName = user.name
        req.session.userEmail = user.email
        res.send "/"
        callback null

  # verify login creds, redirect to first collection
  login : (req, res, app, callback) ->
    email = req.body.email
    password = req.body.password
    console.log 'trying login', email, password
    models.User.find(
      where: { email }
      include: [ models.Collection ]
    ).done (err, user) ->
      return res.status(400).send if err?
      return res.status(400).send "No account found for that email" if not user?
      return res.status(400).send "Sign up to activate this account" if user? and !user.password
      user.verifyPassword password, (err, result) ->
        return res.status(400).send err if err?
        # render first collection on success
        if result
          req.session.currentUserId = user.id
          req.session.userName = user.name
          req.session.userEmail = user.email
          res.send "/"#"/s/" + user.collections[0].collectionKey
          callback()
        else
          callback null
          return res.status(400).send 'Incorrect password.'

  logout : (req, res, app, callback) ->
    req.session.destroy (err) ->
      return callback err if err?
      callback null
      res.redirect "/"
