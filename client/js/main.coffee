'use strict'

window.constants =
  style:
    gutter: 36
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

obscureArticles = ($articles) ->
  $contents = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
  options     =
    duration: constants.style.duration.openArticle
    easing:   constants.velocity.easing.smooth
#   $articles.velocity
#     properties:
#       opacity: .125
#     options: options
  $contents.velocity
    properties:
      opacity: 0
#       blur: 5
    options: options
  $articles.addClass 'obscured'
    
unobscureArticles = ($articles) ->
  $contents = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
  options     =
    duration: constants.style.duration.openArticle
    easing:   constants.velocity.easing.smooth
#   $articles.velocity
#     properties:
#       opacity: 1
#     options: options
  $contents.velocity
    properties:
      opacity: 1
#       blur: 0
    options: options
  $articles.removeClass 'obscured'
  
hideNav = ->
  $sections = $(constants.dom.nav).children()
  unless $(constants.dom.collectionsMenu).hasClass('open')
    $sections.each ->
      $(@).velocity
        properties:
          translateY: -$(@).height()*1.25
        options:
          duration: 1000
          easing: constants.velocity.easing.smooth
          
retractNav = ->
  $sections = $(constants.dom.nav).children()
  unless $(constants.dom.collectionsMenu).hasClass('open')
    $sections.each ->
      translateY = if $(@).hasClass('center') then -$(@).height()*1.25 / 2 else -$(@).height()*1.25
      $(@).velocity
        properties:
          translateY: translateY
        options:
          duration: 1000
          easing: constants.velocity.easing.smooth

extendNav = ->
  $sections = $(constants.dom.nav).children()
  $sections.velocity
    properties:
      translateY: 0
    options:
      duration: 1000
#       queue: false
      easing: constants.velocity.easing.smooth
  
window.events =
  onArticleLoad: ($article) ->
    if $article.hasClass('playable')
      $article.find('.artist', '.source').css
        position: 'absolute'
        opacity: 0
      $.Velocity.hook($article.find('.artist', '.source'), 'scale', '0')
      
  onArticleMouseenter: (event, $article) ->
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
        x: (event.clientX * (1/1)) - $button.data('startPos').x - $button.width()  / 2
        y: (event.clientY * (1/1)) - $button.data('startPos').y - $button.height() / 2

  onArticleMouseleave: (event, $article) ->
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
    offset = 
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
    $color = $('<div></div>').appendTo('article')
    $article.css
      opacity: .2

  onCollectionOutArticle: ($article, event, $collection) ->
    $card = $article.children('.card')
    $article.css
      opacity: 1

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
              if window.triedToOpen and $menu.is(':hover') # if user tried to open menu before ready, and is still hovering
                events.onOpenCollectionsMenu() # open menu after close animation finishes
                window.triedToOpen = false
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

  onScroll: () ->
    scrollTop = $(window).scrollTop()
    
    # detect direction change
    if window.oldScrollTop isnt scrollTop
      if window.oldScrollTop < scrollTop
        if window.scrollDirection isnt 'down'
          events.onChangeScrollDirection 'down'
      else
        if window.scrollDirection isnt 'up'
          events.onChangeScrollDirection 'up'
      window.oldScrollTop = scrollTop
    if scrollTop <= 10
      extendNav() unless $('nav').children().hasClass('velocity-animating')
    else
      unless window.scrollDirection is 'up'
        retractNav() unless $('nav').children().hasClass('velocity-animating')
        
  onChangeScrollDirection: (direction) ->
    window.scrollDirection = direction
    if $(window).scrollTop() > 10
      if direction is 'up'
        extendNav()
      else
        retractNav()

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
          event.stopPropagation()
          event.preventDefault()
          collectionKey = $collection.data('collectionkey')
          events.onSwitchToCollection collectionKey
          events.onCloseCollectionsMenu()
        )
      $collection.css
        width: $(@).width()  

  article: ($articles) ->
    $articles.each ->
      $(@).css
        marginTop:  12 + Math.random() * constants.style.gutter
        marginLeft: 12 + Math.random() * constants.style.gutter
    
    $articles.droppable
      greedy: true
      hoverClass: "hovered"
      over: (event, object) ->
        events.onCollectionOverArticle $(@), event, object.draggable
      out: (event, object) ->
        events.onCollectionOutArticle $(@), event, object.draggable
      drop: ( event, ui ) ->
        $collection = ui.draggable.clone()
        $collection.css 'top':0, 'left':0
        $.Velocity.hook($collection.find('.contents'), 'translateY', "0px")
        init.collection $collection
        $collection.show()
        articleModel.addCollection $(@), $collection
        event.stopPropagation()
        true
    
    $articles.click ->
      unless $(@).hasClass 'open'
        events.onArticleOpen event, $(@)
        $article = $(@)
        $('body').click (event) ->
          events.onArticleClose(event, $article) unless $article.is(':hover')
    $articles.mouseenter -> events.onArticleMouseenter event, $(@)
    $articles.mousemove  -> events.onArticleMousemove  event, $(@)
    $articles.mouseleave -> events.onArticleMouseleave event, $(@)
    $articles.each ->
      events.onArticleResize  $(@)
      events.onArticleLoad    $(@)
      
    $articles.find('img').load () -> 
      events.onArticleResize($(@))
      
  parallaxHover: ->
    getProgressValues = ($element, scale) ->
      # if article, compensate for global scale
      offsetGlobalScale = if $element.is('article') then 1 / (constants.style.globalScale) else 1
      offsetX = $element.offset().left - $(window).scrollLeft()
      offsetY = $element.offset().top  - $(window).scrollTop()
      progressY = offsetGlobalScale * Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
      progressX = offsetGlobalScale * Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))
      { x: progressX, y: progressY }
    getRotateValues = ($element, progress) ->
      maxRotateY = if $element.is('a') then 22 else 22
      maxRotateX = if $element.is('a') then 22 else 22
      rotateX = maxRotateY * (progress.y - .5)
      rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
      { x: rotateX, y: rotateY}
    $elements = $('#articleContainer article, ul.collectionsMenu li a, .addForm .headerButton a')
    $elements.each ->
      $element = $(@)
      $layers = $element.find('.parallaxLayer')
      scale = if $element.is('a') then 1.25 else 1.5
      duration = 500
      $element.addClass 'parallaxHover'
      $element.mouseenter (event) ->
        unless $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover')
          $element.wrapInner '<span></span>' if $element.is('a')
          perspective = $element.height()
          $element.wrapInner $('<div></div>').addClass('transform')
          $transform = $element.find('.transform')
          $transform.wrap $('<div></div>').addClass('perspective')
          $perspective = $element.find('.perspective')
          progress = getProgressValues($element, scale)
          rotate = getRotateValues($element, progress)
          # offset if element too close to edge
          if $element.is 'article'
            translateY = if ($element.offset().top  - $(window).scrollTop() ) < 72 then 48 else 0
            translateX = if ($element.offset().left - $(window).scrollLeft()) < 72 then 48 else 0
          else
            translateY = 0
            translateX = 0
          console.log 'hi', translateY
          $element.add($element.parents('li')).css
            zIndex: 2
          $transform.velocity
            properties:
              scale: scale
              translateX: translateX
              translateY: translateY
            options:
              easing: constants.velocity.easing.smooth
              duration: duration
          $perspective.velocity
            properties:
              perspective: perspective
            options:
              duration: 1
          $layers.each ->
            depth = parseFloat $(@).data('parallaxdepth')
            offset =
              x: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').x else 0
              y: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').y else 0
