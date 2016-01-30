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
      unique: true
    color:
      type: DataTypes.TEXT
      defaultValue: coverColor
      allowNull: false
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
        # Collection.belongsToMany models.Article, {
        #   through: ['ArticleCollection']
        # }
  }
