models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
mime = require('mime')
moment = require('moment')
async = require 'async'
welcomeElements = require '../welcomeElements'

mail = require '../adapters/nodemailer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )


request = require 'request'
cheerio = require 'cheerio'

config = 
  aws_key:  "AKIAJKJJR5OLTKWMMHSA" #AWS Key
  aws_secret:  "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" #AWS Secret
  aws_bucket:  "scrapimagesteamnap" #AWS Bucket
  redirect_host:  "http://localhost:3000/" #Host to redirect after uploading
  host:  "s3.amazonaws.com" #S3 provider host
  max_filesize:  20971520 #Max filesize in bytes (default 20MB)

nameMap = (space) ->
  map = {}
  for user in space.users
    map[user.id] = user.name
  map

module.exports =
  # create a new space and redirect to it
  newSpace : (req, res, callback) ->
    spaceKey = uuid.v4().split('-')[0]
    { name, welcomeSpace } = req.body
    currentUserId = req.session.currentUserId
    
    models.User.find(
      where: { id: currentUserId }
      include: [ models.Space ]
    ).complete (err, user) ->
      return res.send 400 if err?
      attributes = { name, spaceKey, publicRead:true }
      models.Space.create( attributes ).complete (err, space) ->
        return res.send 400 if err?
        space.addUser(user).complete (err) ->
          return res.send 400 if err?
          space.setCreator(user).complete (err) ->
            return res.send 400 if err?
            # if welcomeSpace
            #   createWelcomePage space, (err) ->
            #     return callback err if err?
            #     res.redirect "/s/" + spaceKey
            # else
            #   res. redirect "/s/" + spaceKey
            res.status(200).send spaceKey

    createWelcomePage = (space, callback) ->
      async.each welcomeElements, (attributes, cb) ->
        attributes.SpaceId = space.id
        models.Element.create(attributes).complete cb
      , callback

  #when the space url is accessed
  showReadOnly : (req, res) ->
    showReadOnly = (space) ->
      res.render 'publicSpace.jade',
        title : "#{space.name} on Hotpot"
        current_space: space
        names: nameMap space

    currentUserId = req.session.currentUserId
    models.Space.find(
      where: { spaceKey: req.params.spaceKey }
      include: [ models.Element, models.User, { model: models.User, as: 'Creator' } ]
    ).complete (err, space) ->
      return res.redirect '/' unless space?
      return showReadOnly space unless currentUserId?

      models.User.find(
        where: { id: currentUserId }
        include: [ models.Space ]
      ).complete (err, user) ->
        return callback err if err?
        space.hasUser(user).complete (err, hasAccess) ->
          return callback err if err?
          # if the user was invited to the space
          if hasAccess
            res.redirect "/"#?key=#{space.spaceId}"
          else #or if they just got the link
            showReadOnly space

  #when the meta-space loads a space in an iframe
  showSpace: (req, res) ->
    currentUserId = req.session.currentUserId
    return res.send(400) unless currentUserId?
    models.Space.find(
      where: { spaceKey: req.params.spaceKey }
      include: [ models.Element, models.User, { model: models.User, as: 'Creator' } ]
    ).complete (err, space) ->
      # If the space does not exist
      return res.send(404) unless space
      models.User.find(
        where: { id: currentUserId }
        include: [ models.Space ]
      ).complete (err, user) ->
        return res.send 400 if err
        users = (space.users.map (u) -> { name: u.name, id: u.id, email: u.email })
        res.render 'space.jade',
          title : "#{space.name} on Hotpot"
          current_space: space
          current_user: user
          users: users
          names: nameMap space

  webPreview: (req, res) ->
    models.Space.find(
      where: { spaceKey: req.params.spaceKey }
      include: [ models.Element, models.User, { model: models.User, as: 'Creator' } ]
    ).complete (err, space) ->
      res.render 'previewSpace.jade',
        title : "#{space.name} on Hotpot"
        current_space: space
        names: {}

  # update the space name and save it to the db
  updateSpace : (req, res) ->
    { name, spaceKey } = req.body

    query = "UPDATE \"Spaces\" SET"
    query += " \"name\"=:name"
    query += " WHERE \"spaceKey\"=:spaceKey RETURNING *"

    # new space to be filled in by update
    space = models.Space.build()
    
    models.sequelize.query(query, space, null, { name, spaceKey }).complete (err) ->
      return res.send 400 if err?
      return res.send 200

  addUserToSpace : (req, res) ->
    { email, name } = data
    name = toTitleCase name

    models.Space.find( where: { spaceKey }).complete (err, space) ->
      return callback err if err?
      models.User.find( where: { email }).complete (err, user) ->
        return callback err if err?

        hostUrl = "http://54.86.238.114:9001/"
        spaceNameWithLink = "<a href=\"#{hostUrl}s/#{spaceKey}\">#{space.name}</a>"
        subject = "#{name} invited you to #{space.name} on Scrap."
        html = "<h1>View #{spaceNameWithLink} on Scrap.</h1>
            <p>If you do not yet have an account, register with email '#{email}' to view.</p><br>
            <p><a href=\"#{hostUrl}\">Scrap</a> is a simple visual organization tool.</p>"

        mail.send {
          to: email
          subject: subject
          text: html
          html: html
        }
        if user?
          add user, space
        else # no user
          models.User.create({ email }).complete (err, user) ->
            return callback err if err?   
            add user, space

    add = (user, space) ->
      space.hasUser(user).complete (err, hasUser) ->
        # make sure we don't add the user twice
        if not hasUser
          space.addUser(user).complete (err) ->
            return callback err if err?
            sio.to(spaceKey).emit 'addUserToSpace', { name: user.name }
            callback()
        else
          callback()

  # removeUserFromSpace : (req, res) ->
  #   id = data.id

  #   models.Space.find( where: { spaceKey }).complete (err, space) ->
  #     return callback err if err?
  #     models.User.find( where: { id }).complete (err, user) ->
  #       return callback err if err?
  #       if user?
  #         space.removeUser(user).complete (err) ->
  #           return callback err if err?
  #           # sio.to(spaceKey).emit 'removeUserFromSpace', { id }
  #           # callback()

  uploadFile : (req, res, callback) ->
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
    });

    base64policy = new Buffer(policy).toString('base64'); # Create base64 policy
    signature = crypto.createHmac('sha1', config.aws_secret).update(base64policy).digest('base64'); # Create signature

    # Return JSON View
    res.json {
      policy: base64policy
      signature: signature
      key: (spaceKey + "/" + file_key + "/" + title)
      success_action_redirect: "/"
      contentType: type
    }
    callback()
