uuid = require 'node-uuid'
coverColor = require('../server/modules/coverColor')
module.exports = (sequelize, DataTypes) ->
  Space = sequelize.define 'Space', {
    name:
      type: DataTypes.TEXT
      allowNull: false
    spaceKey:
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
    elementOrder:
      type: DataTypes.ARRAY(DataTypes.INTEGER)
      allowNull: false
      defaultValue: '{}'

  }, {

    classMethods:
      associate: (models) ->
        Space.hasMany models.User
        Space.hasMany models.Element

        Space.hasMany models.Space, { as: 'children' }
        Space.belongsTo models.Space, { as: 'parent', onDelete: 'CASCADE' }

        # Space.belongsTo models.Element, { as: 'coverId', foreignKey: 'coverId' }
        Space.belongsTo models.User, { as: 'Creator' }
  }
