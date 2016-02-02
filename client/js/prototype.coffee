scale       = 1 / 1.5
duration    = 1000
easing      = [20, 10]
packeryDurationMS = duration / 2
packeryDuration = "#{packeryDurationMS / 1000}s"

draggable = false
'use strict'
window.constants =
  style:
    gutter: 40

hslLight = (color) ->
  pattern = /^hsl\(([-.0-9]+),(0|100|\d{1,2})%,([-.0-9]+)%\)$/
  hue = color.match(pattern)[1]
  'hsl('+hue+',100%, 98%)'

stopProp = (event) -> event.stopPropagation()
onResize = () ->
onScroll = () ->

window.visualEvents =
  collectionOverArticle: (event, $collection) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  collectionOutArticle: (event, $collection) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  openCollections: () ->
    console.log 'openCollections'
    $('ul.collections.center').children().show()
    $('#container').hide()

  closeCollections: () ->
    console.log 'closeCollections'
    $menuCollections = $('ul.collections.center').children()
    $menuCollections.not('.headerButton, .ui-draggable-dragging').hide()
    $('#container').show()

  animateOutArticle: ($article, callback) ->

  animateInArticle: ($article, callback) ->

window.structuralEvents =
  switchToCollection: (collectionKey) ->
    console.log 'switchToCollection', collectionKey
    $title = $('.collections.center li.headerButton a')

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
    
    visualEvents.closeCollections()
    $('#container').packery()

window.articleModel = 
  getCollectionKeys: ($article) ->
    keys = []
    for c in $article.find('.collection')
      if c.length
        keys.append(c.data('collectionkey'))
    keys

  # getCollection: ($article) ->
  #   $article.children('ul.articleCollections').children().first()
  
  # getcollectionKey: ($article) ->
  #   articleModel.getCollection($article).data 'collectionKey'
  
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
        visualEvents.closeCollections()
        $(ui.helper).hover stopProp, stopProp
      stop: (event, ui) ->
        $(ui.helper).off 'hover'

    $collections.
      zIndex(2).
      draggable(draggableOptions).
      click (event) ->
        collectionKey = $(@).data('collectionkey')
        structuralEvents.switchToCollection collectionKey
        event.stopPropagation()
        event.preventDefault()

  article: ($articles) ->
    $articles.droppable
      greedy: true
      hoverClass: "hovered"
      over: (event, object) ->
        visualEvents.collectionOverArticle event, object.draggable
      out: (event, object) ->
        visualEvents.collectionOutArticle event, object.draggable
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

initAddCollectionForm = () ->
  $('#newCollectionForm').submit (event) ->
    name = $('#newCollectionForm [type=text]').val()
    $('#newCollectionForm [type=text]').val ''
    socket.emit 'addCollection', { name }
    event.preventDefault()

initCollectionsHeader = () ->
  $('ul.collections.center').css 'left': $(window).width()/2
  
  $('ul.collections.center').hover(visualEvents.openCollections,
                                   visualEvents.closeCollections)
  visualEvents.closeCollections()

$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  init.article $( "article" )
  init.container $('#container')
  init.collection $('li.collection')
  
  
  initCollectionsHeader()
  initAddCollectionForm()
  initAddArticleForm()

  $('article').each () ->
    switch $(@).data 'contenttype'
      when 'text'       then initText $(@)
      when 'video'      then initVideo $(@)
      when 'file'       then initFile $(@)
      when 'soundcloud' then initSoundCloud $(@)
      when 'youtube'    then initYoutube $(@)

  $(window).resize -> onResize()
  onResize()
  $(window).scroll -> onScroll()
  onScroll()

  # if draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie



