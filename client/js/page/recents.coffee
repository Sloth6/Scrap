$ ->
  $('article').each () ->
    $content = $(@).children('content')
    $(@).width($content.width())
    $(@).height($content.height())

  $container = $('#container')
  $container.packery({
    itemSelector: 'article'
    isOriginTop: true
    gutter: 20
  }).packery('bindResize')

  itemElems = $container.packery('getItemElements')
  for elem in itemElems
    draggie = new Draggabilly( elem )
    $container.packery 'bindDraggabillyEvents', draggie