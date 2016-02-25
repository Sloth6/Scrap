window.containerController =
  init: ($container) ->
    $wrapper      = $('.wrapper')
    
    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      transitionDuration: '0.0s'
      gutter: 0 #constants.style.gutter
      isOriginTop: false

    $container.packery 'bindResize'
    
    $wrapper.mousemove (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length
        cursorView.start '+'
            
    $wrapper.click (event) ->
      unless scrapState.openArticle? or $("#{constants.dom.articles}:hover").length 
        containerView.insertNewArticleForm(event)
        console.log 'click wrapper', $container.data 'canInsertFormOnClick'
#       cursorView.end()

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleController.removeCollection $collection.parent().parent(), $collection

    containerView.updateHeight $wrapper, $container
    $container.css
      width: "#{100/constants.style.globalScale}%"
    $container.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1
