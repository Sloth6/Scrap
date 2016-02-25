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


  init: ($articles) ->
    $articles.each ->
      # Base color by first label.
      $firstLabel = $(@).find('ul.articleCollections li.collection').first().find('a')
      $card       = $(@).find('.card')
      $(@).css
        marginTop:  12 + Math.random() * constants.style.gutter
        marginLeft: 12 + Math.random() * constants.style.gutter
      $card.css
        borderWidth: .75 / constants.style.globalScale

      if $firstLabel.length and $(@).hasClass('text') or $(@).hasClass('website')
        $backgroundColor = $('<div></div>').prependTo($(@).find('.card')).css
          backgroundColor: $firstLabel.css('background-color')
          position: 'absolute'
          top: 0
          left: 0
          right: 0
          bottom: 0
          opacity: .25

      # Handle specific contenttypes.
      switch $(@).data 'contenttype'
        when 'text'       then initText $(@)
        when 'video'      then initVideo $(@)
        when 'file'       then initFile $(@)
        when 'soundcloud' then initSoundCloud $(@)
        when 'youtube'    then initYoutube $(@)

    # Allow labels to drop on article.
    $articles.droppable
      greedy: true
      hoverClass: "hovered"
      over: (event, object) ->
        articleView.onCollectionOver $(@), event, object.draggable
      out: (event, object) ->
        articleView.onCollectionOut $(@), event, object.draggable
      drop: ( event, ui ) ->
        $collection = ui.draggable.clone()
        $collection.css 'top':0, 'left':0
        $.Velocity.hook($collection.find('.contents'), 'translateY', "0px")
        collectionController.init $collection
        $collection.show()
        articleController.addCollection $(@), $collection
        event.stopPropagation()
        true

      # Articles zoom on click.
    $articles.click (event) ->
      return if scrapState.openArticle?
      console.log 'opening', $(@).attr 'id'
      articleView.open event, $(@)
      scrapState.openArticle = $(@)
      scrollController.disableScroll()
      event.stopPropagation()

    # Scale up labels indicator inversely proportional to global scale
    $.Velocity.hook $articles.find('ul.articleCollections .scale'), 'scale', 1 / constants.style.globalScale

    $articles.each () ->
      $article = $(@)

      articleView.resize($article) unless $article.hasClass('image') or $article.hasClass('website')

      $article.find('img').load -> articleView.resize $article

      $article.find(constants.dom.articleMeta).hide()

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
      else if $article.hasClass 'website'
        $article.find('header').css
          position: 'absolute'
          top: 0
        $.Velocity.hook($article.find('.description, .source'), 'opacity', '0')

    # Bind other article events.
    $articles.mouseenter -> articleView.mouseenter event, $(@)
    $articles.mousemove  -> articleView.mousemove  event, $(@)
    $articles.mouseleave -> articleView.mouseleave event, $(@)

    parallaxHover $articles, 500, constants.style.articleHoverScale / constants.style.globalScale
