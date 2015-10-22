stackCreate = (cover) ->
  transform = $('<div>').addClass('transform')
  cover.addClass('stack').removeClass('cover').empty().append transform
  # $('div').addClass('stack').data('content', {spaceKey})

stackPopulate = (stack) ->
  # console.log 'stack stackPopulate', stack
  spaceKey = stack.data('content').spaceKey
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
  max = 0
  spacing = 20
  for i in [0...stack.find('.element').length]
    e = $(stack.find('.element')[i])
    offset = i*spacing
    max = Math.max(max, offset+e.width())
    e.css 'left', offset

  stack.data 'width', max
  collectionRealign()

#check for reduce
# stackUpdate = (stack) ->
#   console.log 'updating', stack
#   if 

# createStack = (cover) ->
#   # stack = $('div').addClass('stack').

#   # stack = $('div').addClass('stack')
#   stack = cover.
#             removeClass('cover').
#             addClass('stack').
#             empty()
#   # $.each cover.prop("attributes"), () ->
#   #   stack.attr @name, @value

#   spaceKey = stack.data('content').spaceKey
#   spacing = 25
#   loadElements spaceKey, (elements) ->
#     elements = elements.not('.cover').slice(1, 6)
#     stack.append elements
#     max = 0
#     for i in [0...elements.length]
#       e = $(elements[i])
#       offset = i*spacing
#       max = Math.max(max, offset+e.width())
#       e.css 'left', offset

#     # stack.data 'width', max
#     stack.width max
#     realign()
#     