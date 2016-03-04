models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
moment = require('moment')
async = require 'async'

config_path = __dirname+'/../config.json'
config = JSON.parse(require('fs').readFileSync(config_path, 'utf8'))

module.exports =
  collectionContent: (req, res, app, callback) ->
    userId = req.session?.currentUserId
    o = parseInt(req.query.o)
    n = parseInt(req.query.n)
    console.log { o, n }
    return res.send(400) unless (o and n and userId)?

    options =
      where: { id: userId }
      include: [
        { model: models.Collection },
        {
          model: models.Article,
          order: '"createdAt" ASC',
          include: [
            { model:models.Collection, required: false },
            { model:models.User, as: 'Creator'}
          ]
        }
      ]
    models.User.find( options ).done (err, user) ->
      return callback err, res if err?
      return indexPage res unless user?

      # user.Articles.reverse()
      user.Articles = user.Articles.slice(o, o+n)

      collections = {}
      for collection in user.Collections
        key = collection.collectionKey
        collections[key] = collection.dataValues

      console.log "Showing #{user.Articles.length} articles"

      res.render 'partials/articles', { user }
      # app.render 'partials/articles', { user }, (err, html) ->
      #   return callback err if err?
      #   res.status(200).send html
      #   callback null

  uploadFile : (req, res, app, callback) ->
    userId = req.session.currentUserId
    { title, type } = req.query
    title = title or 'undefined'

    expire = moment().utc().add('hour', 1).toJSON("YYYY-MM-DDTHH:mm:ss Z") # Set policy expire date +30 minutes in UTC
    file_key = uuid.v4().split('-')[0] # Generate uuid for filename
    path = "users/#{userId}/#{file_key}/#{title}"

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


