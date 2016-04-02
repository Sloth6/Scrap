# TODO, clean this
scaleWhenOpen = ($article) ->
  return 1 / constants.style.globalScale

window.articleView =
  init: ($article) ->
    $card       = $article.find('.card')
    $firstLabel = $article.find('ul.articleCollections li.collection').first().find('a')

    # Scale up labels indicator inversely proportional to global scale
    scale = 1 / constants.style.globalScale
    $.Velocity.hook $article.find('ul.articleCollections .scale'), 'scale', scale
    popController.init $article, 500, constants.style.articleHoverScale / constants.style.globalScale

    # Base color by first label.
    if $firstLabel.length and $article.hasClass('text') or $article.hasClass('website')
      $backgroundColor = $('<div></div>').prependTo($(@).find('.card')).css
        backgroundColor: $firstLabel.css('background-color')
        position: 'absolute'
        top: 0
        left: 0
        right: 0
        bottom: 0
        opacity: .25
    # Init playable
    if $article.hasClass('playable')
      $article.find('.artist', '.source').css
        position: 'absolute'
        opacity: 0
      $.Velocity.hook($article.find('.artist, .source'), 'scale', '0')
    # Init website
    else if $article.hasClass 'website'
      styleUtilities.transformOrigin $article.find('.description'), 'center', 'top'
      $article.find('.image').velocity('stop', true).velocity
        properties:
          marginTop: -$article.find('.description').height()
        options:
          duration: 500
          easing: constants.velocity.easing.smooth

  # When global scale or article scale is changed
  updateScale: ($articles, scale) ->
    $articles.each ->
      $card       = $(@).find('.card')
      $card.css
        borderWidth: 1 / scale + 'px'

  obscure: ($articles) ->
    $cards      = $articles.find('.card')
    $contents   = $cards.children().add($articles.find('ul, .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity('stop', true).velocity
      properties:
        opacity: 0
      options: options

    # Store original background color
    $cards.each ->
      $(@).data 'originalBackground', $(@).css('background-color')
      # Transition card background color to white
      $(@).transition
        backgroundColor: 'white'
        duration: 500
        easing: constants.style.easing
    $articles.addClass 'obscured'

  unobscure: ($articles) ->
    $cards      = $articles.find('.card')
    $contents   = $cards.children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity('stop', true).velocity
      properties:
        opacity: 1
      options: options
    # Transition card background color to original
    $cards.each ->
      $(@).transition
        backgroundColor: $(@).data 'originalBackground'
        duration: 500
        easing: constants.style.easing
    $articles.removeClass 'obscured'

  showMeta: ($article) ->
    $li = $article.find(constants.dom.articleMeta).find('li')
    $li.velocity('stop', true).velocity
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

    scale = $article.find('ul.articleCollections .scale')
    scale.velocity('stop', true).velocity
      properties:
        scale: constants.style.articleHoverScale / constants.style.globalScale
      options:
        easing: constants.velocity.easing.smooth
        duration: 500

  hideMeta: ($article) ->
    # Animate out article metadata
    $li = $article.find(constants.dom.articleMeta).find('li')
    $li.velocity('stop', true).velocity
      properties:
        scale: 0
        translateY: -12
      options:
        complete: -> $article.find(constants.dom.articleMeta).hide()
        duration: constants.style.duration.hoverArticle
        easing: constants.velocity.easing.smooth

    scale = $article.find('ul.articleCollections .scale')
    scale.velocity('stop', true).velocity
      properties:
        scale: 1 / constants.style.globalScale
      options:
        easing: constants.velocity.easing.smooth
        duration: 500

  mouseenter: (event, $article) ->
    $card     = $article.find('.card')
    $article.zIndex 999
    $article.find('ul.articleCollections').css
      zIndex: 2

    articleView.showMeta($article) unless $article.hasClass('open')

    unless $article.hasClass 'open'
      articleCollectionsMenuView.expandLabels $article

    if $article.hasClass 'playable'
      cursor = '▶︎'
      $article.find('.artist, .source').velocity('stop', true).velocity
        properties:
          opacity: 1
          scale: 1
        options:
          easing: constants.velocity.easing.smooth
          duration: 500

    else if $article.hasClass 'website'
      cursor    = '→'
      $h1       = $article.find('h1')
      $header   = $article.find('header')
      $detail   = $header.find('.detail')
      $image      = $article.find('.image')
      $article.find('a').css 'cursor', 'none'
      $detail.find('.description').velocity('stop', true).velocity
        properties:
          opacity: 1
          scale: [1, .5]
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
      $image.velocity('stop', true).velocity
        properties:
          marginTop: 0
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
    else if $article.hasClass 'image'
      cursor = '+'
    else if $article.hasClass 'text'
      cursor = '✎'
    else
      cursor = 'Open'
    cursorView.start cursor, event
    # Adjust border width
    articleView.updateScale $article, $.Velocity.hook $article.find('.transform'), 'scale'

  mouseleave: ($article) ->
    $article.zIndex 0
    $article.find('ul.articleCollections').css { zIndex: '' }
    articleView.hideMeta($article) unless $article.hasClass('open')
    articleCollectionsMenuView.closeLabels($article) unless $article.hasClass('open')
    articleCollectionsMenuView.hideAddCollectionMenu $article
    if $article.hasClass('playable')
      $article.find('.artist, .source').velocity
        properties:
          opacity: 0
          scale: 0
        options:
          easing: constants.velocity.easing.smooth
          queue: false
          duration: 500
    if $article.hasClass 'website'
      $h1 = $article.find('h1')
      $card = $article.find('.card')
      $header = $article.find('header')
      $image = $article.find('.image')
      $image.velocity
        properties:
          marginTop: -$header.find('.description').height()
        options:
          duration: 500
          queue: false
          easing: constants.velocity.easing.smooth
      $header.find('.description').velocity
        properties:
          opacity: 0
          scale: [.5, 1]
        options:
          duration: 500
          queue: false
          easing: constants.velocity.easing.smooth
    # Adjust border width
    articleView.updateScale $article, constants.style.globalScale
    # Close menus
    menuController.close $article.find(constants.dom.controls.menus)

  mousemove: (event, $article) ->
#     cursorView.move event

  open: ($article) ->
    articleView.obscure $('article').not($article)

    # Move to center
    translateY = - $article.offset().top + $(window).scrollTop() + $(window).height()/2
    translateX = - $article.offset().left  + $(window).width()/2

    # Move over by half
    translateY -= ($article.height()/(2/constants.style.globalScale))
    translateX -= ($article.width()/(2/constants.style.globalScale))

    $article.velocity('stop', true).velocity
      properties:
        scale: scaleWhenOpen($article)
        translateX: translateX
        translateY: translateY

      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
        complete: () ->
          $article.addClass 'open'

    $article.trigger 'mouseleave'
    popController.end $article
    $article.css { zIndex: 2 }# must run after trigger('mouseleave')

    $article.mouseleave (event) -> cursorView.start '✕', event
    $article.mouseenter -> cursorView.end()

    $li = $article.find(constants.dom.articleMeta).find('li')
    $li.velocity('stop', true).velocity
      properties:
        scale: 1
        translateY: 0
        opacity: 1
      options:
        duration: constants.style.duration.hoverArticle
        easing: constants.velocity.easing.smooth

  resize: ($article) ->
    $article.width  $article.find('.card').outerWidth()
    $article.height $article.find('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()

  close: ($article) ->
    $article.velocity('stop', true).velocity
      properties:
        translateX: 0
        translateY: 0
        scale: 1
      options:
        complete: () ->
          $article.zIndex 0
          $article.removeClass 'open'


    articleView.unobscure ($(constants.dom.articleContainer).find('article').not($article))
