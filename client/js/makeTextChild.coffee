detach = (child) ->
  id = child.attr 'id'
  child.removeClass 'attached'
  parent = child.data 'parent'
  if parent
    parent = $('#'+parent)
    children = parent.data 'children'
    children.splice(children.indexOf(id),1)
    parent.data 'children', children
  child.data 'parent', null

makeTextChild = (elem) ->
  getCoords = (elem) ->
    $elem = $(elem)
    offset = $elem.offset()
    dimens = dimension $elem
    elem =
      id: Math.floor(parseInt($elem.attr('id')))
      left: Math.floor(parseInt($elem.css('left')))
      top: Math.floor(parseInt($elem.css('top')))
      w: Math.floor(dimens.w)
      h: Math.floor(dimens.h)

  intersect = (a, b) ->
    return false if a.id == b.id
    offset = 0#10 / screenScale
    maxAx = a.left + a.w + offset
    maxAy = a.top + a.h + offset

    maxBx = b.left + b.w + offset
    maxBy = b.top + b.h + offset

    minAx = a.left - offset
    minAy = a.top - offset

    minBx = b.left - offset
    minBy = b.top - offset

    aLeftOfB  = maxAx < minBx;
    aRightOfB = minAx > maxBx;
    aAboveB   = minAy > maxBy;
    aBelowB   = maxAy < minBy;
    return !( aLeftOfB || aRightOfB || aAboveB || aBelowB )


  isWithen = (a, b) ->
    return false unless a.top > b.top
    return false unless a.left > b.left
    return false unless a.top+a.h < b.top+b.h
    return false unless a.left+a.w < b.left+b.w
    return true

  getAllCoords = () ->
    # $(".content .card .image,.website").parent().get().map getCoords
    $("article:not(.text)").get().map getCoords
    
  getParent = (elem, others) -> 
    for b in others
      if intersect elem, b
        return $('#'+b.id)
    null
  
  attach = (child, parent) ->
    child.addClass 'attached'
    elem.data 'parent', parent.attr('id')
    
    children = parent.data('children') or []
    children.push child.attr('id')
    parent.data 'children', children

  
  return unless elem.children().hasClass('text')
  detach elem
  parent = getParent getCoords(elem), getAllCoords()
  attach(elem, parent) if parent 


$ ->
  $('article').not('#spaceName').each () ->
    makeTextChild $(this)