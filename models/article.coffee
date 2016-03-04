module.exports = (sequelize, DataTypes) ->
  Article = sequelize.define 'Article', {
    contentType:
      type: DataTypes.ENUM 'text', 'image', 'website', 'file', 'video', 'gif', 'soundcloud', 'mp3', 'youtube', 'pdf'
      allowNull: false
    content:
      type: DataTypes.JSON
      allowNull: false
  }, {
    classMethods:
      associate: (models) ->
        Article.belongsTo models.User, foreignKey: 'creatorId', as: 'Creator'
        Article.hasMany models.Collection
  }
