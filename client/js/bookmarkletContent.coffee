close = () ->
	parent.window.postMessage("removetheiframe", "*")

addCollection = ($collection) ->
	collectionKey = $collection.data 'collectionkey'
	# todo, post to server
	close()

$ ->
	console.log 'Hello world from bookmarklet iframe'
	$(".collection").click () ->
		console.log 'alldone!'
		addCollection($(@))


