fs = require 'fs'
path = require 'path'
Sequelize = require 'sequelize'
lodash = require 'lodash'
psq_url = process.env.POSTGRES_URL || 'postgres://localhost/scrapdb'
sequelize = new Sequelize(psq_url, {logging: ->})
db = {}

fs.readdirSync(__dirname).filter((file) ->
  (file.indexOf '.' isnt 0) and (file isnt 'index.coffee')
  ).forEach (file) ->
    model = sequelize.import path.join __dirname, file
    db[model.name] = model

Object.keys(db).forEach (modelName) ->
  if 'associate' of db[modelName]
    db[modelName].associate db

module.exports = lodash.extend {
  sequelize,
  Sequelize
}, db
