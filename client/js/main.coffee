'use strict'

window.constants =
  style:
    gutter: 48
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
    globalScale: 1/2
    duration:
      openArticle: 1000
      hoverArticle: 250
  velocity:
    easing:
      smooth: [20, 10]
      spring: [75, 10]
  dom:
    nav: 'nav.main'
    collectionsMenu: 'ul.collectionsMenu'
    addArticleMenu: '.addArticleForm'
    articleContainer: '#articleContainer'
    collections: 'ul.collectionsMenu li.collection'
    articles: 'article'
    articleMeta: 'footer .meta'


$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  collectionsMenuController.init $(constants.dom.collectionsMenu)
  containerController.init       $(constants.dom.articleContainer)
  addArticleMenuController.init  $(constants.dom.addArticleMenu)

  articleController.init         $(constants.dom.articles)
  collectionController.init      $(constants.dom.collections)

  # $(window).resize -> articleView.resize()
  # articleView.resize()

  $( constants.dom.articleContainer ).packery()

  $('li.recent a, li.labelsButton a').each ->
    $(@).data('hue', Math.floor(Math.random() * 360))
    rotateColor $(@), $(@).data('hue')

  setInterval ->
    $('li.recent a, li.labelsButton a').each ->
      $(@).data('hue', $(@).data('hue') + 30)
      rotateColor $(@), $(@).data('hue')
  , 1000
