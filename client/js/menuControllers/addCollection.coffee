# $ ->
  # $('.addCollectionButton').click () ->

addCollection = () ->
  name = 'New Space' + $('.collection').length
  post = $.post '/s/new', {space:{ name }}, (dom) ->
    collection = $(dom)
    top = $('.collection').length * collection.height()
    collection.css { top }
    $('.collections').append collection
    collection_init.call collection


checkForNewCollection = () ->
	if $('.elements').get().every((e) -> $(e).children().length)
		console.log 'adding new collection'
		addCollection()