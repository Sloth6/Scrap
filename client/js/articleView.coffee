window.articleView =
  obscure: ($articles) ->
    $contents   = $articles.find('.card').children().add($articles.find('article ul, article .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity
      properties:
        opacity: 0
      options: options
    $articles.addClass 'obscured'

  unobscure: ($articles) ->
    $contents = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity
      properties:
        opacity: 1
      options: options
    $articles.removeClass 'obscured'
  
  showMeta: ($article) ->
    # Animate in article metadata
    $article.find(constants.dom.articleMeta).find('li').velocity
      properties:
        scale: [1, 0]
        translateY: [0, -12]
        opacity: [1, 1]
      options:
        begin: =>
          $article.find(constants.dom.articleMeta).show()
          $(@).css
            opacity: 0
        duration: constants.style.duration.hoverArticle
        easing: constants.velocity.easing.smooth
    # If playable, special treatment
    if $article.hasClass('playable')
      $button = $article.find('.playButton')
      x = $button.offset().left - $(window).scrollLeft()
      y = $button.offset().top  - $(window).scrollTop()
      $button.data('startPos', {x: x, y: y})
#       $button.show()
      $button.css
        scale: 0
        opacity: 1
      $button.transition
        x: (event.clientX * (1/1)) - x - $button.width()  / 2
        y: (event.clientY * (1/1)) - y - $button.height() / 2
        scale: 1
        easing: constants.style.easing
        duration: 250
      $article.css
        cursor: 'none'
      $article.find('.artist, .source').velocity
        properties:
          opacity: 1
          scale: 1
        options:
          easing: constants.velocity.easing.smooth
          duration: 500
          
  hideMeta: ($article) ->
    # Animate out article metadata
    $article.find(constants.dom.articleMeta).find('li').velocity
      properties:
        scale: 0
        translateY: -12
      options:
        complete: -> $article.find(constants.dom.articleMeta).hide()
        duration: constants.style.duration.hoverArticle
        easing: constants.velocity.easing.smooth
    # If playable, special treatment
    if $article.hasClass('playable')
      $('.playButton').transition
        x: 0
        y: 0
        scale: 0
        easing: constants.style.easing
        duration: 250
      setTimeout ->
        $('.playButton').css
          opacity: 0
      , 250
      $article.css
        cursor: 'none'
      $article.find('.artist, .source').velocity
        properties:
          opacity: 0
          scale: 0
        options:
          easing: constants.velocity.easing.smooth
          duration: 500

    
  mouseenter: (event, $article) ->
    $article.find('ul.articleCollections').css
      zIndex: 2
    articleView.showMeta($article) # unless $article.hasClass('open') or $article.hasClass('opening')

  mousemove: (event, $article) ->
    if $article.hasClass('playable')
      $button = $article.find('.playButton')
      $button.css
        x: (event.clientX) - $button.data('startPos').x - $button.width()  / 2
        y: (event.clientY) - $button.data('startPos').y - $button.height() / 2

  mouseleave: (event, $article) ->
    $article.find('ul.articleCollections').css
      zIndex: ''
    articleView.hideMeta($article) # unless $article.hasClass('open') or $article.hasClass('opening')

  open: (event, $article) ->
    event.stopPropagation()
    $article.addClass 'opening'
    articleView.obscure $(constants.dom.articleContainer).find('article').not($article)
    $container = $(constants.dom.articleContainer)
    scale = if $article.hasClass 'image' then 1 / ($article.find('img').height() / Math.min($(window).height(), $article.find('img')[0].naturalHeight)) else 1 / constants.style.globalScale
    offset = # distance of article top/left to window top/left
      x: $article.offset().left - $(window).scrollLeft()
      y: $article.offset().top  - $(window).scrollTop()
    $container.velocity
      properties:
        translateX: ($(window).width() / 2)  - (scale * offset.x) - ($article.outerWidth()  / 2)
        translateY: ($(window).height() / 2) - (scale * offset.y) - ($article.outerHeight() / 2)
        scale: if $article.hasClass 'image' then scale else 1
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
        complete: ->
          $article.addClass('open').removeClass('opening')
        #   articleView.resize $article
    $article.trigger 'mouseleave'
    $article.css # must run after trigger('mouseleave')
      zIndex: 2
    $article.find(constants.dom.articleMeta).find('li').velocity
      properties:
        scale: 1
        translateY: 0
        opacity: 1
      options:
        duration: constants.style.duration.hoverArticle
        easing: constants.velocity.easing.smooth
    hideNav()

  resize: ($article) ->
    $article.width  $article.children('.card').outerWidth()
    $article.height $article.children('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()

  close: (event, $article) ->
    articleView.unobscure ($(constants.dom.articleContainer).find('article').not($article))
    $container = $(constants.dom.articleContainer)
    $article.removeClass 'open'
    if $article.hasClass('playable')
      stopPlaying $article
    $container.velocity
      properties:
        translateX: 0
        translateY: 0
        scale:      constants.style.globalScale
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
    extendNav()

  onCollectionOver: ($article, event, $collection) ->
    $card = $article.children('.card')
    $color = $('<div></div>').appendTo($article).addClass('backgroundColor').css
      position: 'absolute'
      zIndex: 5
      top: 0
      left: 0
      right: 0
      bottom: 0
      backgroundColor: 'transparent'
      'mix-blend-mode': 'multiply'  
    $color.transition
      backgroundColor: $collection.find('a').css '-webkit-text-fill-color'
      duration: 500
      easing: constants.style.easing
    $article.find('.card').transition
#       'mix-blend-mode': 'multiply'
      '-webkit-filter': 'grayscale(1)'
      duration: 500
      easing: constants.style.easing

  onCollectionOut: ($article, event, $collection) ->
    $('.backgroundColor').remove()
    $article.find('.card').transition
      '-webkit-filter': ''
      duration: 500
      easing: constants.style.easing