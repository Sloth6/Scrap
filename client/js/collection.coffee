cache = {}
realignTimeout = null
loadElements = (spacekey, callback) ->
  return callback 'ERR. spacekey not passed to loadElements' unless spacekey
  
  # return callback cache[spacekey] if cache[spacekey]
  $.get "/collectionContent/#{spacekey}", (data) ->
    cache[spacekey] = $(data)
    callback cache[spacekey]
    
transformCollection = (cover, collection) ->
  rotateZ=    ['0deg', cover.data('rotateZ')]
  translateY= [0, cover.data('translateY')]
  collection.velocity {
    rotateZ
    translateY
  }, {
    easing: openCollectionCurve
    duration: openCollectionDuration
  }
  
coverToCollection = (cover, elements) ->
  spacekey = cover.data('content')
  collection = $("<div>").
    addClass("collection open #{spacekey}").
    data({ spacekey }).
    insertBefore(cover).
    append cover
  collectionContent = $("<div>").
    addClass('collectionContent').
    appendTo(collection).
    append elements
  if not cover.hasClass 'root'
    transformCollection(cover, collection)
  collection

collectionOpen = (cover, options = {}, callback) ->
  # 'cover' is cover of opened collection (if the first level of notebook)
  # 'elements' are articles being loaded into new space
  return if cover.hasClass 'open'
  spacekey = cover.data('content')  
  console.log 'opens', spacekey
  spacePath.unshift(spacekey)
  dragging = options.dragging
  
  loadElements spacekey, (elements) ->
    parentCollection = $('.open.collection')
    parentCover = $('.open.cover, .open.stack')

    # Elements to left and right of opening collection
    prevSliding = cover.prevAll('.sliding')
    nextSliding = cover.nextAll('.sliding')

    collection = coverToCollection cover, elements    
    parentCollection.removeClass('open').addClass 'closed'
    parentCover.removeClass('open').addClass 'closed'
    cover.addClass('open').removeClass('draggable').removeClass('closed')
    prevSliding.removeClass 'sliding'
    nextSliding.removeClass 'sliding'
      
    if dragging?
      padding.insertAfter collection.find('.addElementForm')
    
    elements.addClass('sliding').css({ x: xTransform(cover) })
    sliderInit elements
          
    # Remember where we were  
    window.pastState.scrollLeft = $(window).scrollLeft()
    window.pastState.docWidth   = $(window.document).width()
    $(window).scrollLeft 0

    parentCover.velocity
      properties:
        translateX: [ (() -> -sliderWidth($(@))), xForceFeedSelf ]
      options: { complete: () -> parentCover.hide() }

    nextSliding.velocity
      properties:
        translateX: [ $(window).width() + coverMargin, xForceFeedSelf ]
        translateY: marginTop
        rotateZ: '0deg'
      options: { complete: () -> nextSliding.hide() }

    prevSliding.velocity
      properties:
        translateX: [ (() -> -sliderWidth($(@)) - coverMargin), xForceFeedSelf ]
        translateY: marginTop
        rotateZ: '0deg'
      options: { complete: () -> prevSliding.hide() }
    
    # If leaving root collection, 
    if parentCover.hasClass('root')
      # animate in back button
      $('header.main .backButton').addClass 'visible'
      moveBackButton(32)
      cover.data('rotateZ', 0)
      cover.data('translateY', marginTop)
      
    callback() if callback?

    collectionRealign()

