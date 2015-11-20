models = require '../../models'

readOnlyPage = (res, collection) ->
  res.render 'read-only.jade',
    title : "#{collection.name} on Scrap"
    description: ''
    author: 'scrap'
    collection: collection
    names: { 1: "" }
    current_collection:
      collectionKey: 'index'

module.exports =
  index: (req, res, app, callback) ->
    { collectionKey } = req.params
    currentUserId = req.session.currentUserId
    
    models.Collection.find(where: { collectionKey }).complete (err, collection) ->
      return callback err if err
      return res.send(404) unless collection?
      return readOnlyPage(res, collection) unless currentUserId?
      q = 'select exists
            (select true from "CollectionsUsers" where "UserId"=? and "CollectionId"=?)'
      params = [ currentUserId, collection.id ]
      models.sequelize.query(q, null, { raw:true}, params).complete (err, results) ->
        return res.send(400) if err?
        return res.send(400) unless results?
        hasCollection = results[0].exists
        console.log 'results', results, hasCollection
        if hasCollection
          # in the future load them directly into collection
          return res.redirect('/')
        else
          readOnlyPage(res, collection)
