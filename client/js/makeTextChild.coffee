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

  isWithen = (a, b) ->
    return false unless a.top > b.top
    return false unless a.left > b.left
    return false unless a.top+a.h < b.top+b.h
    return false unless a.left+a.w < b.left+b.w
    return true

  getAllCoords = () ->
    $('.content').children().get().map getCoords
    
  getParent = (elem, others) -> 
    for b in others
      return $('#'+b.id) if isWithen elem, b 
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
  $('article').each () ->
    makeTextChild $(this)