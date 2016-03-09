# TODO, clean this
scaleWhenOpen = ($article) ->
  # return 3
  if $article.hasClass 'image'
    1 / ($article.find('img').height() / Math.min($(window).height(), $article.find('img')[0].naturalHeight))
  else
    1 / constants.style.globalScale

window.articleView =
  init: ($article) ->
    $card       = $article.find('.card')
    $firstLabel = $article.find('ul.articleCollections li.collection').first().find('a')

        # Scale up labels indicator inversely proportional to global scale
    scale = 1 / constants.style.globalScale
    $.Velocity.hook $article.find('ul.articleCollections .scale'), 'scale', scale
    # Add random ragged edges
#     $article.css
#       marginTop:    Math.random() * constants.style.maxGutter
#       marginRight:  Math.random() * constants.style.maxGutter
#       marginBottom: Math.random() * constants.style.maxGutter
#       marginLeft:   Math.random() * constants.style.maxGutter
    parallaxHover $article, 500, constants.style.articleHoverScale / constants.style.globalScale
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
        duration: 1
      options: options

    # # Store original background color
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
        duration: 1
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

  closeLabels: ($article) ->
    dotWidths = 0
    options =
      duration: 500
      easing: constants.velocity.easing.spring
    $article.find('ul.articleCollections li').each ->
      $label = $(@)
      $a =   $label.children 'a'
      $dot = $label.children '.dot'
      delay = $label.index() * 60
      $label.velocity('stop', true).velocity
        properties:
          translateX: dotWidths
          translateY: 0
        options:
          duration: options.duration + delay
          easing: options.easing
      $a.velocity('stop', true).velocity
        properties:
          scaleX: [$dot.width()  / $a.width(), 1]
          scaleY: [$dot.height() / $a.height(),1]
          opacity: [0, 1]
        options:
          duration: options.duration + delay
          easing: options.easing
          complete: -> $a.hide()
      $dot.velocity('stop', true).velocity
        properties:
          scaleX: [1, $a.data('naturalWidth') /  $dot.data('naturalWidth')]
          scaleY: [1, $a.data('naturalHeight') / $dot.data('naturalHeight')]
          opacity: 1
        options:
          duration: options.duration + delay
          easing: options.easing
          begin: -> $dot.show()
      dotWidths += $dot.data 'naturalWidth'

  expandLabels: ($article) ->
    options =
      duration: 500
      easing: constants.velocity.easing.spring
    labelHeights = -72
    $article.find('ul.articleCollections li').each ->
      $label = $(@)
      $a =   $label.children 'a'
      $dot = $label.children '.dot'
      delay = $label.index() * 60
      $label.velocity('stop', true).velocity
        properties:
          translateX: constants.style.margin.articleText.left
          translateY: labelHeights
        options:
          duration: options.duration + delay
          easing: options.easing
      $a.velocity('stop', true).velocity
        properties:
          scaleX: [1, $dot.data('naturalWidth')  / $a.data('naturalWidth') ]
          scaleY: [1, $dot.data('naturalHeight') / $a.data('naturalHeight')]
          opacity: 1
        options:
          duration: options.duration + delay
          easing: options.easing
          begin: -> $a.show()
      $dot.velocity('stop', true).velocity
        properties:
          scaleX: $a.data('naturalWidth')  / $dot.data('naturalWidth')
          scaleY: $a.data('naturalHeight') / $dot.data('naturalHeight')
          opacity: [-1, 1]
        options:
          duration: options.duration + delay
          easing: options.easing
          complete: -> $dot.hide()
      labelHeights -= $a.data 'naturalHeight'

  showAddCollectionMenu: ($article) ->
    $collections  = $article.find 'ul.articleCollections'
    $menu         = $article.find 'ul.addCollectionMenu'
    $button       = $collections.find('li.addCollection a')
    articleController.initAddCollectionsMenu $article
    $menu.find('li').each ->
      delay = $(@).index() * 125
      toY   = $(@).data 'translateY'
      $(@).velocity('stop', true).velocity
        properties:
          translateY: [toY, $(window).height()]
          opacity: 1
          scale: [1, 0]
          rotateZ: [0, 90 * (Math.random() - .5)]
        options:
          duration: 250 + delay
          easing: constants.velocity.easing.smooth
          complete: -> simpleHover $(@).find('a div'), 250, 1.25
    $menu.find('li').show()
    $menu.find('li').css 'opacity', 0
    $button.text 'Never mind'
    # Hide contents of article
    $article.find('.card').contents().each ->
      $(@).transition
        opacity: 0
        duration: 500
        easing: constants.style.easing
