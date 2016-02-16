'use strict'

window.constants =
  style:
    gutter: 48
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
    globalScale: 1/2
    duration:
      openArticle: 1000
  velocity:
    easing:
      smooth: [20, 10]
      spring: [75, 10]
  dom:
    nav: 'nav.main'
    collectionsMenu: 'ul.collectionsMenu'
    articleContainer: '#articleContainer'
    collections: 'ul.collectionsMenu li.collection'

stopProp = (event) -> event.stopPropagation()
  
window.events =
  onArticleLoad: ($article) ->
    if $article.hasClass('playable')
      $article.find('.artist', '.source').css
        position: 'absolute'
        opacity: 0
      $.Velocity.hook($article.find('.artist', '.source'), 'scale', '0')
      
  onArticleMouseenter: (event, $article) ->
    $article.find('ul.articleCollections').css
      zIndex: 2
    if $article.hasClass('playable')
      $button = $article.find('.playButton')
      x = $button.offset().left - $(window).scrollLeft()
      y = $button.offset().top  - $(window).scrollTop()
      $button.data('startPos', {x: x, y: y})
      $button.transition
        x: (event.clientX * (1/1)) - x - $button.width()  / 2
        y: (event.clientY * (1/1)) - y - $button.height() / 2
        easing: constants.style.easing
        duration: 250
      $article.css
        cursor: 'none'
      $article.find('.artist, .source').velocity
        properties:
          opacity: 1
          scale: 1
        options:
          easing: constants.velocity.easing.smooth
          duration: 500
  
  onArticleMousemove: (event, $article) ->
    if $article.hasClass('playable')
      $button = $article.find('.playButton')
      $button.css
        x: (event.clientX) - $button.data('startPos').x - $button.width()  / 2
        y: (event.clientY) - $button.data('startPos').y - $button.height() / 2

  onArticleMouseleave: (event, $article) ->
    $article.find('ul.articleCollections').css
      zIndex: ''
    if $article.hasClass('playable')
      $('.playButton').transition
        x: 0
        y: 0
        easing: constants.style.easing
        duration: 250
      $article.css
        cursor: 'none'
      $article.find('.artist, .source').velocity
        properties:
          opacity: 0
          scale: 0
        options:
          easing: constants.velocity.easing.smooth
          duration: 500
        
  onArticleOpen: (event, $article) ->
    event.stopPropagation()
    obscureArticles ($(constants.dom.articleContainer).find('article').not($article))
    $container = $(constants.dom.articleContainer)
    scale = 1 / constants.style.globalScale
    offset = # distance of article top/left to window top/left
      x: $article.offset().left - $(window).scrollLeft()
      y: $article.offset().top  - $(window).scrollTop()
    $container.velocity
      properties:
        translateX: ($(window).width() / 2)  - (scale * offset.x) - ($article.outerWidth()  / 2)
        translateY: ($(window).height() / 2) - (scale * offset.y) - ($article.outerHeight() / 2)
        scale: 1
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
        complete: ->
          events.onArticleResize $article
    $article.trigger 'mouseleave'
    $article.addClass 'open'
    $article.css # must run after trigger('mouseleave')
      zIndex: 2
    hideNav()

  onArticleClose: (event, $article) ->
    unobscureArticles ($(constants.dom.articleContainer).find('article').not($article))
    $container = $(constants.dom.articleContainer)
    $article.removeClass 'open'
    if $article.hasClass('playable')
      stopPlaying $article
    $container.velocity
      properties:
        translateX: 0
        translateY: 0
        scale:      constants.style.globalScale
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
    extendNav()

  onArticleResize: ($article) ->
    $article.width  $article.children('.card').outerWidth()
    $article.height $article.children('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()
  
  onCollectionOverArticle: ($article, event, $collection) ->
    $card = $article.children('.card')
    console.log 'over!'
    $color = $('<div></div>').appendTo($article).addClass('backgroundColor').css
      position: 'absolute'
      zIndex: -1
      top: 0
      left: 0
      right: 0
      bottom: 0
      backgroundColor: $collection.find('a').css '-webkit-text-fill-color'
    $article.find('.card').transition
      'mix-blend-mode': 'multiply'
      '-webkit-filter': 'grayscale(1)'
      duration: 500
      easing: constants.style.easing

  onCollectionOutArticle: ($article, event, $collection) ->
    $('.backgroundColor').remove()
    $article.find('.card').transition
      '-webkit-filter': ''
      duration: 500
      easing: constants.style.easing

  onOpenCollectionsMenu: () ->
    $menu       = $(constants.dom.collectionsMenu )
    $container  = $(constants.dom.articleContainer)
    $menuItems  = $menu.children()
    $button     = $menu.find('.openMenuButton')
    $labelsButton = $menu.find('li.labelsButton')
    $labels     = $menuItems.not('li.labelsButton')
    $openLabel  = $menu.children(".#{window.openCollection}")
    options     =
      duration: 1000
      easing:   constants.velocity.easing.smooth
    isHome      = window.openCollection is 'recent'
    $menu.addClass 'open'
    # animate in labels
    $labels.not($openLabel).find('.contents').css
      opacity: 0
    $menuItems.show()
    console.log 'OPEN MENU'
    $.Velocity.hook($openLabel.find('.contents'), 'translateY', "#{-$openLabel.offset().top}px")
    $menu.css
      width: $menu.width()
    if isHome
      $labelsButton.find('.contents').velocity
        properties:
          translateY: -$button.height() * 3
          scaleY: 2
          scaleX: .125
          rotateZ: 45 * (Math.random() - .5)
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
      scaleY = if $openLabel.index() is $label.index() then 1 else 2
      scaleX = if $openLabel.index() is $label.index() then 1 else .125
      rotateZ = if $openLabel.index() is $label.index() then 1 else 22 * (Math.random() - .5)
      $label.find('.contents').velocity
        properties:
          translateY: [-$button.height(), translateY]
          scaleY: [1, scaleY]
          scaleX: [1, scaleX]
          rotateZ: [0, rotateZ]
          opacity: [1, 1]
        options:
          duration: options.duration # + ($label.index() * 60)
          easing:   options.easing
          delay:    $label.index() * 60
          begin: ->
            $label.css
              position: ''
              top: ''
          complete: ->
            $menu.data 'canOpen', false
    obscureArticles $container.find('article')
    extendNav()

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
        rotateZ: 0
        scaleY: 1
        scaleX: 1
      options:
        duration: options.duration
        easing:   options.easing
    $destinationLabel.find('span').trigger('mouseleave')
    $labels.not($destinationLabel).each ->
      $label = $(@)
      if $destinationLabel.index() < $label.index() # below
        translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
      else
        translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
      $label.find('.contents').velocity
        properties:
          translateY: translateY
          scaleY: 2
          scaleX: .125
          rotateZ: 22 * (Math.random() - .5)
        options:
          duration: options.duration
          easing:   options.easing
          delay:    0 #60 * (($labels.length ) - $label.index())
          complete: ->
            if $label.index() is $labels.length - 1
              $menuItems.not('.openMenuButton, .ui-draggable-dragging').hide()
              $.Velocity.hook($destinationLabel.find('.contents'), 'translateY', 0)
              $menu.data 'canOpen', true
#               if window.triedToOpen and $menu.is(':hover') # if user tried to open menu before ready, and is still hovering
#                 events.onOpenCollectionsMenu() # open menu after close animation finishes
#                 window.triedToOpen = false
    unobscureArticles $container.find('article')
    extendNav()

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

      

$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'
  $(window).resize -> events.onResize()
  events.onResize()
  
  initAddArticleForm()

  # if  draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie



