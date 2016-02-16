$ ->
  initCollection       $( constants.dom.collections )
  initCollectionsMenu  $( constants.dom.collectionsMenu )
  
  $('li.recent a, li.labelsButton a').each ->
    $(@).data('hue', Math.floor(Math.random() * 360))
    rotateColor $(@), $(@).data('hue')
    
  setInterval ->
    $('li.recent a, li.labelsButton a').each ->
      $(@).data('hue', $(@).data('hue') + 30)
      rotateColor $(@), $(@).data('hue')
  , 1000

window.initCollection = ($collections) ->
  draggableOptions = 
    helper: "clone"
    revert: "true"
    start: (event, ui) ->
      events.onCloseCollectionsMenu()
      $(ui.helper).find('a').trigger('mouseleave').velocity
        properties:
          scale: .5
          rotateX: 0
          rotateY: 0
          translateX: 0
          translateY: 0
        options:
          queue: false
          easing: constants.velocity.easing.spring
          duration: 250
      $(ui.helper).hover stopProp, stopProp
    stop: (event, ui) ->
      $(ui.helper).off 'hover'
  $collections.each ->
    $collection = $(@)
    $collection.zIndex(2).
      draggable(draggableOptions).
      find('a').click((event) ->
        event.stopPropagation()
        event.preventDefault()
        collectionKey = $collection.data('collectionkey')
        events.onSwitchToCollection collectionKey
        events.onCloseCollectionsMenu()
      )
    $collection.css
      width: $(@).width()
  parallaxHover $collections.find('a')

window.initCollectionsMenu = ($menu) ->  
  $menu.find('li a').click (event) ->
    event.stopPropagation()
    if $(@).parents('li').hasClass('openMenuButton') # only run if is the current open menu button
      if $menu.data('canOpen') # ready to open (i.e., not in middle of close animation)
        events.onOpenCollectionsMenu()
      else # not ready to open
        window.triedToOpen = true # register attempt to open
  $('body').click ->
    events.onCloseCollectionsMenu() if $menu.hasClass 'open'
  $menu.find('li').not('.openMenuButton').hide()
  $menu.data 'canOpen', true
