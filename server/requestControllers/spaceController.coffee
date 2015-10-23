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
newSpace = require '../newSpace'

config = 
  redirect_host:  "http://localhost:3000/" #Host to redirect after uploading
  host:  "s3.amazonaws.com" #S3 provider host
  max_filesize:  20971520 #Max filesize in bytes (default 20MB)

module.exports =
  collectionData: (req, res, app, callback) ->
    { spaceKey } = req.params
    models.Space.find({
      where: { spaceKey }, include:[ model:models.User ]
    }).complete (err, space) ->
      return callback(err, res) if err?
      return res.send(400) unless space?
      res.status(200).send space

  collectionContent: (req, res, app, callback) ->
    { spaceKey } = req.params
    console.log spaceKey
    models.Space.find({
      where: { spaceKey }, include:[ model:models.Element ]
    }).complete (err, space) ->
      return callback err, res if err?
      return callback "No space found for '#{spaceKey}'", res unless space?

      { elements, elementOrder } = space
      # console.log elementOrder, elements
      elements.sort (a, b) ->
        if elementOrder.indexOf(a.id) > elementOrder.indexOf(b.id) then 1 else -1
      
      app.render 'partials/collectionContent', { collection: space }, (err, html) ->
        return callback err if err?
        res.status(200).send html

  uploadFile : (req, res, app, callback) ->
    { type, title, spaceKey } = req.query
    title = title or 'undefined'
    console.log title, type, spaceKey

    expire = moment().utc().add('hour', 1).toJSON("YYYY-MM-DDTHH:mm:ss Z") # Set policy expire date +30 minutes in UTC
    file_key = uuid.v4() # Generate uuid for filename

    # Creates the JSON policy according to Amazon S3's CORS uploads specfication (http://aws.amazon.com/articles/1434)
    policy = JSON.stringify({
      "expiration": expire
      "conditions": [
        {"bucket": config.aws_bucket}
        ["eq", "$key", spaceKey + "/" + file_key + "/" + title]
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
      path: (spaceKey + "/" + file_key + "/" + title)
      success_action_redirect: "/"
      contentType: type
    }
    callback()


