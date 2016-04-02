'use strict'

window.contentControllers ?= {}

window.constants =
  style:
    grid:
      col: null
      cell: null
    sizeClasses:
      xSmall: null
      small: null
      medium: null
      large: null
      xLarge: null
    minGutter: 24
    maxGutter: 72
    margin:
      articleText:
        left: 16 / .75 # convert pt to px
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
    globalScale: 1#getGlobalScale()
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
    wrapper: '.wrapper'
    containerScale: '.wrapper > .scale'
    controls:
      menus: '.menuNeue'


window.scrapState =
  waitingForContent: false
#   addingArticle: false
  openArticle: null
  collectionsMenuIsOpen: false
  sizeClass: null


$ ->
  window.socket = io.connect()
  window.openCollection = 'recent'

    # Init controls; TODO: MOVE ELSEWHERE
  menuController.init $(constants.dom.controls.menus)
  buttonView.init $('.actionButton')


  collectionController.init      $(constants.dom.collections)
  collectionController.init      $(constants.dom.collectionsMenu).find('.labelsButton')
  collectionsMenuController.init $(constants.dom.collectionsMenu)
  articleController.init         $(constants.dom.articles)
  containerController.init       $(constants.dom.articleContainer)
  cursorController.init          $(constants.dom.cursor)

  contentControllers.newArticle.init $(constants.dom.addArticleMenu)

  containerController.getArticles(10)
  $(window).scroll scrollController.onScroll
  scrollController.onScroll()


  # Main body click handler.
  $('body').on 'touchend mouseup', (event) ->
    console.log 'body touchend'
    if scrapState.collectionsMenuIsOpen
      collectionsMenuView.close()
    # Close article if article is open
    else if scrapState.openArticle?
      articleController.close scrapState.openArticle
      scrollController.enableScroll()
#     else
#       $(window).scrollTop 0
#       articleController.open $(constants.dom.addArticleMenu)
    menuController.close $(constants.dom.controls.menus)


  $('li.recent a, li.labelsButton a').each ->
    $(@).data('hue', Math.floor(Math.random() * 360))
    rotateColor $(@), $(@).data('hue')

  setInterval ->
    $('li.recent a, li.labelsButton a').each ->
      $(@).data('hue', $(@).data('hue') + 30)
      rotateColor $(@), $(@).data('hue')
  , 1000

  # Init grid (makes CSS constants accessible in JS)
  constants.style.grid.col      = $('.ruler .grid .col').width()
  constants.style.grid.cell     = $('.ruler .grid .cell').width()
  constants.style.sizeClasses.xSmall  = $('.ruler .break .xSmall').width()
  constants.style.sizeClasses.small   = $('.ruler .break .small').width()
  constants.style.sizeClasses.medium  = $('.ruler .break .medium').width()
  constants.style.sizeClasses.large   = $('.ruler .break .large').width()
  constants.style.sizeClasses.xLarge  = $('.ruler .break .xLarge').width()
  $('.ruler').remove()

  window.onResize = ->
    width = $(window).width()
    # Set current sizeClass
    scrapState.sizeClass = switch
      when width <= constants.style.sizeClasses.xSmall then 'xSmall'
      when width <= constants.style.sizeClasses.small  then 'small'
      when width <= constants.style.sizeClasses.medium then 'medium'
      when width <= constants.style.sizeClasses.large  then 'large'
      when width >  constants.style.sizeClasses.large  then 'xLarge'
    constants.style.globalScale = switch
      when scrapState.sizeClass is 'xSmall' then 1/4
      when scrapState.sizeClass is 'small'  then 1/4
      when scrapState.sizeClass is 'medium' then 1/3
      when scrapState.sizeClass is 'large'  then 1/2
      when scrapState.sizeClass is 'xLarge' then 1/2
    containerView.updateScale()
    articleView.updateScale $(constants.dom.articles), constants.style.globalScale

  onResize()

  $(window).resize(onResize)


