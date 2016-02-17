window.articleController =
  getCollectionKeys: ($article) ->
    keys = []
    for c in $article.find('.collection')
      if c.length
        keys.append(c.data('collectionkey'))
    keys

  addCollection: ($article, $collection) ->
    $article.addClass($collection.data('collectionkey'))
    $article.children('ul.articleCollections').append $collection

    articleId     = $article.attr 'id'
    collectionKey = "#{$collection.data 'collectionkey'}"
    socket.emit 'addArticleCollection', { articleId, collectionKey }

  removeCollection: ($article, $collection) ->
    articleId     = $article.attr 'id'
    collectionKey = $collection.data 'collectionkey'

    $article.removeClass collectionKey
    $collection.remove()
    socket.emit 'removeArticleCollection', { articleId, collectionKey }

  init: ($articles) ->
    $articles.each ->
      # Base color by first label.
      $firstLabel = $(@).find('ul.articleCollections li.collection').first().find('a')
      $(@).css
        marginTop:  12 + Math.random() * constants.style.gutter
        marginLeft: 12 + Math.random() * constants.style.gutter

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
    $articles.click ->
      unless $(@).hasClass 'open'
        articleView.open event, $(@)
        $article = $(@)
        $('body').click (event) ->
          articleView.close(event, $article) unless $article.is(':hover')

    $articles.each () ->
      unless $(@).hasClass 'image'
        articleView.resize $(@)

      $articles.find('img').load () =>
        articleView.resize $(@)
        
      $(@).find(constants.dom.articleMeta).hide()
      if $(@).hasClass('playable')
#         $(@).find('.playButton').hide()
        $(@).find('.artist', '.source').css
          position: 'absolute'
          opacity: 0
        $.Velocity.hook($(@).find('.artist', '.source'), 'scale', '0')

    # Bind other article events.
    $articles.mouseenter -> articleView.mouseenter event, $(@)
    $articles.mousemove  -> articleView.mousemove  event, $(@)
    $articles.mouseleave -> articleView.mouseleave event, $(@)

    parallaxHover $articles
