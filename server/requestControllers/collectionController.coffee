models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
mime = require('mime')
moment = require('moment')
async = require 'async'
mail = require '../adapters/nodemailer'
request = require 'request'
domain = require('../config.json').domain
coverColor = require '../modules/coverColor'
newCollection = require '../newCollection'

config = 
  redirect_host:  "http://localhost:3000/" #Host to redirect after uploading
  host:  "s3.amazonaws.com" #S3 provider host
  max_filesize:  20971520 #Max filesize in bytes (default 20MB)

module.exports =
  # collectionData: (req, res, app, callback) ->
  #   { collectionKey } = req.params
  #   models.Collection.find({
  #     where: { collectionKey }, include:[ model:models.User ]
  #   }).complete (err, collection) ->
  #     return callback(err, res) if err?
  #     return res.send(400) unless collection?
  #     res.status(200).send collection

  collectionContent: (req, res, app, callback) ->
    { collectionKey } = req.params
    return res.send(400) unless collectionKey?
    models.Collection.find({
      where: { collectionKey }
      include:[ 
        model:models.Article
        { model:models.Collection, as: 'children', include: [model:models.Article] }
      ]
    }).complete (err, collection) ->
      return callback err, res if err?
      return callback "No collection found for '#{collectionKey}'", res unless collection?

      { articles, children, articleOrder } = collection

      articles.sort (a, b) ->
        if articleOrder.indexOf(a.id) > articleOrder.indexOf(b.id) then 1 else -1
      
      app.render 'partials/collectionContent', { collection: collection }, (err, html) ->
        return callback err if err?
        res.status(200).send html

  uploadFile : (req, res, app, callback) ->
    { type, title, collectionKey } = req.query
    title = title or 'undefined'
    console.log title, type, collectionKey

    expire = moment().utc().add('hour', 1).toJSON("YYYY-MM-DDTHH:mm:ss Z") # Set policy expire date +30 minutes in UTC
    file_key = uuid.v4() # Generate uuid for filename

    # Creates the JSON policy according to Amazon S3's CORS uploads specfication (http://aws.amazon.com/articles/1434)
    policy = JSON.stringify({
      "expiration": expire
      "conditions": [
        {"bucket": config.aws_bucket}
        ["eq", "$key", collectionKey + "/" + file_key + "/" + title]
        {"acl": "public-read"}
        {"success_action_status": "201"}
        ["starts-with", "$Content-Type", type]
        ["content-length-range", 0, config.max_filesize]
      ]
    })

    base64policy = new Buffer(policy).toString('base64'); # Create base64 policy
    signature = crypto.createHmac('sha1', config.aws_secret).update(base64policy).digest('base64'); # Create signature

    # Return JSON View
    res.json {
      policy: base64policy
      signature: signature
      path: (collectionKey + "/" + file_key + "/" + title)
      success_action_redirect: "/"
      contentType: type
    }
    callback()