#     articleView.obscure $(constants.dom.articles).not($article)

  hideAddCollectionMenu: ($article) ->
    $collections  = $article.find     'ul.articleCollections'
    $menu         = $article.find     'ul.addCollectionMenu'
    $button       = $collections.find 'li.addCollection a'
    $menu.find('li').not('.added').each ->
      delay = ($menu.find('li').length - $(@).index()) * 125
      $(@).velocity('stop', true).velocity
        properties:
          translateY: $(window).height()
          scale: 0
          rotateZ: 90 * (Math.random() - .5)
        options:
          duration: 250 + delay
          easing: constants.velocity.easing.smooth
          complete: -> $(@).remove()
    $button.text('Add label')
    # Show contents of article
    $article.find('.card').contents().each ->
      $(@).transition
        opacity: 1
        duration: 500
        easing: constants.style.easing
#     articleView.unobscure $(constants.dom.articles).not($article)

  addCollection: ($article, $label) ->
    $collectionsList = $article.find 'ul.articleCollections'
    y = $collectionsList.children('li.addCollection').offset().top - $label.offset().top
    $label.addClass 'added'
    $label.velocity('stop', true).velocity
      properties:
        translateY: y - $label.height()
      options:
        duration: 500
        easing: constants.velocity.easing.smooth
        complete: ->
          $label.appendTo $collectionsList
    $collectionsList.children('li').not('.addCollection').each ->
      startY = parseInt $.Velocity.hook($(@), 'translateY')
      $(@).velocity('stop', true).velocity
        properties:
          translateY: startY-$label.height()
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
    articleView.hideAddCollectionMenu $article
  
  articleCollectionEnter: ($animate, event) ->
    $animate.velocity('stop', true).velocity
      properties:
        scale: 1.25
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
        complete: ->
          $animate.addClass 'parallaxLayer'
          $animate.attr 'data-parallaxdepth', '.5'

  articleCollectionLeave: ($animate, event) ->
    $animate.removeClass 'parallaxLayer'
    $animate.attr 'data-parallaxdepth', ''
    $animate.velocity('stop', true).velocity
      properties:
        scale: 1
        translateY: 0
        translateX: 0
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
  
  mouseenter: (event, $article) ->
    $card     = $article.find('.card')
    $article.find('ul.articleCollections').css
      zIndex: 2
    articleView.showMeta($article) unless $article.hasClass('open')
    articleView.expandLabels($article) unless $article.hasClass('open')
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
    $article.find('ul.articleCollections').css { zIndex: '' }
    articleView.hideMeta($article) unless $article.hasClass('open')
    articleView.closeLabels($article) unless $article.hasClass('open')
    articleView.hideAddCollectionMenu $article
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

  mousemove: (event, $article) ->
#     cursorView.move event

  open: ($article) ->
    $container = $(constants.dom.articleContainer)
    articleView.obscure $('article').not($article)

    centerX = ($elem) ->
      return $(window).width()/2 if $elem.is($(window))
      $elem.offset().left + ($elem.width()/2)*constants.style.globalScale
    centerY = ($elem) ->
      return $(window).height()/2 if $elem.is($(window))
      $elem.offset().top + ($elem.height()/2)*constants.style.globalScale

    $article.velocity('stop', true).velocity
      properties:
        scale: scaleWhenOpen($article)
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
        complete: () ->
          $article.addClass 'open'

    $container.velocity('stop', true).velocity
      properties:
        translateX: (-(centerX($article) - centerX($(window)))) / constants.style.globalScale
        translateY: (-(centerY($article) - centerY($(window))) + $(window).scrollTop())/constants.style.globalScale

    $article.trigger 'mouseleave'
    unparallax($article.find('.transform'), 500, constants.velocity.easing.smooth)
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
    $article.velocity('stop', true)
    $article.removeClass 'open'
    $article.velocity
      properties: {scale: 1 }
    articleView.unobscure ($(constants.dom.articleContainer).find('article').not($article))
    $container = $(constants.dom.articleContainer)
    $container.velocity('stop', true).velocity
      properties:
        translateX: 0
        translateY: 0
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth

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
    $article.trigger 'mouseleave'

  onCollectionOut: ($article, event, $collection) ->
    $('.backgroundColor').remove()
    $article.find('.card').transition
      '-webkit-filter': ''
      duration: 500
      easing: constants.style.easing
