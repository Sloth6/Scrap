window.contentControllers ?= {}
contentControllers.website =
	init: ($article) ->
	open: ($article) ->
		url = decodeURIComponent($article.data('content').url)
		articleView.mouseleave $article
		window.open url,'_blank'

