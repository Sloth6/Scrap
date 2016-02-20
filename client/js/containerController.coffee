window.containerController =
  init: ($container) ->
    isOverArticle = false
    $wrapper      = $('.wrapper')
    
    # Will clicking the wrapper insert a new add form?
    $container.data 'canInsertFormOnClick', false
    
    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      transitionDuration: '0.0s'
      gutter: 0 #constants.style.gutter
      isOriginTop: false

    $container.packery 'bindResize'
    
    $wrapper.mousemove (event) ->
      if $("#{constants.dom.articles}:hover").length # If over article
        if isOverArticle
          cursorView.end $wrapper, $wrapper.children('.cursor')
          $container.data 'canInsertFormOnClick', false
        isOverArticle = false
      else
        if isOverArticle
          cursorView.move event, 1
          $container.data 'canInsertFormOnClick', true
        else
          cursorView.start '+', $wrapper, 1
        isOverArticle = true
    
    $wrapper.click (event) ->
      containerView.insertNewArticleForm() if $container.data('canInsertFormOnClick')

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleController.removeCollection $collection.parent().parent(), $collection

    $container.css
      width: "#{100/constants.style.globalScale}%"
#       minHeight: "#{85/constants.style.globalScale}vh"
#       maxHeight: $container.height()/8
    $container.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1
