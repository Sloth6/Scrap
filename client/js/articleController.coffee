window.articleController =
  getCollectionKeys: ($article) ->
    keys = []
    for c in $article.find('.collection')
      if c.length
        keys.append(c.data('collectionkey'))
    keys

  addCollection: ($article, $label) ->
    articleId     = $article.attr 'id'
    collectionKey = "#{$label.data 'key'}"
    articleView.addCollection $article, $label
    if !(articleId? and collectionKey?)
      throw "Invalid params #{{articleId, collectionKey}}"
    socket.emit 'addArticleCollection', { articleId, collectionKey }

  removeCollection: ($article, $collection) ->
    articleId     = $article.attr 'id'
    collectionKey = $collection.data 'collectionkey'

    $article.removeClass collectionKey
    $collection.remove()
    socket.emit 'removeArticleCollection', { articleId, collectionKey }

  # Must be called everytime an article opens the add menu.
  initAddCollectionsMenu: ($article) ->
    $menu = $article.find 'ul.addCollectionMenu'

    content = $(document.body).children('.addCollectionMenu').children().clone()
    $menu.append content

    labelHeights = 0
    $article.find('ul.addCollectionMenu li').each ->
      $.Velocity.hook $(@), 'translateX', "#{constants.style.margin.articleText.left}px"
      $.Velocity.hook $(@), 'translateY', "#{labelHeights}px"
      $(@).data 'translateY', labelHeights
      labelHeights += $(@).height()
      console.log labelHeights

    # Click to add label
    $article.find('ul.addCollectionMenu li a').click ->
      $menu = $article.find('ul.addCollectionMenu')
      $label = $(@).parent()
      event.stopPropagation()
      event.preventDefault()
      articleController.addCollection $article, $label

  open: ($article) ->
    contentType = $article.data 'contenttype'
    return if scrapState.openArticle?
    console.log 'Opening article', $article.attr('class')
    scrapState.openArticle = $article
    scrollController.disableScroll()
    $article.addClass 'open'

    if contentControllers[contentType]?.canZoom?
      articleView.open $article

    # Handle specific contentTypes.
    if contentControllers[contentType]?.open
      contentControllers[contentType].open $article
    hideNav()

  close: ($article) ->
    throw "No article passed to closed" unless $article?
    console.log 'Closing article', $article.attr('class')

    contentType = $article.data 'contenttype'
    console.log 'content type', contentType, '\n'
    $article.removeClass 'open'
    articleView.close $article

    # if $article.hasClass('playable')
    #   stopPlaying $article

    # Handle specific contenttypes.
    if contentControllers[contentType]?.close
      contentControllers[contentType]?.close $article
    scrapState.openArticle = null
    scrollController.enableScroll()
    extendNav()

  init: ($articles) ->
    $articles.each ->
      $article = $(@)
      articleView.init $article
      contentType = $article.data 'contenttype'
      if window.contentControllers[contentType]
        window.contentControllers[contentType].init $article

      $article.find('.articleDeleteButton').click (event) ->
        console.log 'Delete button clicked'
        socket.emit 'deleteArticle', { articleId: $article.attr('id') }
        event.stopPropagation()

    # Articles zoom on click.
    $articles.click (event) ->
      articleController.open $(@)
      event.stopPropagation()

    # Scale up labels indicator inversely proportional to global scale
    $.Velocity.hook $articles.find('ul.articleCollections .scale'), 'scale', 1 / constants.style.globalScale

    $articles.each () ->
      $article = $(@)

      articleView.resize($article) unless $article.hasClass('image') or $article.hasClass('website')

      $article.find('img').load -> articleView.resize $article
      
      setTimeout ->
        articleView.resize($article) 
      , 2000

      $article.find(constants.dom.articleMeta).hide()

      $article.find('ul.articleCollections li a').each ->
        simpleHover $(@), 250, 1.25

      # Set up label indicators
      $article.find('ul.articleCollections li').each ->
        $a   = $(@).children('a')
        $dot = $(@).children('.dot')
        $a.data   'naturalHeight', $a.height()
        $a.data   'naturalWidth',  $a.width()
        $dot.data 'naturalHeight', $dot.height()
        $dot.data 'naturalWidth',  $dot.width()
        # parallaxHover $a, 250, 1.5
        $(@).mouseenter -> cursorView.start '☛'

      # Open/close collections menu
      $article.find('ul.articleCollections li.addCollection a').click ->
        $menu = $article.find('ul.addCollectionMenu')
        event.stopPropagation()
        event.preventDefault()
        if $menu.hasClass('open')
          articleView.hideAddCollectionMenu $article
          $menu.removeClass 'open'
        else
          articleView.showAddCollectionMenu $article
          $menu.addClass 'open'

      # Hide labels and add label menu
      articleView.hideAddCollectionMenu $article
      articleView.closeLabels           $article

      # Init delete button
      $article.find('.articleDeleteButton').mouseenter ->
        cursorView.start '🔫'

      if $article.hasClass('playable')
        $article.find('.playButton').css
          opacity: 0
        $article.find('.artist', '.source').css
          position: 'absolute'
          opacity: 0
        $.Velocity.hook($article.find('.artist, .source'), 'scale', '0')

      # Bind other article events.
      $article.mouseenter ->
        unless $article.hasClass('open') or $article.hasClass('obscured')
          articleView.mouseenter event, $article
      $article.mousemove  -> articleView.mousemove  event, $(@)
      $article.mouseleave ->
        unless $article.hasClass('open') or $article.hasClass('obscured')
          articleView.mouseleave event, $article

    parallaxHover $articles, 500, constants.style.articleHoverScale / constants.style.globalScale
