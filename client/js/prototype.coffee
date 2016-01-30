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
    $menuCollections = $('ul.collections.center').children().not('.headerButton')
    console.log $menuCollections
    $menuCollections.hide()
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
  
  changeArticlesCollection: ($article, $collection) ->
    console.log 'changeArticlesCollection', $article[0], $collection[0]
    oldcollectionKey  = articleModel.getcollectionKey $article
    newcollectionKey  = $collection.data 'collectionKey'
    $existingCollection    = articleModel.getCollection $article
    $card = $article.children('.card')

    $collection.insertAfter $existingCollection
    $existingCollection.remove()

    $article.
      removeClass(oldcollectionKey).
      addClass(newcollectionKey).
      data('collectionKey', newcollectionKey)

    $card.css 'background-color': hslLight(collections[newcollectionKey].color)

    structuralEvents.switchToCollection(openCollection)

window.articleModel = 
  getCollection: ($article) ->
    $article.children('ul.articleCollections').children().first()
  getcollectionKey: ($article) ->
    articleModel.getCollection($article).data 'collectionKey'

window.init =
  collection: ($collections) ->
    $collections.
      zIndex(2).
      draggable({
        start: (event, ui) ->
          visualEvents.closeCollections()
          $(ui.helper).hover(
            ((event) -> event.stopPropagation()),
            ((event) -> event.stopPropagation())
          )
        stop: (event, ui) ->
          $(ui.helper).off 'hover'

        helper: "clone"
        revert: "true"
      }).
      click (event) ->
        collectionKey = $(@).data('collectionKey')
        structuralEvents.switchToCollection collectionKey
        event.stopPropagation()
        event.preventDefault()

  article: ($articles) ->
    $articles.droppable
      hoverClass: "hovered"
      over: (event, object) ->
        visualEvents.collectionOverArticle event, object.draggable
      out: (event, object) ->
        visualEvents.collectionOutArticle event, object.draggable
      drop: ( event, ui ) ->
        $collection = init.collection ui.draggable.clone()
        structuralEvents.changeArticlesCollection $(@), $collection
        $collection.show()

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


# window.forms:
#   add: () ->
#   collections: () ->
#     $collectionsButton = $('.collections .headerButton a')
#   settings: () ->
initAddCollectionForm = () ->
  $('#newCollectionForm').submit (event) ->
    name = $('#newCollectionForm [type=text]').val()
    $('#newCollectionForm [type=text]').val ''
    socket.emit 'newCollection', { name }
    event.preventDefault()
$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  # if draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie

  init.container $('#container')
  init.collection $('li.collection')
  init.article $( "article" )
  initAddArticleForm()
  initAddCollectionForm()
  # $('a').on 'ondragstart', ()  -> false

  $(window).resize -> onResize()
  onResize()
  $(window).scroll -> onScroll()
  onScroll()

  
  $('ul.collections.center').css 'left', $(window).width()/2
  visualEvents.closeCollections()


  $('.collections.center').hover(
    (() -> visualEvents.openCollections event),
    (() -> visualEvents.closeCollections event)
  )

  $addArticleForm = $('.addArticleForm')
  $addArticleForm.hide()

  $('.addForm').hover(
    (() ->
      $('.addForm .headerButton').hide()
      $addArticleForm.show()
      $addArticleForm.find('.editable').focus()
    ),
    (() ->
      $('.addForm .headerButton').show()
      $addArticleForm.hide()

    )
  )


