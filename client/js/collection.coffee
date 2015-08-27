
collectionOpen = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children 'article'
  spacekey = cover.data 'spacekey'
  history.pushState { name: "home" }, "", "/#{spacekey}"

  # cover.removeClass 'sliding'
  # cover.css { 'position': 'absolute', 'z-index': 999 }
  
  # Close anything else thats open
  $('.open').removeClass 'open'
  collection.removeClass('closed').addClass 'open'

  # Remember where we were  
  window.pastState.scrollLeft = $(window).scrollLeft()
  window.pastState.docWidth   = $(window.document).width()
  $(window).scrollLeft 0

  collection.siblings().hide()
  collectionContent.show()
  
  elements.css { x: xTransform(cover) }

  # cover.velocity
  #   properties:
  #     translateX: [- cover.width() + edgeWidth,  xTransform(cover)]
  #   options:
  #     duration: openCollectionDuration
  #     queue: false
  #     easing:openCollectionCurve
  #     complete: () ->
  #       cover.addClass 'atEdge'

  collectionContent.velocity
    properties:
      opacity: [1, 0]
    options:
      duration: openCollectionDuration
      easing: openCollectionCurve

  collectionRealign.call $('.slidingContainer')

collectionClose = (cover) ->
  collection = cover.parent()
  collectionContent = collection.children '.collectionContent'
  elements = collectionContent.children 'article'
  spacekey = cover.data 'spacekey'
  
  # 
  cover.addClass 'sliding'
  cover.removeClass 'atEdge'

  collection.removeClass('open').addClass 'closed'
  collection.siblings().show()
  
  # elements to remove
  collectionContent.children().css 'zIndex', 0
  collectionContent.hide()

  console.log 'setting scroll to:', window.pastState.scrollLeft
  $(document.body).css width: window.pastState.docWidth
  $(window).scrollLeft window.pastState.scrollLeft
  collectionRealignDontScale.call $('.slidingContainer')
  console.log $(window).scrollLeft()
  # $("body").css("overflow", "hidden")
  # setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration

  collection.siblings().velocity
    properties:
      opacity: [1, 0]
    options:
      duration:   openCollectionDuration
      easing:     openCollectionCurve

  # $(@).velocity({
  #         rotateZ : 0
  # }, {
  #         duration : openCollectionDuration,
  #         easing : openCollectionCurve
  # })

  # $elements.velocity({
  #         rotateZ : 0
  #         translateY : 0;
  # }, {
  #         duration : openCollectionDuration,
  #         easing : openCollectionCurve
  # })

collectionChildren = () ->
  children = $(@).find('.sliding').filter () ->
    collection = $(@).parent().parent()
    $(@).hasClass('cover') or collection.hasClass('open') or collection.hasClass('closing')

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
    slidingPlace.call @, animate
    width = $(@).width()
    if collection.hasClass('closing')
      width = 0
    lastX += width + margin
    maxX = lastX

  $(@).data { maxX }
 
collectionScroll = () ->
  collectionChildren.call(@).each () ->
    slidingPlace.call @, false
    # if $(@).hasClass('cover') and $(@).css('x') < edgeWidth
    #   # console.log 'on edgeWidth'

  # padding = $('<div>').addClass('padding').addClass('sliding').css('width', $('.cover').width())
  # collectionContent.append padding

  
  # collectionContent.css 'opacity', 1

  # collectionContent.velocity
  #   properties:
  #     translateZ: 0
  #     opacity:    0
  #   options:
  #     duration:   openCollectionDuration
  #     easing:     openCollectionCurve
  #     complete: () ->
  #       collectionContent.hide()
  #       collectionContent.css 'opacity', 1
  #       collectionContent.children().removeClass 'collapsing'
  #       cover.removeClass 'collapsing'
  #       padding.remove()

  # elements.velocity
  #   properties:
  #     translateZ: 0
  #     translateY: 0
  #     translateX: 0
  #     rotateZ:    0
  #   options:
  #     duration:   openCollectionDuration
  #     easing:     openCollectionCurve
  

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