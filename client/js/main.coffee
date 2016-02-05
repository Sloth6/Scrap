'use strict'

window.constants =
  style:
    gutter: 36
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
  velocity:
    easing:
      smooth: [20, 10]
      spring: [75, 10]
  dom:
    collectionsMenu: 'ul.collectionsMenu'
    articleContainer: '#articleContainer'
    collections: 'ul.collectionsMenu li.collection'

stopProp = (event) -> event.stopPropagation()

  
window.events =
  onCollectionOverArticle: (event, $collection) ->
    $article = $('article.hovered')
    $card = $article.children('.card')
    $color = $('<div></div>').appendTo('article')
#     $color.css
#     $article.css
#       opacity: .2

  onCollectionOutArticle: (event, $collection) ->
    $article = $('article.hovered')
    $card = $article.children('.card')
#     $article.css
#       opacity: .1

  onOpenCollectionsMenu: () ->
    $menu       = $(constants.dom.collectionsMenu )
    $container  = $(constants.dom.articleContainer)
    $menuItems  = $menu.children()
    $button     = $menu.find('.openMenuButton')
    $labelsButton = $menu.find('li.labelsButton')
    $labels     = $menuItems.not('li.labelsButton')
    $openLabel  = $menu.children(".#{window.openCollection}")
    $articleContents = $container.find('article .card').children().add($container.find('article ul, article .articleControls'))
    options     =
      duration: 1000
      easing:   constants.velocity.easing.smooth
    isHome      = window.openCollection is 'recent'
    $menu.addClass 'open'
    # animate in labels
    $labels.not($openLabel).find('.contents').css
      opacity: 0
    $menuItems.show()
    $.Velocity.hook($openLabel.find('.contents'), 'translateY', "#{-$openLabel.offset().top}px")
    $menu.css
      width: $menu.width()
    if isHome
      $labelsButton.find('.contents').velocity
        properties:
          translateY: -$button.height() * 3
#           scaleY: 2
#           scaleX: .125
#           rotateZ: 45 * (Math.random() - .5)
        options:
          duration: options.duration
          easing:   options.easing
          delay:    0
    $openLabel.removeClass('openMenuButton')   
    $labels.each ->
      $label = $(@)
      if $openLabel.index() is $label.index()
        translateY = -500
      else if $openLabel.index() < $label.index() # below
        translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
      else
        translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
#       scaleY = if $openLabel.index() is $label.index() then 1 else 2
#       scaleX = if $openLabel.index() is $label.index() then 1 else .125
#       rotateZ = if $openLabel.index() is $label.index() then 1 else 22 * (Math.random() - .5)
      $label.find('.contents').velocity
        properties:
          translateY: [-$button.height(), translateY]
#           scaleY: [1, scaleY]
#           scaleX: [1, scaleX]
#           rotateZ: [0, rotateZ]
          opacity: [1, 1]
        options:
          duration: options.duration # + ($label.index() * 60)
          easing:   options.easing
          delay:    $label.index() * 60
          begin: ->
            $label.css
              position: ''
              top: ''
    # hide articles
    $container.velocity
      properties:
        opacity: .5
      options: options
    $articleContents.velocity
      properties:
        opacity: 0
      options: options
    $menu.data 'canOpen', false

  onCloseCollectionsMenu: () ->
    isHome      = window.openCollection is 'recent'
    $menu       = $(constants.dom.collectionsMenu )
    $container  = $(constants.dom.articleContainer)
    $menuItems  = $menu.children()
    $oldButton     = $menu.find('.openMenuButton')
    $labelsButton = $menu.find('li.labelsButton')
    $dragging   = $menu.find 'ui-draggable-dragging'
    $labels     = $menuItems.not('.ui-draggable-dragging, .openMenuButton')
    $articleContents = $container.find('article .card').children().add($container.find('article ul, article .articleControls'))
    $destinationLabel  = if isHome then $labelsButton else $menu.children(".#{window.openCollection}")
    options     =
      duration: 500
      easing:   constants.velocity.easing.smooth
    
    $menu.removeClass 'open'

    if isHome
      $labelsButton.find('.content').velocity 'reverse', {
        delay: 60 * $labels.length
      }
    else
      $oldButton.removeClass('openMenuButton')
    $destinationLabel.addClass('openMenuButton')
    $destinationLabel.find('.contents').velocity
      properties:
        translateY: -$destinationLabel.offset().top
#         rotateZ: 0
#         scaleY: 1
#         scaleX: 1
      options:
        duration: options.duration
        easing:   options.easing
#         complete: ->
#           $destinationLabel.css
#             position: 'absolute'
#             top: 0
#           $.Velocity.hook($destinationLabel.find('.contents'), 'translateY', 0)
    $labels.not($destinationLabel).each ->
      $label = $(@)
      console.log $label.attr 'class'
      if $destinationLabel.index() < $label.index() # below
        translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
      else
        translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
      $label.find('.contents').velocity
        properties:
          translateY: translateY
