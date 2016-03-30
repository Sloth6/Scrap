window.articleController =
  getCollectionKeys: ($article) ->
    keys = []
    for c in $article.find('.collection')
      if c.length
        keys.append(c.data('collectionkey'))
    keys

  open: ($article) ->
    return if scrapState.openArticle?
    contentType = $article.data 'contenttype'
    if contentControllers[contentType]?.canZoom
      scrapState.openArticle = $article
      scrollController.disableScroll()
      $article.addClass 'open'
      articleView.open $article

    # Handle specific contentTypes.
    if contentControllers[contentType]?.open
      contentControllers[contentType].open $article

    hideNav()

  close: ($article) ->
    throw "No article passed to closed" unless $article?

    contentType = $article.data 'contenttype'
    $article.removeClass 'open'
    articleView.close $article

    if $article.hasClass('playable')
      stopPlaying $article

    # Handle specific contenttypes.
    if contentControllers[contentType]?.close
      contentControllers[contentType]?.close $article
    scrapState.openArticle = null
    scrollController.enableScroll()
    extendNav()

  delete: ($article) ->
    socket.emit 'deleteArticle', { articleId: $article.attr('id') }

  init: ($articles) ->
    $articles.each ->
      $article = $(@)
      content = $article.data 'content'
      contentType = $article.data 'contenttype'

      # Must be called early on so these controllers get accurate measurements
      menuController.init $article.find(constants.dom.controls.menus)
      buttonView.init $article.find('.actionButton')

      articleView.init $article

      # Initialize behavior custom to contenttype
      if window.contentControllers[contentType]
        window.contentControllers[contentType].init $article

      $article.find('.articleDeleteButton').on 'touchend mouseup', (event) ->
        articleController.delete $article
        event.stopPropagation()

      # Articles zoom on click.
      $article.on 'touchend mouseup', (event) ->
        event.stopPropagation()
        articleController.open $article

      # Init delete button
      $article.find('.articleDeleteButton').mouseenter (event) ->
        cursorView.start '🔫', event

      # Bind other article events.
      $article.on 'touchstart mouseenter', (event) ->
        unless $article.hasClass('open') or $article.hasClass('obscured')
          articleView.mouseenter event, $article

      $article.on 'touchmove mousemove',(event) ->
        articleView.mousemove  event, $(@)

      $article.on 'touchend mouseleave', (event) ->
        unless $article.hasClass('open') or $article.hasClass('obscured')
          articleView.mouseleave $article

      $article.find('footer, a, input').on 'touchstart mouseenter', (event) ->
        cursorView.end()

      # Resize
      imgs = $article.find('img')
      # if images exist, wait for them to load to resize.
      if imgs.length
        imgs.load -> articleView.resize $article
      else
        articleView.resize $article

      # Hide meta element
      $article.find(constants.dom.articleMeta).hide()

      # Apply simple hover effect to labels
      $article.find('ul.articleCollections li a div').each ->
        simpleHover $(@), 250, 1.25

      # Set up label indicators
      $article.find('ul.articleCollections li').each ->
        $a   = $(@).children('a')
        $dot = $(@).children('.dot')
        $a.data   'naturalHeight', $a.height()
        $a.data   'naturalWidth',  $a.width()
        $dot.data 'naturalHeight', $dot.height()
        $dot.data 'naturalWidth',  $dot.width()
        $(@).mouseenter (event) -> cursorView.start '☛', event

      # Open/close collections menu
      $article.find('ul.articleCollections li.addCollection a').on 'touchend mouseup', (event) ->
        $menu = $article.find('ul.addCollectionMenu')
        event.stopPropagation()
        event.preventDefault()
        if $menu.hasClass('open')
          articleCollectionsMenuView.hideAddCollectionMenu $article
          $menu.removeClass 'open'
        else
          articleCollectionsMenuView.showAddCollectionMenu $article
          $menu.addClass 'open'


      # Hide labels and add label menu
      articleCollectionsMenuView.hideAddCollectionMenu $article
      articleCollectionsMenuView.closeLabels           $article

