models = require '../../models'
module.exports = 
	addArticleCollection: (sio, socket, data, callback) ->
		{ articleId, collectionKey } = data
		console.log 'addArticleCollection', data
		models.Collection.find(where: { collectionKey }).done (err, collection) ->
			return callback err if err?
			models.Article.find(where: { id: articleId }).done (err, article) ->
				return callback err if err?
				article.addCollection(collection).done (err) ->
					return callback err if err?
					collection.addArticle(article).done callback

			# q = """
			# 			INSERT INTO "ArticlesCollections" ("CollectionId", "ArticleId")
			# 				VALUES ( :collectionId, :articleId)
			# 		"""
			# replacements = { articleId, collectionId: collection.id }
			# models.sequelize.query(q, {replacements}).done callback


	removeArticleCollection: (sio, socket, data, callback) ->
		{ articleId, collectionKey } = data
		console.log 'removeArticleCollection', data

		models.Collection.find(where: { collectionKey }).done (err, collection) ->
			return callback(err) if err?
			models.Article.find(where: { id: articleId }).done (err, article) ->
				return callback(err) if err?
				article.removeCollection(collection).done (err) ->
					return callback(err) if err?
					collection.removeArticle(article).done (err) ->
						return callback(err) if err?
						callback null

		# q = """
		# 			DELETE FROM "ArticlesCollections"
		# 			WHERE 'CollectionId'=:collectionId and 'ArticleId'=articleId 
		# 		"""