#           scaleY: 2
#           scaleX: .125
#           rotateZ: 22 * (Math.random() - .5)
        options:
          duration: options.duration
          easing:   options.easing
          delay:    0 #60 * (($labels.length ) - $label.index())
          complete: ->
            if $label.index() is $labels.length - 1
              $menuItems.not('.openMenuButton, .ui-draggable-dragging').hide()
              $.Velocity.hook($destinationLabel.find('.contents'), 'translateY', 0)
              $menu.data 'canOpen', true
              if window.triedToOpen and $menu.is(':hover') # if user tried to open menu before ready, and is still hovering
                events.onOpenCollectionsMenu() # open menu after close animation finishes
                window.triedToOpen = false
    $container.velocity 'reverse'
    $articleContents.velocity 'reverse'

  onArticleResize: ($article) ->
    $(@).width $(@).children('.card').outerWidth()
    $(@).height $(@).children('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()

  # direction = ['up', 'down']
  onChangeScrollDirection: (direction) ->

  onSwitchToCollection: (collectionKey) ->
    $container  = $(constants.dom.articleContainer)
    $matched    = if collectionKey is 'recent' then $container.find('article') else $container.find("article.#{collectionKey}")
    $unmatched  = if collectionKey is 'recent' then $('')                      else $container.find('article').not(".#{collectionKey}")
    
    # Hide unmatched articles
    $unmatched.each ->
      $(@).velocity
        properties:
          translateY: $(window).height() * (Math.random() - .5)
          translateX: if ($(@).offset().left > $(window).width() / 2) then $(window).width() else -$(window).width()
          rotateZ: 90 * (Math.random() - .5)
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          complete: ->
            $(@).hide()
            $(constants.dom.articleContainer).packery()
    # Show matched articles
    $matched.show()
    $matched.css 'opacity', 0
    $container.packery
      transitionDuration: 0
    $matched.each ->
      startX = if ($(@).offset().left > $(window).width() / 2) then $(window).width() else -$(window).width()
      $(@).velocity
        properties:
          translateY: [0, $(window).height() * (Math.random() - .5)]
          translateX: [0, startX]
          rotateZ: [0, 90 * (Math.random() - .5)]
          opacity: [1, 0]
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          begin: -> $(@).show()
          complete: ->
            if $matched.index() is $matched.length - 1 # last article
              $container.packery
                transitionDuration: 500
    window.openCollection = collectionKey
    $container.packery()

  onResize: () ->

  onScroll: () ->

window.articleModel = 
  getCollectionKeys: ($article) ->
    keys = []
    for c in $article.find('.collection')
      if c.length
        keys.append(c.data('collectionkey'))
    keys
  
  addCollection: ($article, $collection) ->
    $article.addClass($collection.data('collectionkey'))
    $article.children('ul.articleCollections').append $collection

    articleId     = $article.attr 'id'
    collectionKey = $collection.data 'collectionkey'
    socket.emit 'addArticleCollection', { articleId, collectionKey }

  removeCollection: ($article, $collection) ->
    articleId     = $article.attr 'id'
    collectionKey = $collection.data 'collectionkey'
    
    $article.removeClass collectionKey
    $collection.remove()
    socket.emit 'removeArticleCollection', { articleId, collectionKey }

window.init =
  collection: ($collections) ->
    draggableOptions = 
      helper: "clone"
      revert: "true"
      start: (event, ui) ->
        events.onCloseCollectionsMenu()
        $(ui.helper).hover stopProp, stopProp
      stop: (event, ui) ->
        $(ui.helper).off 'hover'

    $collections.each ->
      $collection = $(@)
      $collection.zIndex(2).
        draggable(draggableOptions).
        find('a').click((event) ->
          collectionKey = $collection.data('collectionkey')
          events.onSwitchToCollection collectionKey
          events.onCloseCollectionsMenu()
          event.stopPropagation()
          event.preventDefault())
      $collection.css
        width: $(@).width()  
      console.log 'hi', $(@).width()
  #       mousedown ->
  #         console.log $collection
  #         # keep width the same on drag
  #         $(@).css
  #           width: $(@).width()  

  article: ($articles) ->
    $articles.each ->
      $(@).css
        paddingTop:  12 + Math.random() * constants.style.gutter
        paddingLeft: 12 + Math.random() * constants.style.gutter
    
    $articles.droppable
      greedy: true
      hoverClass: "hovered"
      over: (event, object) ->
        events.onCollectionOverArticle event, object.draggable
      out: (event, object) ->
        events.onCollectionOutArticle event, object.draggable
      drop: ( event, ui ) ->
        $collection = ui.draggable.clone()
        $collection.css 'top':0, 'left':0
        init.collection $collection
        $collection.show()
        articleModel.addCollection $(@), $collection
        event.stopPropagation()
        true
    
    $articles.each () -> events.onArticleResize($(@))
    $articles.find('img').load () -> 
      events.onArticleResize($(@))
      
  fancyHover: ->
    getProgressValues = ($element, scale) ->
      offsetX = $element.offset().left - $(window).scrollLeft()
      offsetY = $element.offset().top  - $(window).scrollTop()
      progressY = Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
      progressX = Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))      
      { x: progressX, y: progressY }
      
    getRotateValues = ($element, progress) ->
      maxRotateY = if $element.is('a') then 45 else 45
      maxRotateX = if $element.is('a') then 45 else 45
      rotateX = maxRotateY * (progress.y - .5)
      rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
      { x: rotateX, y: rotateY}
    
    $elements = $('#articleContainer article, ul.collectionsMenu li a, .addForm .headerButton a')
    easing = 
