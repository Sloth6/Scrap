module.exports = (sequelize, DataTypes) ->
  Element = sequelize.define 'Element', {
    contentType:
      type: DataTypes.ENUM 'text', 'image', 'website', 'file', 'video', 'gif', 'soundcloud', 'mp3', 'youtube', 'cover'
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
  }, {
    classMethods:
      associate: (models) ->
        Element.belongsTo models.User, foreignKey: 'creatorId', as: 'Creator'
        Element.belongsTo models.Space
  }
