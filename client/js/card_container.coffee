margin = 50

card_container =
  children: () ->
    $(@).find('.sliding').filter () ->
      collection = $(@).parent().parent()
      $(@).hasClass('cover') or collection.hasClass('open') or collection.hasClass('closing')

  realign: () ->
    children = card_container.children.call @
    lastX  = 0
    maxX   = -Infinity
    zIndex = children.length

    # console.log 'realigning',window.oldScroll, $(window).scrollLeft()
    animateOptions =
      duration: 1000
      opacity: 1.0

    children.each () ->
      $(@).data 'scroll_offset', lastX
      collection = $(@).parent().parent()
      $(@).css { zIndex: zIndex-- }
      card.place.call @, animateOptions
      width = $(@).width()
      # if $(@).is(":visible") or !
      if collection.hasClass('closing')
        width = 0
      lastX += width + margin
      
      maxX = lastX

    window.dontScroll = true
    $(document.body).css { width: maxX }

    $(@).data { maxX }

    # children.each () ->
      

  init: () ->
    card_container.realign.call @
    # form = $(@).find('.direct-upload')
    # form.fileupload fileuploadOptions $(@), $(@).data('spacekey')


  scroll: () ->
    children = card_container.children.call @
    children.each () ->
      if $(@).is(":visible")
        card.place.call @
