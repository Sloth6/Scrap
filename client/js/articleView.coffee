# TODO, clean this
scaleWhenOpen = ($article) ->
  # return 3
  if $article.hasClass 'image'
    1 / ($article.find('img').height() / Math.min($(window).height(), $article.find('img')[0].naturalHeight))
  else
    1 / constants.style.globalScale

window.articleView =
  obscure: ($articles) ->
#     $articles.hide()
#     return
    $contents   = $articles.find('.card').children().add($articles.find('article ul, article .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity
      properties:
        opacity: 0
        duration: 1
      options: options
    $articles.addClass 'obscured'

  unobscure: ($articles) ->
#     $articles.show()
#     return
    $contents   = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
    options     =
      duration: constants.style.duration.openArticle
      easing:   constants.velocity.easing.smooth
    $contents.velocity
      properties:
        opacity: 1
        duration: 1
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
    $article.find('ul.articleCollections .scale').velocity
      properties:
        scale: constants.style.articleHoverScale / constants.style.globalScale
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
    $article.find('ul.articleCollections .scale').velocity
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
      $a = $label.find('a')
      $dot = $label.find('.dot')
      delay = $label.index() * 60
            
#       $.Velocity.hook $label, 'translateX', "#{dotWidths}px"
      
      $label.velocity
        properties:
          translateX: dotWidths
          translateY: 0
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
      $a.velocity
        properties:
          scaleX: [$dot.width()  / $a.width(), 1]
          scaleY: [$dot.height() / $a.height(),1]
          opacity: [0, 1]
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
          complete: -> $a.hide()
      $dot.velocity
        properties:
          scaleX: [1, $a.data('naturalWidth') /  $dot.data('naturalWidth')]
          scaleY: [1, $a.data('naturalHeight') / $dot.data('naturalHeight')]
          opacity: 1
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
          begin: -> $dot.show()
      dotWidths += $dot.data 'naturalWidth'
    
  expandLabels: ($article) ->
    options =
      duration: 500
      easing: constants.velocity.easing.spring
    labelHeights = -72
    $article.find('ul.articleCollections li').each ->
      $label = $(@)
      $a = $label.find('a')
      $dot = $label.find('.dot')
      console.log $label.text()
      
      delay = $label.index() * 60
      $label.velocity
        properties:
          translateX: constants.style.margin.articleText.left
          translateY: labelHeights
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
      $a.velocity
        properties:
          scaleX: [1, $dot.data('naturalWidth')  / $a.data('naturalWidth') ]
          scaleY: [1, $dot.data('naturalHeight') / $a.data('naturalHeight')]
          opacity: 1
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
          begin: -> $a.show()
      $dot.velocity
        properties:
          scaleX: $a.data('naturalWidth')  / $dot.data('naturalWidth')
          scaleY: $a.data('naturalHeight') / $dot.data('naturalHeight')
          opacity: [-1, 1]
        options:
          duration: options.duration + delay
          easing: options.easing
#           delay: delay
          complete: -> $dot.hide()
      labelHeights -= $a.data 'naturalHeight'

  mouseenter: (event, $article) ->
    $article.find('ul.articleCollections').css
      zIndex: 2
    articleView.showMeta($article) unless $article.hasClass('open')
    articleView.expandLabels($article) unless $article.hasClass('open')
    if $article.hasClass 'playable'
      cursor = '▶︎'
      $article.find('.artist, .source').velocity
        properties:
          opacity: 1
          scale: 1
        options:
          easing: constants.velocity.easing.smooth
          duration: 500
    else if $article.hasClass 'website'
      cursor = '→'
      $h1 = $article.find('h1')
      $card = $article.find('.card')
      $header = $article.find('header')
      $img = $article.find('.image')
      $article.find('a').css 'cursor', 'none'
      $h1.transition
        '-webkit-text-fill-color': 'black'
        '-webkit-text-stroke-color': 'transparent'
        duration: 500
        easing: constants.style.easing
      $img.velocity
        properties:
          marginTop: $header.height() + parseFloat($header.css('padding-top')) + parseFloat($header.css('padding-bottom'))
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
      $header.find('.source,.description').velocity
        properties:
          opacity: 1
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
    else if $article.hasClass 'image'
      cursor = '+'
    else if $article.hasClass 'text'
      cursor = '✎'
    else
      cursor = 'Open'
    cursorView.start cursor

  mouseleave: (event, $article) ->
    $article.find('ul.articleCollections').css { zIndex: '' }
    articleView.hideMeta($article) unless $article.hasClass('open')
    articleView.closeLabels($article) unless $article.hasClass('open')
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
      $article.find('.artist, .source').velocity
        properties:
          opacity: 0
          scale: 0
        options:
          easing: constants.velocity.easing.smooth
          duration: 500
    if $article.hasClass 'website'
      $h1 = $article.find('h1')
      $card = $article.find('.card')
      $header = $article.find('header')
      $img = $article.find('.image')
      $h1.transition
        '-webkit-text-fill-color': ''
        '-webkit-text-stroke-color': ''
        duration: 500
        easing: constants.style.easing
      $img.velocity
        properties:
          marginTop: 0
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
      $header.find('.source,.description').velocity
        properties:
          opacity: 0
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
#     cursorView.end()
    
  mousemove: (event, $article) ->
#     cursorView.move event
    
  open: (event, $article) ->
    $container = $(constants.dom.articleContainer)
    articleView.obscure $('article').not($article)

    centerX = ($elem) ->
      return $(window).width()/2 if $elem.is($(window))
      $elem.offset().left + ($elem.width()/2)*constants.style.globalScale
    centerY = ($elem) ->
      return $(window).height()/2 if $elem.is($(window))
      $elem.offset().top + ($elem.height()/2)*constants.style.globalScale

    $article.velocity
      properties:
        scale: scaleWhenOpen($article)
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
    $container.velocity
      properties:
        translateX: (- (centerX($article) - centerX($(window)))) / constants.style.globalScale
        translateY: (- (centerY($article) - centerY($(window))) + $(window).scrollTop())/constants.style.globalScale
      options:
        duration: constants.style.duration.openArticle
        easing: constants.velocity.easing.smooth
        queue: false
        complete: () ->
          $article.addClass 'open'

    $article.trigger 'mouseleave'
    unparallax($article.find('.transform'), 500, constants.velocity.easing.smooth)
    $article.css {zIndex: 2}# must run after trigger('mouseleave')
#     cursorView.end()
    cursorView.start '✕'
#     cursorView.move event
#     $('body').mousemove (event) -> cursorView.move event

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
    console.log 'resize'
    $article.width  $article.children('.card').outerWidth()
    $article.height $article.children('.card').outerHeight()
    $( constants.dom.articleContainer ).packery()

  close: (event, $article) ->
    $article.velocity
      scale: 1
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
        begin: () ->
          $article.removeClass 'open'
    extendNav()
#     cursorView.end()

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
