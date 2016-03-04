# Only code that calls packery
window.containerController =
  init: ($container) ->
    $wrapper      = $('.wrapper')
    $scale        = $wrapper.children('.scale')

    $container.packery
      itemSelector: 'article'
      isOriginTop: false
      transitionDuration: '0.0s'
      gutter: constants.style.minGutter
#       columnWidth: 240
#       rowHeight: 240

    $container.packery 'bindResize'

    $wrapper.mousemove (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length
        cursorView.start '+'

    containerView.updateHeight $wrapper, $container
    $scale.css
      width: "#{100/constants.style.globalScale}%"
    $scale.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1

  removeArticle: ($articles) ->
    $container = $(constants.dom.articleContainer)
    $container.
      packery 'remove', $articles
    $articles.remove()

  addArticles: ($articles) ->
    $container = $(constants.dom.articleContainer)
    $container.
      append($articles).
      packery 'appended', $articles
    buttonView.init $articles.find('.actionButton')
    containerView.updateHeight $('.wrapper'), $(constants.dom.articleContainer)

  getArticles: (n) ->
    return if scrapState.waitingForContent
    scrapState.waitingForContent = true
    o = $('article').not('.addArticleForm').length
    $.get('collectionContent', {o, n}).
      fail(() -> 'failed to get content').
      done (data) ->
        derp = $('<div>')
        for foo in $(data)
          derp.append $(foo)

        $articles = derp.children()
        containerController.addArticles $articles
        articleController.init $articles
        scrapState.waitingForContent = false

  insertNewArticleForm: ($form) ->
    containerController.addArticles $form
    articleController.open $form