collectionClose = (options = {}) ->
  draggingElement = options.draggingElement or null
  deleteAfter     = options.deleteAfter or null
  state           = options.state or null

  closingCover = $('.open.cover, .open.stack')
  sliderInit closingCover
  return if closingCover.hasClass 'root'
  spacePath.shift()

  closingCollection = closingCover.parent()
  closingChildren = collectionChildren()
 
  closingCollection.addClass('closed').removeClass('open')
  closingChildren.css('zIndex', 0).removeClass('sliding')

  parentCollection = closingCollection.parent().parent()
  parentChildren = collectionChildren parentCollection

  parentCover = parentCollection.children('.cover,.stack')
  parentSpacekey = parentCover.data('content')

  parentCollection.addClass('open').removeClass('closed')
  parentChildren.show().addClass 'sliding'
  parentCover.addClass('open').removeClass('closed')

  # If entering root collection, animate out back button
  if parentCover.hasClass('root')
    $('header.main .backButton').removeClass 'visible'
    moveBackButton(0)
  
  if draggingElement?
    draggingElement.
      removeClass('dragging').
      addClass('sliding').
      css({scale: 1, zIndex: draggingElement.data('oldZIndex')})
    draggingElement.insertAfter parentCollection.find('.addElementForm')    

    content = parentChildren.not('.addElementForm')
    elementOrder = JSON.stringify(content.get().map (elem) -> +elem.id)
    addToCollection(draggingElement, parentSpacekey)
    console.log "Emitting reorderElements"
    socket.emit 'reorderElements', { elementOrder, spaceKey: parentSpacekey }

  closingCollection.
    data('width', 0).
    children('.collectionContent').velocity {
      properties: { opacity: [0, 1] }
    }
  # console.log deleteAfter, closingCover
  unless deleteAfter
    closingCover.
      addClass('closed').
      removeClass('open').
      addClass('draggable').
      addClass('sliding').
      show().
      insertBefore closingCollection

    if closingCover.hasClass 'stack'
      stackPopulate closingCover

  # return to the parents state last time we were there.
  if state?
    $(document.body).css width: state.width
    $(window).scrollLeft state.scrollLeft
    $("body").css("overflow", "hidden")
  
  collectionRealignDontScale()
  setTimeout (() ->
    closingCollection.remove()
    $("body").css("overflow", "visible")
    # collectionRealignDontScale()
  ), openCollectionDuration

  $('.root.cover').hide()
  
collectionChildren = (collection) ->
  collection ?= $('.collection.open')
  cover = collection.children('.cover')
  elements = collection.children('.collectionContent').children('.element,.padding')
  elements.add cover

collectionParent = (collection) ->
  collection.parent().parent()

collectionOfElement = () ->
  $(@).parent().parent()

collectionWidth = () ->
  sliding = collectionChildren().filter('.sliding')
  w = 0
  sliding.each () ->
    w += sliderWidth($(@)) + margin
  w

realign = (animate) ->
  return if realignTimeout?
  clearTimeout realignTimeout
  realignTimeout = setTimeout (() -> realignTimeout = null), 100
  sliding = collectionChildren().filter('.sliding')
  lastX  = 0
  maxX   = -Infinity
  zIndex = sliding.length
  
  sliding.each () ->
    margin = coverMargin if $(@).hasClass 'cover'

    $(@).data 'scroll_offset', lastX
    collection = $(@).parent().parent()
    
    if $(@).hasClass('cover') and $(@).hasClass('open')
      $(@).css { zIndex: (sliding.length*3) }
    # If at root level and elem is add element form, to prevent form from being on top at root level
    else if $(@).hasClass('addElementForm') and not $('.root.open').length # (puts add element card at back on root level
      $(@).css { zIndex: (sliding.length*3) - 1 }
    else
      $(@).css { zIndex: zIndex++ }

    $(@).removeData 'oldZIndex'
    slidingPlace.call @, animate
    width = sliderWidth($(@))# or $(@).width()
    
    if collection.hasClass('closing')
      width = 0
    lastX += width + margin
  
  maxX = lastX# - sliderWidth(sliding.last())/2
  $(@).data { maxX }
  maxX

collectionRealign = (animate) ->
  width = collectionWidth $(@)
  width += margin
  $(document.body).css { width } #+ $(window).width()/2
  $(window).scrollLeft(width)
  maxX = realign.call @, animate
  $("body").css("overflow", "hidden")
  setTimeout (() -> $("body").css("overflow", "visible")), openCollectionDuration

collectionRealignDontScale = (animate) ->
  realign animate
 
collectionScroll = () ->
  collectionChildren().filter('.sliding').each () ->
    slidingPlace.call @, false

collectionElemAfter = (x) ->
  # Get the element that the mouse is over
  for html in collectionChildren().filter('.sliding').not('.addElementForm')
    child = $(html)
    if parseInt(child.css('x')) + sliderWidth(child) > x
      return child
  $()
  
moveBackButton = (x) ->
  $('header.main .backButton').velocity
    properties:
      translateX: x
    options:
      easing: openCollectionCurve
      duration: 1000
      
