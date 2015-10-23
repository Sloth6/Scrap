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
    
    models.Space.find(where: { spaceKey }).complete (err, space) ->
      return callback err if err
      return res.send(404) unless space?
      return readOnlyPage(res, space) unless currentUserId?
      q = 'select exists
            (select true from "SpacesUsers" where "UserId"=? and "SpaceId"=?)'
      params = [ currentUserId, space.id ]
      models.sequelize.query(q, null, { raw:true}, params).complete (err, results) ->
        return res.send(400) if err?
        return res.send(400) unless results?
        hasSpace = results[0].exists
        console.log 'results', results, hasSpace
        if hasSpace
          # in the future load them directly into space
          return res.redirect('/')
        else
          readOnlyPage(res, space)
