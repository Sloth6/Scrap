models = require '../../models'
spaceController = require './spaceController'
module.exports =
  
  # create a new user and default space, redirect to space
  newUser : (req, res, callback) ->
    { name, email, password } = req?.body?.user
    attributes = { name, email, password }

    models.User.find(where: { email }).complete (err, user) ->
      if user?
        if user.name? and user.password?
          return res.send 400, 'Duplicate email'

        user.updateAttributes({name, password}).complete (err) ->
          done user
      else
        models.User.create(attributes).complete (err, user) ->
          if err?
            if 'email' of err # not a valid email
              return res.send 400, 'LOGIN FAILED: not a valid email'
            if err.code == '23505' # not a unique email
              return res.send 400, 'LOGIN FAILED: not a unique email'
            return res.send 400, err
          else
            done user
      done = (user) ->
        req.session.currentUserId = user.id
        req.body.space =
          name: "Welcome"
        spaceController.newSpace req, res, callback

  # verify login creds, redirect to first space
  login : (req, res, callback) ->
    email = req.body.user.email
    password = req.body.user.password

    models.User.find(
      where: { email }
      include: [ models.Space ]
    ).complete (err, user) ->
      return res.send 400, err if err?
      res.send 400, "No account found for that email" if not user?
      if user?
        user.verifyPassword password, (err, result) ->
          return res.send 400, err if err?

          # render first space on success
          if result
            req.session.currentUserId = user.id
            res.redirect "/s/" + user.spaces[0].spaceKey
            callback()
          else
            return res.send 400, 'Incorrect password.'
      else
        

  logout : (req, res, callback) ->
    req.session.destroy (err) ->
      return callback err if err?
      res.redirect "/"
