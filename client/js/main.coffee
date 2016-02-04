'use strict'

window.constants =
  style:
    gutter: 40
  dom:
    collectionsMenu: '.collectionsMenu'
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
    console.log 'onOpenCollectionsMenu'
    $( constants.dom.collectionsMenu ).children().show()
    $( constants.dom.container ).hide()

  onCloseCollectionsMenu: () ->
    console.log 'onCloseCollectionsMenu'
    $collectionsInMenu = $( constants.dom.collectionsMenu ).children()
    console.log $collectionsInMenu
    $collectionsInMenu.not('.headerButton, .ui-draggable-dragging').hide()
    $( constants.dom.container ).show()

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
    $( constants.dom.container ).packery()

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
      click (event) ->
        collectionKey = $(@).data('collectionkey')
        events.onSwitchToCollection collectionKey
        event.stopPropagation()
        event.preventDefault()

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
        console.log ui
        true

    $articles.each () ->
      $(@).width $(@).children('.card').outerWidth()
      $(@).height $(@).children('.card').outerHeight()

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
    # console.log $menu
    $menu.css 'left': $(window).width()/2
    
    $menu.hover(events.onOpenCollectionsMenu, events.onCloseCollectionsMenu)
    events.onCloseCollectionsMenu()

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



