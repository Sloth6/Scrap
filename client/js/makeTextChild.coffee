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
      return b if isWithen elem, b 
    null
  
  return unless elem.children().hasClass('comment')
  parent = getParent getCoords(elem), getAllCoords()
  # console.log parent
  id = elem[0].id
  if parent
    elem.addClass 'attached'
    parentElem = $('#'+parent.id)
    elem.data 'attachedTo', parentElem
    comments = parentElem.data('comments') or []
    comments.push id
    parentElem.data('comments', comments)
  else
    elem.removeClass 'attached'
    old_parent = elem.data 'attachedTo'
    if old_parent
      comments = old_parent.data('comments')
      comments.splice(comments.indexOf(id),1)
      old_parent.data('comments', comments)
    elem.data 'attachedTo', null

$ ->
  $('article').each () ->
    makeTextChild $(this)