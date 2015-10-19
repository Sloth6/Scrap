models = require '../models'
errorHandler = require './errorHandler'
fs = require 'fs'
path = require 'path'

controllers = {}
fs.readdirSync(__dirname + '/requestControllers').forEach (fileName) ->
  if fileName.match /.coffee$/
    controllerName = fileName.slice(0, -7)
    pathName = path.join __dirname, '/requestControllers', controllerName
    controllers[controllerName] = require(pathName)

module.exports = (app) ->
  app.get '/', (req,res) ->
    controllers.indexController.index req, res, app, errorHandler

  app.post '/s/new', (req, res) ->
    controllers.spaceController.newSpace req, res, app, errorHandler

  app.post '/s/update', (req, res) ->
    controllers.spaceController.updateSpace req, res, app, errorHandler

  # app.post '/addUserToSpace', (req, res) ->
  #   controllers.spaceController.addUserToSpace req, res, app, errorHandler

  app.post '/updateSpaceName', (req, res) ->
    controllers.spaceController.updateSpaceName req, res, app, errorHandler

  app.get '/collectionContent/:spaceKey', (req, res) ->
    controllers.spaceController.collectionContent req, res, app, errorHandler

  app.get '/collectionData/:spaceKey', (req, res) ->
    controllers.spaceController.collectionData req, res, app, errorHandler

  app.get '/s/:spaceKey', (req, res) ->
    res.redirect '/'
    # controllers.readOnlyController.index req, res, app, errorHandler

  app.post '/login', (req, res) ->
    controllers.userController.login req, res, app, errorHandler

  app.get '/logout', (req, res) ->
    controllers.userController.logout req, res, app, errorHandler

  app.post '/register', (req, res) ->
    controllers.userController.newUser req, res, app, errorHandler

  app.post '/updateUser', (req, res) ->
    controllers.userController.updateUser req, res, app, errorHandler

  app.get '/sign_s3', (req, res) ->
    controllers.spaceController.uploadFile req, res, app, errorHandler
    
  app.get '/500', (req, res) ->
    throw new Error 'This is a 500 Error'

  app.get '/*', (req, res) ->
    res.redirect '/'
    # res.status 404
    # res.render '404', { url: req.url }
    # console.log 'Failed to get', req.url

  NotFound = (msg) ->
    this.name = 'NotFound'
    Error.call this, msg
    Error.captureStackTrace this, arguments.callee