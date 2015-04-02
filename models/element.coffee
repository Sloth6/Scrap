module.exports = (sequelize, DataTypes) ->
  Element = sequelize.define 'Element', {
    contentType:
      type: DataTypes.ENUM 'text', 'image', 'website', 'file', 'video', 'gif'
      allowNull: false
    content:
      type: DataTypes.TEXT
      allowNull: false
    preview:
      type: DataTypes.TEXT
      allowNull: true
    caption:
      type: DataTypes.TEXT
      allowNull: true
    x:
      type: DataTypes.INTEGER
      allowNull: false
    y:
      type: DataTypes.INTEGER
      allowNull: false
    z:
      type: DataTypes.INTEGER
      allowNull: false
    scale:
      type: DataTypes.FLOAT
      allowNull: false
  }, {
    classMethods:
      associate: (models) ->
        Element.belongsTo models.User, foreignKey: 'creatorId', as: 'Creator'
        Element.belongsTo models.Space
  }
