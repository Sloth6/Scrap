models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
moment = require('moment')
async = require 'async'
config = require '../config.json'

module.exports =
  collectionContent: (req, res, app, callback) ->
    userId = req.session?.currentUserId
    o = parseInt(req.query.o)
    n = parseInt(req.query.n)
    collectionKey = req.query.collectionKey

    console.log { o, n, collectionKey }
    return res.send(400) unless (o and n and userId)?

    done = (articles) ->
      articles = articles.slice o, o+n #.reverse()
      console.log "Showing #{articles.length} articles"
      res.render 'partials/articles', { articles, host:config.HOST }

    articleOptions =
      model: models.Article,
      order: '"createdAt" DESC',
      include: [
        { model:models.Collection, required: false },
        { model:models.User, as: 'Creator'}
      ]

    if collectionKey != 'recent'
      options =
        where: { collectionKey }
        include: [ articleOptions ]
      models.Collection.find( options ).done (err, collection) ->
        return callback err, res if err?
        done collection.Articles
    else
      options =
        where: { id: userId }
        include: [ { model: models.Collection }, articleOptions ]
      models.User.find( options ).done (err, user) ->
        return callback err, res if err?
        done user.Articles


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
        {"bucket": config.S3.bucket}
        ["eq", "$key", path]
        {"acl": "public-read"}
        {"success_action_status": "201"}
        ["starts-with", "$Content-Type", type]
        ["content-length-range", 0, config.S3.maxFilesize]
      ]
    })
    base64policy = new Buffer(policy).toString('base64') # Create base64 policy
    signature = crypto.createHmac('sha1', config.S3.secretAccessKey).update(base64policy).digest('base64') # Create signature

    # Return JSON View
    res.json {
      policy: base64policy
      signature: signature
      path: path
      success_action_redirect: "/"
      contentType: type
    }
    callback null


