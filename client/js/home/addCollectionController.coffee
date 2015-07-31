$ ->
  $('.addCollectionButton').click () ->
    name = 'New Space' + $('.collection').length
    post = $.post '/s/new', { name }, (dom) ->
      collection = $(dom)
      top = $('.collection').length * collection.height()
      collection.css { top }
      $('.collections').append collection
      collection_init.call collection
