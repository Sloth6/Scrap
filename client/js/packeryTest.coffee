$ ->
  $('.item').each () ->
    w = Math.random() * 200 + 100
    h = Math.random() * 200 + 100
    # h = a / w
    $(@).width(w)
    $(@).height(h)
    $(@).css
      'background-color': 'red'
      'border': 'solid'

  $container = $('#container')
  $container.packery({
    itemSelector: '.item'
    isOriginTop: false
    gutter: 10
  }).packery('bindResize')

  setInterval (() ->
    w = Math.random() * 200 + 100
    h = Math.random() * 200 + 100
    item = $('<div>')
    item.
      addClass('item').
      width(w).
      height(h).
      css
        'background-color': 'red'
        'border': 'solid'

    $container.append(item)
    $container.packery('appended', item)

  ), 1000



  reorder = () ->
    console.log 'reorder'
    element = $(@.$element[0])
    
    closest = null
    min_d = Infinity 
    
    x1 = parseInt(element.css('left')) + element.width()/2
    y1 = parseInt(element.css('top')) + element.height()/2
    console.log x1, y1
    $('.item').not(element).each () ->
      x2 = parseInt($(@).css('left')) + $(@).width()/2
      y2 = parseInt($(@).css('top')) + $(@).height()/2
      d = Math.sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) )
      if d < min_d
        min_d = d
        closest = $(@)
    
    console.log closest
    

    element.insertAfter closest
    $container.packery('reloadItems').packery()
    # 
    # $container.packery( 'remove', element)
    # $container.append(element)
    # $container.packery( 'appended', element )
    # $container.packery()
    # x = element.css('top')
    # y = element.css('left')
    # $container.packery( 'fit', element, x, y )
    # items = $container.packery('getItemElements')
    # $container.packery()
    # i = 0
    # for elem in itemElems
    #   $(elem).find('p').text(i)
    #   i++

  itemElems = $container.packery('getItemElements')
  for elem in itemElems
    draggie = new Draggabilly( elem )
    # draggie.on( 'dragEnd', reorder )
    $container.packery 'bindDraggabillyEvents', draggie