models = require '../../models'
crypto = require 'crypto'
uuid = require('node-uuid')
mime = require('mime')
moment = require('moment')
async = require 'async'
welcomeElements = require '../welcomeElements'
mail = require '../adapters/nodemailer'
request = require 'request'
domain = require('../config.json').domain

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )

# collection_jade = null
# require('fs').readFile __dirname+'/../../views/partials/collection.jade', 'utf8', (err, data) ->
#   console.log err, data
#   # throw err if err
#   collection_jade = require('jade').compile data


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



# models.Space.find({ where: { spaceKey:'c751793f' }, include:[ {model:models.Element, raw:true}] }).complete (err, space) ->  
#   orderElements space

module.exports =
  addUserToSpace : (req, res, app, callback) ->
    { email, spaceKey } = req.body
    userName = req.session.userName
    console.log "#{userName} invited #{email} to #{spaceKey}"

    models.Space.find( where: { spaceKey }).complete (err, space) ->
      return callback err if err?
      models.User.find( where: { email }).complete (err, user) ->
        return callback err if err?

        spaceNameWithLink = "<a href=\"#{domain}s/#{spaceKey}\">#{space.name}</a>"
        subject = "#{userName} invited you to #{space.name} on Scrap."
        
        html = "<h1>View #{spaceNameWithLink} on Scrap.</h1>
            <p>If you do not yet have an account, register with email '#{email}' to view.</p><br>
            <p><a href=\"#{domain}\">Scrap</a> is a simple visual organization tool.</p>"

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
        return res.send 200 if hasUser
        space.addUser(user).complete (err) ->
          return callback err if err?
          res.send 200
          
  updateSpaceName: (req, res, app, callback) ->
    { spaceKey, name } = req.body
    console.log "changing name of #{spaceKey} to #{name}"
    models.Space.update({ name }, { spaceKey }).complete (err) ->
      return callback err if err
      res.send 200
      # sio.to("#{spaceKey}").emit 'updateElement', data
  
  collectionContent: (req, res, app, callback) ->
    { spaceKey } = req.params
    models.Space.find({ where: { spaceKey }, include:[ model:models.Element] }).complete (err, space) ->
      return callback err if err?
      { elements, elementOrder } = space
      elements.sort (a, b) ->
        if elementOrder.indexOf(a.id) > elementOrder.indexOf(b.id) then 1 else -1
      
      app.render 'partials/collectionContent', { collection: space }, (err, html) ->
        return callback err if err?
        res.status(200).send html

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
    });

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
