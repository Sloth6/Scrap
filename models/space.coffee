module.exports = (sequelize, DataTypes) ->
  Space = sequelize.define 'Space', {
    name:
      type: DataTypes.TEXT
      allowNull: false
    spaceKey:
      type: DataTypes.TEXT
      allowNull: false
    colorOrder:
      type: DataTypes.ARRAY(DataTypes.INTEGER)
      allowNull: false
    publicRead:
      type: DataTypes.BOOLEAN
      allowNull: false
      default: true
    lastChange:
      type: DataTypes.DATE
      allowNull: false
      defaultValue: DataTypes.NOW
  }, {
    classMethods:
      associate: (models) ->
        Space.hasMany models.User
        Space.hasMany models.Element
        Space.belongsTo models.User, {as: 'Creator'}
  }
