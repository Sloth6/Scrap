
# children_cache = null
card_container =
  children: () ->
    children = $(@).find('.sliding').filter () ->
      collection = $(@).parent().parent()
      $(@).hasClass('cover') or collection.hasClass('open') or collection.hasClass('closing')


  realign: (animate) ->
    children = card_container.children.call @
    lastX  = 0
    maxX   = -Infinity
    zIndex = children.length

    children.each () ->
      $(@).data 'scroll_offset', lastX
      collection = $(@).parent().parent()
      $(@).css { zIndex: zIndex-- }
      card.place.call @, animate
      width = $(@).width()
      # if $(@).is(":visible") or !
      if collection.hasClass('closing')
        width = 0
      lastX += width + margin
      
      maxX = lastX

    $(document.body).css { width: maxX }
    $(@).data { maxX }
   
  realign_dont_scale: (animate) ->
    children = card_container.children.call @
    lastX  = 0
    maxX   = -Infinity
    zIndex = children.length

    children.each () ->
      $(@).data 'scroll_offset', lastX
      collection = $(@).parent().parent()
      $(@).css { zIndex: zIndex-- }
      card.place.call @, animate
      width = $(@).width()
      if collection.hasClass('closing')
        width = 0
      lastX += width + margin
      maxX = lastX

    $(@).data { maxX }
   
  # init: () ->
  #   card_container.realign.call @
    # form = $(@).find('.direct-upload')
    # form.fileupload fileuploadOptions $(@), $(@).data('spacekey')


  scroll: () ->
    children = card_container.children.call @
    children.each () ->
      if $(@).is(":visible")
        card.place.call @, false
