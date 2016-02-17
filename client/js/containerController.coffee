window.containerController =
  init: ($container) ->
    $container.packery
      itemSelector: 'article'
      isOriginTop: true
      transitionDuration: '0.5s'
      gutter: 0 #constants.style.gutter

    $container.packery 'bindResize'

    $container.droppable
      greedy: true
      drop: (event, ui) ->
        $collection = ui.draggable
        articleController.removeCollection $collection.parent().parent(), $collection

    $container.css
      width: "#{100/constants.style.globalScale}%"
    $container.velocity
      properties:
        translateZ: 0
        scale: constants.style.globalScale
      options:
        duration: 1
