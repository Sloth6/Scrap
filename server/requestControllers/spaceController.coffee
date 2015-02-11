models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
mime = require('mime')
moment = require('moment')
async = require 'async'
welcomeElements = require '../welcomeElements'

request = require 'request'
cheerio = require 'cheerio'

config = 
  aws_key:  "AKIAJKJJR5OLTKWMMHSA" #AWS Key
  aws_secret:  "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" #AWS Secret
  aws_bucket:  "scrapimagesteamnap" #AWS Bucket
  redirect_host:  "http://localhost:3000/" #Host to redirect after uploading
  host:  "s3.amazonaws.com" #S3 provider host
  bucket_dir:  "uploads/";
  max_filesize:  20971520 #Max filesize in bytes (default 20MB)

module.exports =
  # create a new space and redirect to it
  newSpace : (req, res, callback) ->
    spaceKey = uuid.v4().split('-')[0]
    { name, welcomeSpace } = req.body.space
    currentUserId = req.session.currentUserId
    
    models.User.find(
      where: { id: currentUserId }
      include: [ models.Space ]
    ).complete (err, user) ->
      return callback err if err?
      models.Space.create( { name, spaceKey, publicRead:true } ).complete (err, space) ->
        return callback err if err?
        space.addUser(user).complete (err) ->
          return callback err if err?
          space.setCreator(user).complete (err) ->
            return callback err if err?
            if welcomeSpace
              createWelcomePage space, (err) ->
                return callback err if err?
                res.redirect "/s/" + spaceKey
            else
              res. redirect "/s/" + spaceKey

    createWelcomePage = (space, callback) ->
      async.each welcomeElements, (attributes, cb) ->
        attributes.SpaceId = space.id
        models.Element.create(attributes).complete cb
      , callback

  showSpace : (req, res, callback) ->
    models.Space.find(
      where: { spaceKey: req.params.spaceKey }
      include: [ models.Element, models.User, { model: models.User, as: 'Creator' } ]
    ).complete (err, space) ->
      return callback err if err?
      return res.redirect '/' unless space?
      currentUserId = req.session.currentUserId
      
      if not currentUserId?
        if space.publicRead
          showReadOnly(space)
        else 
          res.redirect '/'
      else
        models.User.find(
          where: { id: currentUserId }
          include: [ models.Space ]
        ).complete (err, user) ->
          return callback err if err?
          space.hasUser(user).complete (err, hasAccess) ->
            return callback err if err?
            if hasAccess
              show space, user
            else if space.publicSpace
              showReadOnly space
            else res.redirect '/'

    colorMap = (space) ->
      map = {}
      n_colors = 10
      for i in [0...space.users.length]
        id = space.users[i].id
        map[id] = i%n_colors
      map

    nameMap = (space) ->
      map = {}
      for user in space.users
        map[user.id] = user.name
      map
      
    showReadOnly = (space) ->
      # console.log 'render read only'
      res.render 'publicSpace.jade',
        title : space.name
        current_space: space
        colors: colorMap space
        names: nameMap space

    show = (space, user) ->
      # console.log 'render private space'
      # console.log JSON.stringify(space.elements.map ({contentType, content, scale, x, y}) -> {contentType, content, scale, x, y})
      users = (space.users.map (u) -> { name: u.name, id: u.id, email: u.email })
      # console.log space.elements
      res.render 'space.jade',
        title : space.name
        current_space: space
        current_user: user
        users: users
        colors: colorMap space
        names: nameMap space

          
  uploadFile : (req, res, callback) ->
    mime_type = mime.lookup(req.query.title) # Uses node-mime to detect mime-type based on file extension
    expire = moment().utc().add('hour', 1).toJSON("YYYY-MM-DDTHH:mm:ss Z") # Set policy expire date +30 minutes in UTC
    file_key = uuid.v4() # Generate uuid for filename

    # Creates the JSON policy according to Amazon S3's CORS uploads specfication (http://aws.amazon.com/articles/1434)
    policy = JSON.stringify({
      "expiration": expire
      "conditions": [
        {"bucket": config.aws_bucket}
        ["eq", "$key", config.bucket_dir + file_key + "_" + req.query.title]
        {"acl": "public-read"}
        {"success_action_status": "201"}
        ["starts-with", "$Content-Type", mime_type]
        ["content-length-range", 0, config.max_filesize]
      ]
    });

    base64policy = new Buffer(policy).toString('base64'); # Create base64 policy
    signature = crypto.createHmac('sha1', config.aws_secret).update(base64policy).digest('base64'); # Create signature

    # Return JSON View
    res.json {
      policy: base64policy
      signature: signature
      key: (config.bucket_dir + file_key + "_" + req.query.title)
      success_action_redirect: "/"
      contentType: mime_type
    }
    callback()
