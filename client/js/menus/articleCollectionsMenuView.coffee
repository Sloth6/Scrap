window.articleCollectionsMenuView =
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
    articleCollectionsMenuController.initAddCollectionsMenu $article
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
    articleCollectionsMenuView.hideAddCollectionMenu $article

  articleCollectionEnter: ($animate, event) ->
    $animate.velocity('stop', true).velocity
      properties:
        scale: 1.25
      options:
        duration: 250
        easing: constants.velocity.easing.smooth
        complete: ->
          $animate.addClass 'popLayer'
          $animate.attr 'data-popdepth', '.5'

  articleCollectionLeave: ($animate, event) ->
    $animate.removeClass 'popLayer'
    $animate.attr 'data-popdepth', ''
    $animate.velocity('stop', true).velocity
      properties:
        scale: 1
        translateY: 0
        translateX: 0
      options:
        duration: 250
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
