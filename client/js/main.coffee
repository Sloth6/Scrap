'use strict'

window.constants =
  style:
    gutter: 40
    curves:
      smooth: [25, 10]
      spring: [75, 10]
  dom:
    collectionsMenu: 'ul.collectionsMenu'
    articleContainer: '#articleContainer'
    collections: '.collection'

stopProp = (event) -> event.stopPropagation()

window.events =
  onCollectionOverArticle: (event, $collection) ->
    console.log 'over'
    $article = $('article.hovered')
    $card = $article.children('.card')

  onCollectionOutArticle: (event, $collection) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  onOpenCollectionsMenu: () ->
    $menu       = $(constants.dom.collectionsMenu )
    $container  = $(constants.dom.articleContainer)
    $menuItems  = $menu.children()
    $button     = $menu.find('.headerButton')
    $labels     = $menuItems.not('.headerButton')
    $articleContents = $container.find('article .card').children().add($container.find('article ul, article .articleControls'))
    options     =
      duration: 1000
      easing:   constants.style.curves.spring
    
    $menu.addClass 'open'
    
    # animate in labels
    $labels.find('.contents').css
      opacity: 0
    $menuItems.show()
    $menu.css
      width: $menu.width()
    $button.velocity
      properties:
        translateY: -$button.height()
      options:
        duration: options.duration
        easing:   options.easing
    $labels.each ->
      $label = $(@)
      $label.find('.contents').velocity
        properties:
          translateY: [-$button.height(), $(window).height() - ($label.offset().top - $label.height())]
          scaleY: [1, 2]
          scaleX: [1, .125]
#           rotateZ: [0, 45 * (Math.random() - .5)]
          opacity: [1, 1]
        options:
          duration: options.duration # + ($label.index() * 60)
          easing:   options.easing
          delay:    $label.index() * 60
          
    # hide articles
    $articleContents.velocity
      properties:
        opacity: 0
      options: options
    $menu.data 'canOpen', false

  onCloseCollectionsMenu: () ->
    $menu       = $(constants.dom.collectionsMenu )
    $container  = $(constants.dom.articleContainer)
    $menuItems  = $menu.children()
    $button     = $menu.find('.headerButton')
    $dragging   = $menu.find 'ui-draggable-dragging'
    $labels     = $menuItems.not('.ui-draggable-dragging, .headerButton')
    $articleContents = $container.find('article .card').children().add($container.find('article ul, article .articleControls'))
    options     =
      duration: 500
      easing:   constants.style.curves.smooth

    $menu.removeClass 'open'
    $button.velocity 'reverse'
    $labels.each ->
      $label = $(@)
      $label.find('.contents').velocity 'reverse', {
        complete: ->
          if $label.index() is $labels.length - 1
            $labels.hide()
            $menu.data 'canOpen', true
            if window.triedToOpen and $menu.is(':hover') # if user tried to open menu before ready, and is still hovering
              events.onOpenCollectionsMenu() # open menu after close animation finishes
              window.triedToOpen = false
      }
      
    $articleContents.velocity 'reverse'

  onArticleResize: ($article) ->
    $(@).width $(@).children('.card').outerWidth()
    $(@).height $(@).children('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()

  # direction = ['up', 'down']
  onChangeScrollDirection: (direction) ->

  onSwitchToCollection: (collectionKey) ->
    console.log 'onSwitchToCollection', collectionKey
    $title = $('.collections li.headerButton a')

    if collectionKey == 'recent'
      $("article").show()
      window.openCollection = 'recent'
      $title.text 'recent'
      $title.css 'color': 'black'
    else
      $("article.#{collectionKey}").show()
      $('article').not(".#{collectionKey}").hide()
      $title.text collections[collectionKey].name
      $title.css 'color': collections[collectionKey].color
      window.openCollection = collectionKey
    
    events.onCloseCollectionsMenu()
    $( constants.dom.articleContainer ).packery()

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

    $collections.
      zIndex(2).
      draggable(draggableOptions).
      click((event) ->
        collectionKey = $(@).data('collectionkey')
        events.onSwitchToCollection collectionKey
        event.stopPropagation()
        event.preventDefault()).
      mousedown ->
        # keep width the same on drag
        $(@).css
          width: $(@).width()  

  article: ($articles) ->
    $articles.droppable
      greedy: true
      hoverClass: "hovered"
      over: (event, object) ->
        events.onCollectionOverArticle event, object.draggable
      out: (event, object) ->
        events.onCollectionOutArticle event, object.draggable
      drop: ( event, ui ) ->
        console.log 'dropped!'
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

  container: ($container) ->
    $container.css
      'margin': constants.style.gutter
      'margin-top': 0
      'padding-top': constants.style.gutter  

    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      gutter: constants.style.gutter

    $container.packery 'bindResize'

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        console.log 'dropped on collection!'
        $collection = ui.draggable
        articleModel.removeCollection $collection.parent().parent(), $collection

  addCollectionForm: () ->
    $('#newCollectionForm').submit (event) ->
      name = $('#newCollectionForm [type=text]').val()
      $('#newCollectionForm [type=text]').val ''
      socket.emit 'addCollection', { name }
      event.preventDefault()

  collectionsMenu: ($menu) ->  
    $menu.find('li.headerButton a').mouseenter ->
      if $menu.data('canOpen') # ready to open (i.e., not in middle of close animation)
        events.onOpenCollectionsMenu()
      else # not ready to open
        window.triedToOpen = true # register attempt to open
    $menu.mouseleave ->
      events.onCloseCollectionsMenu() if $menu.hasClass 'open'
    $menu.find('li').not('.headerButton').hide()
    $menu.data 'canOpen', true
$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  init.article $("article")
  init.container $( constants.dom.articleContainer )
  init.collection $( constants.dom.collections )
  init.collectionsMenu $( constants.dom.collectionsMenu )
  init.addCollectionForm()
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



