cache = {}
loadElements = (spacekey, callback) ->
  return callback cache[spacekey] if cache[spacekey]
  $.get "/collectionContent/#{spacekey}", (data) ->
    console.log "got collection from #{spacekey}"
    cache[spacekey] = $(data)
    callback cache[spacekey]


collectionOpen = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  spacekey = cover.data 'spacekey'
  
  return if cover.hasClass 'open'

  loadElements spacekey, (elements) ->
    collectionContent.append elements
    sliderInit elements    
    addElementController.init collectionContent.find('.addElementForm')

    prevSliding = collection.prevAll().find('.cover.sliding').removeClass 'sliding'
    nextSliding = collection.nextAll().find('.cover.sliding').removeClass 'sliding'

    # Close anything else thats open
    $('.open').removeClass 'open'
    collection.removeClass('closed').addClass 'open'
    cover.addClass 'open'

    # Remember where we were  
    window.pastState.scrollLeft = $(window).scrollLeft()
    window.pastState.docWidth   = $(window.document).width()
    $(window).scrollLeft 0

    nextSliding.velocity
      properties:
        translateX: [$(window).width(), xForceFeedSelf ]
      options:
        complete: () -> nextSliding.hide()

    prevSliding.velocity
      properties:
        translateX: [ ( () -> -$(@).width() ), xForceFeedSelf ]
      options:
        complete: () -> prevSliding.hide()

    # add elements in collection to list of sliding elements.
    elements.
      addClass('sliding').
      css({ x: xTransform(cover) })

    collectionContent.
      show().
      velocity
        properties:
          opacity: [1, 0]

    collectionRealign.call $('.slidingContainer')

collectionClose = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children '.slider'
  spacekey = cover.data 'spacekey'
  
  collection.siblings().find('.cover.slider').addClass('sliding').show()
  
  # elements to remove
  collectionContent.children().css 'zIndex', 0
  elements.removeClass('sliding')

  collectionContent.
    show().
    velocity
      properties:
        opacity: [0, 1]
      options:
        complete: () ->
          collection.removeClass('open').addClass 'closed'
          cover.removeClass('open')
          elements.remove()

  $(document.body).css width: window.pastState.docWidth
  $(window).scrollLeft window.pastState.scrollLeft
  collectionRealignDontScale.call $('.slidingContainer')
  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration


  collectionRealign.call $('.slidingContainer')

collectionChildren = () ->
  $(@).find('.sliding')

collectionOfElement = () ->
  $(@).parent().parent()

realign = (animate) ->
  children = collectionChildren.call @
  lastX  = 0#$(window).width()/2 - children.first().width()/2
  maxX   = -Infinity
  zIndex = children.length
  
  children.each () ->
    $(@).data 'scroll_offset', lastX
    collection = $(@).parent().parent()
    
    if $(@).hasClass 'open'
      $(@).css { zIndex: (children.length*3) }
    else
      $(@).css { zIndex: zIndex-- } # Card stack order

    $(@).removeData 'oldZIndex'
    slidingPlace.call @, animate
    width = $(@).width()
    if collection.hasClass('closing')
      width = 0
    lastX += width + margin
  
  maxX = lastX - children.last().width()/2
  $(@).data { maxX }
  maxX

collectionRealign = (animate) ->
  maxX = realign.call @, animate
  $(document.body).css { width: maxX + $(window).width()/2}
  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration

collectionRealignDontScale = (animate) ->
  realign.call @, animate
 
collectionScroll = () ->
  children = collectionChildren.call(@)
  children.each () ->
    slidingPlace.call @, false

#  Old scrolling code

# placeHolder_under_mouse = (event) ->
#   collection = $(@)
#   element = collection_children.call(@).first()
#   # Get the element that the mouse is over
#   while mouse.x > (parseInt(element.css('x')) + element.width())
#     element = element.next()

#   if mouse.x < parseInt(element.css('x'))+ element.width()/2
#     collection_insert_before.call @, drag_placeholder, element
#   else 
#     collection_insert_after.call @, drag_placeholder, element
#   true

# # put element a before b
# collection_insert_before = (a, b) ->
#   collection = $(@)
#   a.insertBefore b
#   if a.parent() is b.parent()
#     collection_realign_elements.call a.parent().parent()
#   else
#     collection_realign_elements.call a.parent().parent()
#     collection_realign_elements.call b.parent().parent()

# collection_insert_after = (a, b) ->
#   collection = $(@)
#   a.insertAfter b
#   if a.parent() is b.parent()
#     collection_realign_elements.call a.parent().parent()
#   else
#     collection_realign_elements.call a.parent().parent()
#     collection_realign_elements.call b.parent().parent()