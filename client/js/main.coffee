'use strict'

window.contentControllers ?= {}

window.constants =
  style:
    minGutter: 24
    maxGutter: 72
    margin:
      articleText:
        left: 16 / .75 # convert pt to px
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
    globalScale: .5
    duration:
      openArticle: 1000
      hoverArticle: 250
    articleHoverScale: .75
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
    articles: '#articleContainer article'
    articleMeta: 'footer .meta'
    cursor: '.cursor'

window.scrapState =
  waitingForContent: false
#   addingArticle: false
  openArticle: null
  collectionsMenuIsOpen: false


$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

  collectionController.init      $(constants.dom.collections)
  collectionsMenuController.init $(constants.dom.collectionsMenu)
  articleController.init         $(constants.dom.articles)
  containerController.init       $(constants.dom.articleContainer)

  cursorController.init          $(constants.dom.cursor)

  containerController.getArticles(40)
  $(window).scroll scrollController.onScroll
  scrollController.onScroll()

  $newArticleForm = $(constants.dom.addArticleMenu).remove()

  $('body').click (event) ->
    # Close article if article is open
    console.log 'body click'

    if scrapState.collectionsMenuIsOpen
      collectionsMenuView.close()
    else
      if scrapState.openArticle?
        articleController.close scrapState.openArticle
        scrollController.enableScroll()
      else
        unless scrapState.openArticle?
          contentControllers.newArticle.init $newArticleForm
          containerController.insertNewArticleForm $newArticleForm
  
  buttonView.init $('.actionButton')

  $('li.recent a, li.labelsButton a').each ->
    $(@).data('hue', Math.floor(Math.random() * 360))
    rotateColor $(@), $(@).data('hue')

  setInterval ->
    $('li.recent a, li.labelsButton a').each ->
      $(@).data('hue', $(@).data('hue') + 30)
      rotateColor $(@), $(@).data('hue')
  , 1000
