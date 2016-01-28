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
  labelOverArticle: (event, $label) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  labelOutArticle: (event, $label) ->
    $article = $('article.hovered')
    $card = $article.children('.card')

  openLabels: () ->
    console.log 'openLabels'
    $('ul.labels.center li.label').show()
    $('#container').hide()

  closeLabels: () ->
    console.log 'closeLabels'
    $menuLabels = $('ul.labels.center li.label')
    $menuLabels.not('.ui-draggable-dragging').hide()
    $('#container').show()

  animateOutArticle: ($article, callback) ->

  animateInArticle: ($article, callback) ->

window.structuralEvents =
  switchToCollection: (collectionKey) ->
    console.log 'switchToCollection', collectionKey
    $title = $('.labels.center li.headerButton a')

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
    
    visualEvents.closeLabels()
    $('#container').packery()
  
  changeArticlesCollection: ($article, $label) ->
    console.log 'changeArticlesCollection', $article[0], $label[0]
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

window.articleModel = 
  getLabel: ($article) ->
    $article.children('ul.articleLabels').children().first()
  getCollectionKey: ($article) ->
    articleModel.getLabel($article).data 'collectionkey'

window.init =
  label: ($labels) ->
    $labels.
      zIndex(9).
      draggable({
        start: (event, ui) ->
          visualEvents.closeLabels()
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
        $label.show()

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
#   labels: () ->
#     $labelsButton = $('.labels .headerButton a')
#   settings: () ->

$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  # if draggable
  #   itemElems = $container.packery('getItemElements')
  #   for elem in itemElems
  #     draggie = new Draggabilly( elem )
  #     $container.packery 'bindDraggabillyEvents', draggie

  init.container $('#container')
  init.label $('li.label')
  init.article $( "article" )
  # $('a').on 'ondragstart', ()  -> false

  $(window).resize -> onResize()
  onResize()
  $(window).scroll -> onScroll()
  onScroll()

  $('ul.labels.center li.label').hide()
  $('ul.labels.center').css 'left', $(window).width()/2
  
  $('.labels.center').hover(
    (() -> visualEvents.openLabels event),
    (() -> visualEvents.closeLabels event)
  )

