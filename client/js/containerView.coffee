window.containerView =
  switchToCollection: (collectionKey) ->
    $container  = $(constants.dom.articleContainer)
    $matched    = if collectionKey is 'recent' then $container.find('article') else $container.find("article.#{collectionKey}")
    $unmatched  = if collectionKey is 'recent' then $('')                      else $container.find('article').not(".#{collectionKey}")

    console.log 'Switch!'

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

  updateHeight: ($wrapper, $container) ->
    console.log 'height', $container.height()
    $wrapper.css
      height:    $container.height() * constants.style.globalScale
      minHeight: $container.height() * constants.style.globalScale

