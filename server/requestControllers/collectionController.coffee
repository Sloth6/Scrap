models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
moment = require('moment')
async = require 'async'

config_path = __dirname+'/../config.json'
config = JSON.parse(require('fs').readFileSync(config_path, 'utf8'))

formatCollection = (collection) ->
  articles = collection.Articles or []
  children = collection.children or []

  collection.content = articles.concat children
  articleOrder       = collection.articleOrder      
        
  collection.content.sort (a, b) -> 
    if a instanceof models.Collection.Instance
      a_i = articleOrder.indexOf(a.collectionKey)
    else
      a_i = articleOrder.indexOf("#{a.id}")

    if b instanceof models.Collection.Instance
      b_i = articleOrder.indexOf(b.collectionKey)
    else
      b_i = articleOrder.indexOf("#{b.id}")

    if a_i > b_i then 1 else -1

  collection

module.exports =
  collectionContent: (req, res, app, callback) ->
    { collectionKey } = req.params
    return res.send(400) unless collectionKey?
    models.Collection.find({
      where: { collectionKey }
      include:[
        { model:models.Article }
        { model:models.Collection, as: 'children', include: [model:models.Article] }
      ]
    }).done (err, collection) ->
      return callback(err, res) if err?
      return callback "No collection found for '#{collectionKey}'", res unless collection?
      
      formatCollection collection

      unless collection.root
        for child in collection.children
          formatCollection child

      app.render 'partials/collectionContent', { collection }, (err, html) ->
        return callback err if err?
        res.status(200).send html
        callback null

  uploadFile : (req, res, app, callback) ->
    { title, type, collectionKey } = req.query
    title = title or 'undefined'
    
    expire = moment().utc().add('hour', 1).toJSON("YYYY-MM-DDTHH:mm:ss Z") # Set policy expire date +30 minutes in UTC
    file_key = uuid.v4().split('-')[0] # Generate uuid for filename
    path = "collections/#{collectionKey}/#{file_key}/#{title}"

    # Creates the JSON policy according to Amazon S3's CORS uploads specfication (http://aws.amazon.com/articles/1434)
    policy = JSON.stringify({
      "expiration": expire
      "conditions": [
        {"bucket": config.bucket}
        ["eq", "$key", path]
        {"acl": "public-read"}
        {"success_action_status": "201"}
        ["starts-with", "$Content-Type", type]
        ["content-length-range", 0, config.maxFilesize]
      ]
    })
    base64policy = new Buffer(policy).toString('base64') # Create base64 policy
    signature = crypto.createHmac('sha1', config.secretAccessKey).update(base64policy).digest('base64') # Create signature

    # Return JSON View
    res.json {
      policy: base64policy
      signature: signature
      path: path
      success_action_redirect: "/"
      contentType: type
    }
    callback null


