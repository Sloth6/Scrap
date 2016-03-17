models = require '../models'
errorHandler = require './errorHandler'
fs = require 'fs'
path = require 'path'
config = require './config'

controllers = {}
fs.readdirSync(__dirname + '/requestControllers').forEach (fileName) ->
  if fileName.match /.coffee$/
    controllerName = fileName.slice(0, -7)
    pathName = path.join __dirname, '/requestControllers', controllerName
    controllers[controllerName] = require(pathName)

module.exports = (app) ->
  app.get '/', (req,res) ->
    controllers.indexController.index req, res, app, errorHandler

  app.get '/collectionContent', (req, res) ->
    controllers.collectionController.collectionContent req, res, app, errorHandler

  app.get '/sign_s3', (req, res) ->
    controllers.collectionController.uploadFile req, res, app, errorHandler

  app.get '/s/:collectionKey', (req, res) ->
    controllers.readOnlyController.index req, res, app, errorHandler

  app.post '/login', (req, res) ->
    controllers.userController.login req, res, app, errorHandler

  app.get '/logout', (req, res) ->
    controllers.userController.logout req, res, app, errorHandler

  app.post '/register', (req, res) ->
    controllers.userController.newUser req, res, app, errorHandler

  app.post '/updateUser', (req, res) ->
    controllers.userController.updateUser req, res, app, errorHandler

  app.post '/addArticleCollection', (req, res) ->
    controllers.extensionsControllers.addArticleCollection req, res, app, errorHandler

  app.get '/bookmarklet', (req, res) ->
    res.render('partials/bookmarklet', { HOST: config.HOST })

  app.get '/bookmarkletContent', (req, res) ->
    controllers.extensionsControllers.bookmarklet req, res, app, errorHandler

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
