# Only code that calls packery
window.containerController =
  init: ($container) ->
    $wrapper      = $(constants.dom.wrapper)

    $('.jagged').each () ->
      $(@).width(Math.random()*300 + 100).height(Math.random()*300+ 100)

    $container.packery
      itemSelector: 'article,.jagged'
      isOriginTop: true
      # transitionDuration: '0.0s'
      gutter: constants.style.minGutter * 2
      columnWidth: constants.style.grid.col
#       rowHeight:    144

    $container.packery 'bindResize'

    $wrapper.mousemove (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length
        cursorView.start '+', event

    containerView.updateHeight $wrapper, $container
    containerView.updateScale()

  removeArticle: ($articles) ->
    $container = $(constants.dom.articleContainer)
    $container.
      packery('remove', $articles).
      packery()


  addArticles: ($articles, { append }={ append: false }) ->
    $container = $(constants.dom.articleContainer)
    if append
      $container.append($articles)
      $container.packery 'appended', $articles
    else
      $articles.insertAfter $(constants.dom.addArticleMenu)
      $container.packery 'reloadItems'

    containerView.updateHeight $('.wrapper'), $(constants.dom.articleContainer)

  getArticles: (n) ->
    return if scrapState.waitingForContent
    scrapState.waitingForContent = true
    o = $('article').not('.addArticleForm').length
    data = { o, n, collectionKey: window.openCollection }
    $.get('collectionContent', data).
      fail(() -> 'failed to get content').
      done (data) ->
        derp = $('<div>')
        for foo in $(data)
          derp.append $(foo)

        $articles = derp.children()
        containerController.addArticles $articles, { append: true }
        articleController.init $articles
        scrapState.waitingForContent = false
