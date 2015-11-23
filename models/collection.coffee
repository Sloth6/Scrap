uuid = require 'node-uuid'
coverColor = require('../server/modules/coverColor')
async = require 'async'
module.exports = (sequelize, DataTypes) ->
  Collection = sequelize.define 'Collection', {
    name:
      type: DataTypes.TEXT
      allowNull: true
    collectionKey:
      type: DataTypes.TEXT
      defaultValue: () -> uuid.v4().split('-')[0]
      allowNull: false
    root:
      type: DataTypes.BOOLEAN
      defaultValue: false
      allowNull: false
    publicRead:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: true
    color:
      type: DataTypes.TEXT
      defaultValue: coverColor
      allowNull: false
    hasCover:
      type: DataTypes.BOOLEAN
      allowNull: false
      defaultValue: false
    lastChange:
      type: DataTypes.DATE
      allowNull: false
      defaultValue: DataTypes.NOW
    articleOrder:
      type: DataTypes.ARRAY(DataTypes.TEXT)
      allowNull: false
      defaultValue: '{}'

  }, {
    classMethods:
      associate: (models) ->
        Collection.hasMany models.User
        Collection.hasMany models.Article
        Collection.hasMany models.Collection, { as: 'children' }
        Collection.belongsTo models.Collection, { as: 'parent', onDelete: 'CASCADE' }
        Collection.belongsTo models.User, { as: 'Creator' }

      # A new collection always has a creator and usually a parent.
      createAndInitialize: (params, user, parent, callback) ->
        Collection.create( params ).complete (err, collection) ->
          return callback err if err?
          async.parallel [
            (cb) -> collection.addUser(user).complete cb
            (cb) -> collection.setCreator(user).complete cb
            (cb) ->
              return cb(null) unless parent?
              collection.setParent(parent).complete cb
            (cb) ->
              return cb(null) unless parent?
              parent.addChildren(collection).complete cb
          ], (err) ->
            callback err, collection
  }
