
collectionOpen = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children '.slider'
  spacekey = cover.data 'spacekey'
  history.pushState { name: "home" }, "", "/#{spacekey}"

  prevSliding = collection.prevAll().find('.cover.sliding').removeClass 'sliding'
  nextSliding = collection.nextAll().find('.cover.sliding').removeClass 'sliding'

  # Close anything else thats open
  $('.open').removeClass 'open'
  collection.removeClass('closed').addClass 'open'

  # Remember where we were  
  window.pastState.scrollLeft = $(window).scrollLeft()
  window.pastState.docWidth   = $(window.document).width()
  $(window).scrollLeft 0

  nextSliding.velocity
    properties:
      translateX: [$(window).width(), xForceFeedSelf ]

  prevSliding.velocity
    properties:
      translateX: [ ( () -> -$(@).width() ), xForceFeedSelf ]

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
  

  prevSliding = collection.prevAll().find('.cover.slider').addClass 'sliding'
  nextSliding = collection.nextAll().find('.cover.slider').addClass 'sliding'

  collection.removeClass('open').addClass 'closed'
  # collection.siblings().show()
  
  # elements to remove
  collectionContent.children().css 'zIndex', 0

  elements.
    removeClass('sliding')
    # css({ x: xTransform(cover) })

  collectionContent.
    show().
    velocity
      properties:
        opacity: [0, 1]

  $(document.body).css width: window.pastState.docWidth
  $(window).scrollLeft window.pastState.scrollLeft
  collectionRealignDontScale.call $('.slidingContainer')
  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration


  collectionRealign.call $('.slidingContainer')

collectionChildren = () ->
  children = $(@).find('.sliding')
  children
  # .filter () ->
  #   collection = $(@).parent().parent()
  #   $(@).hasClass('cover') or collection.hasClass('open') or collection.hasClass('closing')

collectionOfElement = () ->
  $(@).parent().parent()

collectionRealign = (animate) ->
  children = collectionChildren.call @
  lastX  = 0#edgeWidth
  maxX   = -Infinity
  zIndex = children.length

  children.each () ->
    $(@).data 'scroll_offset', lastX
    collection = $(@).parent().parent()
    $(@).css { zIndex: zIndex-- }
    $(@).removeData 'oldZIndex'
    slidingPlace.call @, animate
    width = $(@).width()
    if collection.hasClass('closing')
      width = 0
    lastX += width + margin
    
    maxX = lastX
  
  $(document.body).css { width: maxX }
  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration
  
  $(@).data { maxX }
 
collectionRealignDontScale = (animate) ->
  children = collectionChildren.call @
  lastX  = 0#edgeWidth
  maxX   = -Infinity
  zIndex = children.length

  children.each () ->
    $(@).data 'scroll_offset', lastX
    collection = $(@).parent().parent()
    $(@).css { zIndex: zIndex-- }
    $(@).removeData 'oldZIndex'
    slidingPlace.call @, animate
    width = $(@).width()
    if collection.hasClass('closing')
      width = 0
    lastX += width + margin
    maxX = lastX

  $(@).data { maxX }
 
collectionScroll = () ->
  children = collectionChildren.call(@)
  children.each () ->
    slidingPlace.call @, false
    # if $(@).hasClass('cover') and $(@).css('x') < edgeWidth
    #   # console.log 'on edgeWidth'


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