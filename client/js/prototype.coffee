scale       = 1 / 1.5
duration    = 1000
easing      = [20, 10]
packeryDurationMS = duration / 2
packeryDuration = "#{packeryDurationMS / 1000}s"

draggable = false
'use strict'
window.constants =
  style:
    gutter: 20

hslLight = (color) ->
  pattern = /^hsl\(([-.0-9]+),(0|100|\d{1,2})%,([-.0-9]+)%\)$/
  hue = color.match(pattern)[1]
  'hsl('+hue+',100%, 98%)'

onResize = () ->
onScroll = () ->

visualEvents =
  labelOverArticle: (event, $label) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  labelOutArticle: (event, $label) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  animateOutArticle: ($article, callback) ->

  animateInArticle: ($article, callback) ->

structuralEvents =
  switchToCollection: (collectionKey) ->
    console.log 'switchToCollection', collectionKey
    if collectionKey == 'recent'
      $("article").show()
      window.openCollection = 'recent'
    else
      $("article.#{collectionKey}").show()
      $('article').not(".#{collectionKey}").hide()
      window.openCollection = collectionKey
    $('#container').packery()
  
  changeArticlesCollection: ($article, $label) ->
    console.log 'changeArticlesCollection', arguments
    oldCollectionKey  = articleModel.getCollectionKey $article
    newCollectionKey  = $label.data 'collectionkey'
    $existingLabel    = articleModel.getLabel $article
    $card = $article.children('.card')

    $label.insertAfter $existingLabel
    $existingLabel.remove()

    $article.
      removeClass(oldCollectionKey).
      addClass(newCollectionKey).
      data('collectionkey', newCollectionKey)

    $card.css 'background-color': hslLight(collections[newCollectionKey].color)

    structuralEvents.switchToCollection(openCollection)

articleModel = 
  getLabel: ($article) ->
    $article.children('ul.articleLabels').children().first()
  getCollectionKey: ($article) ->
    articleModel.getLabel($article).data 'collectionkey'

init =
  label: ($labels) ->
    $labels.
      zIndex(999).
      draggable({
        helper: "clone"
        revert: "true"
      }).
      click (event) ->
        collectionKey = $(@).data('collectionkey')
        structuralEvents.switchToCollection collectionKey
        event.stopPropagation()
        event.preventDefault()

  article: ($articles) ->
    $articles.droppable
      hoverClass: "hovered"
      over: (event, object) ->
        visualEvents.labelOverArticle event, object.draggable
      out: (event, object) ->
        visualEvents.labelOutArticle event, object.draggable
      drop: ( event, ui ) ->
        $label = init.label ui.draggable.clone()
        structuralEvents.changeArticlesCollection $(@), $label

    $articles.each () ->
      $(@).width $(@).children('.card').outerWidth()
      $(@).height $(@).children('.card').outerHeight()

$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  $container = $('#container')
  $container.packery({
    itemSelector: 'article'
    isOriginTop: true
    gutter: constants.style.gutter
  }).packery('bindResize')

  # if draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie
  
  init.label $('li.label')
  init.article $( "article" )
  # $('a').on 'ondragstart', ()  -> false

  $(window).resize -> onResize()
  onResize()
  $(window).scroll -> onScroll()
  onScroll()
