stackCreate = (cover) ->
  transform = $('<div>').addClass('transform')
  cover.addClass('stack').removeClass('cover').empty().append transform
  # $('div').addClass('stack').data('content', {spaceKey})

stackPopulate = (stack) ->
  spaceKey = stack.data('content')
  loadElements spaceKey, (elements) ->
    stackAdd stack, elements.not('.addElementForm')
    collectionRealign()

stackAdd = (stack, elements) ->
  # elements = elements.not('.cover')#.slice(1, 6)
  if !stack.find('.transform').length
    stack.append $('<div>').addClass('transform')
  elements.
    css('transform', 'none').
    removeClass('sliding').
    removeClass('draggable').
    removeClass('slider')
    
  elements.find('.card').
      removeClass('cardDrag').
      removeClass('cardHover')

  stack.children('.transform').append $.makeArray(elements).reverse()
  maxX = 0
  maxY = 0
  spacing = 20
  for i in [0...stack.find('.element').length]
    e = $(stack.find('.element')[i])
    offset = i*spacing
    maxX = Math.max(maxX, offset+sliderWidth(e))
    maxY = Math.max(maxY, e.height())
    e.css 'left', offset

  stack.width maxX
  stack.height maxY
  stack.data 'width', maxX
  collectionRealign()
     