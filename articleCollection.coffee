# module.exports = (sequelize, DataTypes) ->
#   ArticleCollection = sequelize.define 'ArticleCollection', {
#     collection_id: {
#       type: DataTypes.INTEGER,
#       unique: 'item_article_collection'
#     }
#     article_id: {
#       type: DataTypes.INTEGER,
#       unique: 'item_article_collection',
#       references: null
#     }
#   }, {
#     classMethods:
#       associate: (models) ->
#         Article.belongsTo models.User, foreignKey: 'creatorId', as: 'Creator'
#         Article.hasMany models.Collection
#         Article.belongsToMany models.Collection, {
#           through: ['ArticleCollection']
#         }
#   }
