window.articleCollectionsMenuController =
  addCollection: ($article, $label) ->
    articleId     = $article.attr 'id'
    collectionKey = "#{$label.data 'key'}"
    articleCollectionsMenuView.addCollection $article, $label
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
    # Init menus in article
    $menu   = $article.find 'ul.addCollectionMenu'
    content = $(document.body).children('.addCollectionMenu').children().clone()
    $menu.append content
    labelHeights = 0
    $labels = $article.find '.collections li'

    $labels.find('a').on 'touchend mouseup', (event) ->
      event.stopPropagation()
      event.preventDefault()

    # Transform labels to starting positions
    $article.find('ul.addCollectionMenu li').each () ->
      $.Velocity.hook $(@), 'translateX', "#{constants.style.margin.articleText.left}px"
      $.Velocity.hook $(@), 'translateY', "#{labelHeights}px"
      $(@).data 'translateY', labelHeights
      labelHeights += $(@).height()

    # Click to add label
    $article.find('ul.addCollectionMenu li a').on 'touchend mouseup', (event) ->
      $menu = $article.find('ul.addCollectionMenu')
      $label = $(@).parent()
      event.preventDefault()
      articleCollectionsMenuController.addCollection $article, $label

    $article.find('ul.addCollectionMenu li input').on 'touchend mouseup', (event) ->
      event.stopPropagation()

    $labels.on 'touchstart mouseenter', (event) ->
      articleCollectionsMenuView.articleCollectionEnter $(@).find('.animate'), event

    $labels.on 'touchend mouseleave', (event) ->
      articleCollectionsMenuView.articleCollectionLeave $(@).find('.animate'), event

