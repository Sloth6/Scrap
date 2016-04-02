window.containerView =
  switchToCollection: (collectionKey) ->
    $container = $(constants.dom.articleContainer)
    $articles  = $container.find('article').not $(constants.dom.addArticleMenu)
    $matched   = if collectionKey is 'recent' then $articles else $articles.filter(".#{collectionKey}")
    # $unmatched  = if collectionKey is 'recent' then $('')                      else $container.find('article').not(".#{collectionKey}")
    $unmatched = $articles.not ".#{collectionKey}"

    # Scroll to top
    $('body').velocity('stop', true).velocity 'scroll', {
      duration: 1000
      easing: constants.velocity.easing.smooth
    }

    # Hide unmatched articles
    $unmatched.each ->
      $(@).velocity
        properties:
          translateY: ($(window).height() / constants.style.globalScale) * (Math.random() - .5)
          translateX: if ($(@).offset().left > $(window).width() / 2) then $(window).width() / constants.style.globalScale else -$(window).width()  / constants.style.globalScale
          rotateZ: 270 * (Math.random() - .5)
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          complete: ->
            $(@).hide()
            $(constants.dom.articleContainer).packery()

    # Show matched articles
    $matched.show()
    $matched.css 'opacity', 0
    $container.packery
      transitionDuration: 0
    $matched.each ->
      startX = if ($(@).offset().left > $(window).width() / 2) then $(window).width() else -$(window).width()
      $(@).velocity
        properties:
          translateY: [0, $(window).height() * (Math.random() - .5)]
          translateX: [0, startX]
          rotateZ: [0, 270 * (Math.random() - .5)]
          opacity: [1, 0]
        options:
          duration: 500
          easing: constants.velocity.easing.smooth
          begin: -> $(@).show()
          complete: ->
            if $matched.index() is $matched.length - 1 # last article
              $container.packery
                transitionDuration: 500

    window.openCollection = collectionKey
    $container.packery()
    containerView.updateHeight $(constants.dom.wrapper), $container

  updateScale: () ->
    $scale = $(constants.dom.containerScale)
    origin = 'top left'

    $scale.css
      'transform-origin': origin
      '-webkit-transform-origin': origin
      '-ms-transform-origin': origin
      width: "#{100/constants.style.globalScale}%"

    $scale.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1

  updateHeight: ($wrapper, $container) ->
    $wrapper.css
      height:    $container.height() * constants.style.globalScale
      minHeight: $container.height() * constants.style.globalScale

