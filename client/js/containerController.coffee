window.containerController =
  init: ($container) ->
    $wrapper      = $('.wrapper')
    $scale        = $wrapper.children('.scale')

    $container.packery
      itemSelector: 'article'
      isOriginTop: false
      transitionDuration: '0.0s'
      gutter: constants.style.gutter

    $container.packery 'bindResize'

    $wrapper.mousemove (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length
        cursorView.start '+'

    $wrapper.click (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length
        containerView.insertNewArticleForm(event)
        console.log 'click wrapper', $container.data 'canInsertFormOnClick'
#       cursorView.end()

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleController.removeCollection $collection.parent().parent(), $collection

    containerView.updateHeight $wrapper, $container
    $scale.css
      width: "#{100/constants.style.globalScale}%"
    $scale.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1

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
        $( constants.dom.articleContainer ).prepend $articles
        articleController.init $articles
        $( constants.dom.articleContainer ).packery('prepended', $articles)
        scrapState.waitingForContent = false
        containerView.updateHeight $('.wrapper'), $(constants.dom.articleContainer)
