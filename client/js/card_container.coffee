margin = -0.5

card_container =
  children: () ->
    $(@).find('.card').not('.addElementForm')

  realign: () ->
    children = card_container.children.call @
    lastX = 0
    maxX  = -Infinity
    zIndex = children.length
    children.each () ->
      $(@).data 'scroll_offset', lastX
      $(@).css { zIndex: zIndex-- }
      card.place.call @
      lastX += $(@).width() + margin
      maxX  = lastX

    $(@).data { maxX }

  init: () ->
    # $(window).scrollLeft 0
    card_container.realign.call @

    # if not $(@).hasClass('fake')
    #   $(@).click collection_enter
    #   form = $(@).find('.direct-upload')
    #   form.fileupload fileuploadOptions $(@), $(@).data('spacekey')
  scroll: () ->
    children = card_container.children.call @
    children.each card.place
    # scroll_position = collection.data('scroll_position') + delta

    # scroll_position = Math.min scroll_position, $(window).width()/2 - children.first().width()/2
    # scroll_position = Math.max scroll_position, -collection.data('maxX') + $(window).width()/2 + children.last().width()/2

    # collection.data 'scroll_position', scroll_position
    # children.each element_place