#             $(@).velocity
#               properties:
#                 translateZ: 500 * depth #(((scale - 1) + depth) / 2) + 1 # average depth with scale of whole $element
#               options:
#                 easing: constants.velocity.easing.smooth
#                 duration: duration    
      $element.mousemove (event) ->
        unless $element.hasClass('open') or $element.hasClass('obscured') or $element.data('closingHover')
          $transform = $element.find('.transform')
          progress = getProgressValues($element, scale)
          rotate = getRotateValues($element, progress)
          $.Velocity.hook $transform, 'rotateX', "#{rotate.x}deg"
          $.Velocity.hook $transform, 'rotateY', "#{rotate.y}deg"
          $layers.each ->
            depth = parseFloat $(@).data('parallaxdepth')
            offset =
              x: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').x else 0
              y: if $(@).data('parallaxoffset') isnt undefined then $(@).data('parallaxoffset').y else 0
            parallax = 144 * depth
            $.Velocity.hook $(@), 'translateX', "#{offset.x + (parallax * (-1 * (progress.x - .5)))}px"
            $.Velocity.hook $(@), 'translateY', "#{offset.y + (parallax * (-1 * (progress.y - .5)))}px"
      $element.mouseleave ->
        unless $element.hasClass('open') or $element.hasClass('obscured')
          $element.data('closingHover', true)
          $transform = $element.find('.transform')
          $element.add($element.parents('li')).css
            zIndex: ''
          $transform.velocity
            properties:
              scale: 1
              rotateX: 0
              rotateY: 0
              translateY: 0
              translateX: 0
            options:
              queue: false
              easing: constants.velocity.easing.smooth
              duration: duration
              complete: ->
                $transform.children().appendTo $element
                $transform.unwrap $element.find('.perspective')
                $transform.remove()
                $element.find('.perspective').remove()
                $element.data('closingHover', false)
              
          $layers.velocity
            properties:
              scale: 1
              rotateX: 0
              rotateY: 0
              translateX: 0
              translateY: 0
            options:
              easing: constants.velocity.easing.smooth
              duration: duration
              queue: false


  container: ($container) ->
    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      transitionDuration: '0.5s'
      gutter: 0 #constants.style.gutter

    $container.packery 'bindResize'

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleModel.removeCollection $collection.parent().parent(), $collection
    $container.css
      width: "#{100/constants.style.globalScale}%"
    $container.velocity
      properties:
        scale: constants.style.globalScale

  addCollectionForm: () ->
    $('#newCollectionForm').submit (event) ->
      name = $('#newCollectionForm [type=text]').val()
      $('#newCollectionForm [type=text]').val ''
      socket.emit 'addCollection', { name }
      event.preventDefault()
      
  nav: ($nav) ->
    $nav.hover extendNav, retractNav

  collectionsMenu: ($menu) ->  
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
    
$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  init.article $("article")
  init.container $( constants.dom.articleContainer )
  init.collection $( constants.dom.collections )
  init.collectionsMenu $( constants.dom.collectionsMenu )
  init.nav $(constants.dom.nav)
  init.addCollectionForm()
  init.parallaxHover()
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
  window.oldScrollTop = 0
  window.scrollDirection = 'down'
  
  rotateColor = ($element, hue)->
    $element.css
      '-webkit-text-fill-color': "hsl(#{hue},100%,75%)"
    
  $('li.recent a, li.labelsButton a').each ->
    $(@).data('hue', Math.floor(Math.random() * 360))
    rotateColor $(@), $(@).data('hue')
    
  setInterval ->
    $('li.recent a, li.labelsButton a').each ->
      $(@).data('hue', $(@).data('hue') + 30)
      rotateColor $(@), $(@).data('hue')
  , 1000

  # if  draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie



