models = require '../../models'
spaceController = require './spaceController'
newSpace = require '../newSpace'

module.exports =
  updateUser: (req, res, app)  ->
    { userId, name, email, password } = req.body
    attributes = { userId }
    attributes.name = name if name
    attributes.email = email if email
    attributes.password = password if password
    models.User.find(where: { id: userId }).complete (err, user) ->
      return res.send(400) unless user?
      user.updateAttributes(attributes).complete (err) ->
        console.log err
        return res.send 400 if err?
        return res.send 200

  # create a new user and default space, redirect to space
  newUser : (req, res, app, callback) ->
    { name, email, password } = req?.body
    attributes = { name, email, password }

    models.User.find(where: { email }).complete (err, user) ->
      if user?
        if user.name? and user.password?
          return res.status(400).send 'Duplicate email'

        user.updateAttributes({name, password}).complete (err) ->
          done user
      else
        models.User.create(attributes).complete (err, user) ->
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
        # create the users root space
        firstSpaceOptions =
          UserId: user.id
          spaceName: user.name
          root: true
        newSpace firstSpaceOptions, (err) ->
          return callback err if err?
          req.session.currentUserId = user.id
          req.session.userName = user.name
          req.session.userEmail = user.email
          res.send "/"
          # res.render 'home.jade', { user, title: 'Scrap' }

  # verify login creds, redirect to first space
  login : (req, res, app, callback) ->
    email = req.body.email
    password = req.body.password
    console.log 'trying login', email, password
    models.User.find(
      where: { email }
      include: [ models.Space ]
    ).complete (err, user) ->
      console.log err, !!user
      return res.status(400).send if err?
      return res.status(400).send "No account found for that email" if not user?
      return res.status(400).send "Sign up to activate this account" if user? and !user.password
      user.verifyPassword password, (err, result) ->
        return res.status(400).send err if err?
        # render first space on success
        if result
          req.session.currentUserId = user.id
          req.session.userName = user.name
          req.session.userEmail = user.email
          res.send "/"#"/s/" + user.spaces[0].spaceKey
          callback()
        else
          console.log 'Incorrect password'
          # res.status 400
          return res.status(400).send 'Incorrect password.'

  logout : (req, res, app, callback) ->
    req.session.destroy (err) ->
      return callback err if err?
      res.redirect "/"
