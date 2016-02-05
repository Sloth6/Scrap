
close = () ->
	parent.window.postMessage("removetheiframe", "*")

addCollection = ($collection) ->
	collectionKey = $collection.data 'collectionkey'
	console.log "addCollection #{collectionKey} to #{articleId}"
	
	host = document.location.host
	$.post("http://localhost:9001/addArticleCollection", { articleId, collectionKey }).
		fail(() ->
			console.log 'Failed to addCollection'
		).
		always close
		

$ ->
	console.log 'Hello world from bookmarklet iframe'
	console.log "The articleId is #{articleId}"
	$(".collection").click () ->
		console.log 'alldone!'
		addCollection($(@))