#     $scale = 
#     $elements.parent().css
#       'perspective': '400px'
#       '-webkit-perspective': '400px'
    $elements.each ->
      $element = $(@)
      $layers = $element.find('.parallaxLayer')
      scale = if $element.is('a') then 1.25 else 1.125
      perspective = if $element.is('a') then 400 else 800
      duration = 250
      $element.mouseenter (event) ->
        progress = getProgressValues($element, scale)
        rotate = getRotateValues($element, progress)
        $element.transition
          scale: scale
          easing: constants.style.easing
          duration: duration
        $element.css
          zIndex: 2
          perspective: perspective
        $element.parents('.contents').css
          zIndex: 2
        $layers.each ->
          depth = parseFloat $(@).data('parallaxdepth')
          scale =  (((scale - 1) + depth) / 2) + 1
          $(@).transition
            scale: scale
            easing: constants.style.easing
            duration: duration
      $element.mousemove (event) ->
        progress = getProgressValues($element, scale)
        rotate = getRotateValues($element, progress)
        $element.css
          scale: scale
          z: 250
          rotateX: "#{rotate.x}deg"
          rotateY: "#{rotate.y}deg"
        $layers.each ->
          depth = parseFloat $(@).data('parallaxdepth')
          offset = 50 * depth
          $(@).css
            x: offset * (-1 * (progress.x - .5))
            y: offset * (-1 * (progress.y - .5))
      $element.mouseleave ->
        $element.css
          zIndex: 0
        $element.parents('.contents').css
          zIndex: 0
        $element.transition
          scale: 1
          rotateX: 0
          rotateY: 0
          easing: constants.style.easing
          duration: duration
        $layers.each ->
          $(@).transition
            scale: 1
            x: 0
            y: 0
            easing: constants.style.easing
            duration: duration
    

  container: ($container) ->
    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      gutter: 0 #constants.style.gutter

    $container.packery 'bindResize'

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleModel.removeCollection $collection.parent().parent(), $collection

  addCollectionForm: () ->
    $('#newCollectionForm').submit (event) ->
      name = $('#newCollectionForm [type=text]').val()
      $('#newCollectionForm [type=text]').val ''
      socket.emit 'addCollection', { name }
      event.preventDefault()

  collectionsMenu: ($menu) ->
    # cycle colors on Recents
    $menu.find('li.recent a, li.labelsButton a').each ->
      hue = Math.floor(Math.random() * 360)
      $a = $(@)
      setInterval ->
        hue += 30
        $a.css '-webkit-text-fill-color', "hsl(#{hue},100%,75%)"
      , 1000
    $menu.find('li a').click (event) ->
      if $(@).parents('li').hasClass('openMenuButton') # only run if is the current open menu button
        event.stopPropagation()
        if $menu.data('canOpen') # ready to open (i.e., not in middle of close animation)
          events.onOpenCollectionsMenu()
        else # not ready to open
          window.triedToOpen = true # register attempt to open
    $('body').click ->
      events.onCloseCollectionsMenu() if $menu.hasClass 'open'
    $menu.find('li').not('.openMenuButton').hide()
    $menu.data 'canOpen', true
    
$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  init.article $("article")
  init.container $( constants.dom.articleContainer )
  init.collection $( constants.dom.collections )
  init.collectionsMenu $( constants.dom.collectionsMenu )
  init.addCollectionForm()
  init.fancyHover()
  initAddArticleForm()

  $('article').each () ->
    switch $(@).data 'contenttype'
      when 'text'       then initText $(@)
      when 'video'      then initVideo $(@)
      when 'file'       then initFile $(@)
      when 'soundcloud' then initSoundCloud $(@)
      when 'youtube'    then initYoutube $(@)

  # $('article').zoomTarget {
  #   duration: 450
  #   targetsize: 0.9    
  # }

  $(window).resize -> events.onResize()
  events.onResize()
  $(window).scroll -> events.onScroll()
  events.onScroll()

  # if draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie



