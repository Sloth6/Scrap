margin = -0.5

card_container =
  children: () ->
    $(@).children()
    # $(@).find('.sliddingdingContainer,.slidding')

  realign: (animateOptions = null) ->
    children = card_container.children.call @
    lastX = 0
    maxX  = -Infinity
    zIndex = children.length

    children.each () ->
      $(@).data 'scroll_offset', lastX
      $(@).css { zIndex: zIndex-- }
      card.place.call @, animateOptions
      width = $(@).width() * $(@).is(":visible")
      lastX += width + margin
      
      maxX = lastX

    window.dontScroll = true
    $(document.body).css { width: maxX }
    $(@).data { maxX }

  init: () ->
    card_container.realign.call @
    # form = $(@).find('.direct-upload')
    # form.fileupload fileuploadOptions $(@), $(@).data('spacekey')

  open: () ->

    # width = content.
    # spacekey = collection.data 'spacekey'

    # id = setInterval (() -> card_container.realign.call $('.collections')), 20
    # $(@).animate {width: "200vw"}, 1000, () ->
    #   clearInterval id

      # card_container.realign.call $('.collections')
    # history.pushState {name: ""}, "", "/#{spacekey}"
    # collection.addClass('open').removeClass 'closed'

  scroll: () ->
    children = card_container.children.call @
    children.each () -> card.place.call @
