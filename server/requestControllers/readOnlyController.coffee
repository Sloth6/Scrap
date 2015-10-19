models = require '../../models'

readOnlyPage = (res, space) ->
  res.render 'read-only.jade',
    title : 'Hotpot · Here is a read-only space'
    description: ''
    author: 'scrap'
    collection: space
    names: { 1: "" }
    current_space:
      spaceKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    { spaceKey } = req.params
    currentUserId = req.session.currentUserId

    if currentUserId?
      console.log 'has userID'
      models.User.find(where: { id: currentUserId }).complete (err, user) ->
        return callback(err, res) if err?
        models.Space.find(where: { spaceKey }).complete (err, space) ->
          return callback(err, res) if err?
          console.log !!user, !!space
          return res.send 404 unless space?
          return readOnlyPage res unless user?

          space.hasUser(user).complete (err, hasUser) ->
            return res.redirect('/') if hasUser
              
            
              space.addUser(user).complete (err) ->
                return callback(err, res) if err?
                readOnlyPage res, space




    else
      # get space if exists
      models.Space.find(where: { spaceKey }).complete (err, space) ->
        return callback err if err
        return res.send 404 unless space?
        readOnlyPage(res, space)
               


        # space.hasUser(user).complete (err, hasUser) ->
        #   # make sure we don't add the user twice
        #   return res.send 200 if hasUser
