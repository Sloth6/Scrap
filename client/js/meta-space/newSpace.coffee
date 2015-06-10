$ ->
  $('.spacePreview.add').click ->
    elem = $(@)
    $('.spacePreview.add').addClass('new')
    elem.removeClass('add')
# 
    $.post '/s/new', { name: 'New Space' }, (spaceId) ->
      enterSpace spaceId, elem