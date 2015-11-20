uuid = require 'node-uuid'
coverColor = require('../server/modules/coverColor')
module.exports = (sequelize, DataTypes) ->
  Collection = sequelize.define 'Collection', {
    name:
      type: DataTypes.TEXT
      allowNull: false
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
      type: DataTypes.ARRAY(DataTypes.INTEGER)
      allowNull: false
      defaultValue: '{}'

  }, {

    classMethods:
      associate: (models) ->
        Collection.hasMany models.User
        Collection.hasMany models.Article

        Collection.hasMany models.Collection, { as: 'children' }
        Collection.belongsTo models.Collection, { as: 'parent', onDelete: 'CASCADE' }

        # Collection.belongsTo models.Article, { as: 'coverId', foreignKey: 'coverId' }
        Collection.belongsTo models.User, { as: 'Creator' }
  }
