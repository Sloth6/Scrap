$ ->
  $('.spacePreview.new').click ->
    elem = $(@)
    elem.removeClass('new')
    $.post '/s/new', { name: 'New Space' }, (spaceId) ->
      enterSpace spaceId, elem
      # $('.content').prepend('<div class="spacePreview new"><h1 class="spaceName">New Space</h1></div>')