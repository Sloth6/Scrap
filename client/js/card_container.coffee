margin = -0.5

card_container =
  children: () ->
    $(@).children('.sliding')
    # $(@).find('.sliddingdingContainer,.slidding')

  realign: () ->
    children = card_container.children.call @
    lastX = 0
    maxX  = -Infinity
    zIndex = children.length

    animateOptions =
      duration: 1000
      opacity: 1.0

    children.each () ->
      $(@).data 'scroll_offset', lastX
      $(@).css { zIndex: zIndex-- }
      card.place.call @, animateOptions
      width = $(@).width() * $(@).is(":visible")
      lastX += width + margin
      
      maxX = lastX

    window.dontScroll = true
    $(document.body).css { width: maxX+100 }
    $(@).data { maxX }

  init: () ->
    card_container.realign.call @
    # form = $(@).find('.direct-upload')
    # form.fileupload fileuploadOptions $(@), $(@).data('spacekey')


  scroll: () ->
    children = card_container.children.call @
    children.each () -> card.place.call @
