repack = () ->
  if $('.container').data('uiState', 'recents') # only repack when in recents review
    $('.container').packery {
      itemSelector: 'article'
      transitionDuration: 0
    }
    saveItemPositions()

resizeCards = (minSize, gutter) ->
  $('article').each () ->
    $(@).css({
      'padding-left':   gutter
      'padding-top':    gutter
      'padding-bottom': gutter
      'padding-right':  gutter
#       'padding-left':   if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-top':    if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-bottom': if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-right':  if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
    })
    
saveItemPositions = () ->
  $('article').each () ->
    $(@).data('packeryTop', $(@).css('top').toString())
    $(@).data('packeryLeft', $(@).css('left').toString())


initItems = () ->
  saveItemPositions()
    
onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 6 else 12
  resizeCards(cardSize, gutter)
  repack()
  
initOnLoad = () ->
  $('img').load () ->
    repack()

initDrag = () ->
  itemElems = $('.container').packery('getItemElements')
  for elem in itemElems
    draggie = new Draggabilly( elem )
#     draggie.on( 'dragEnd', repack )
    $('.container').packery 'bindDraggabillyEvents', draggie
    
switchProperties = ($article, property, state) ->
  if property is 'transform'
    absoluteLeft  = ''
    absoluteTop   = ''
    if state is 'packs'
      transformLeft = $article.css 'left'
      transformTop  = $article.css 'top'
    else # recents
      transformLeft = $article.data 'packeryLeft'
      transformTop  = $article.data 'packeryTop'
  else # absolute positioning
    transformLeft = '0px'
    transformTop  = '0px'
    if state is 'packs'
      absoluteLeft  = $.Velocity.hook $article, 'translateX'
      absoluteTop   = $.Velocity.hook $article, 'translateY'
    else # recents
      absoluteLeft  = $article.data 'packeryLeft'
      absoluteTop   = $article.data 'packeryTop'
  $article.css
    left: absoluteLeft
    top:  absoluteTop
  $.Velocity.hook $article, 'translateX', transformLeft
  $.Velocity.hook $article, 'translateY', transformTop
      
toggleState = () ->
  if $('.container').data('uiState') is 'recents' # Switch to packs
    $('.container').data 'uiState', 'packs'
    $('article').each () ->
      switchProperties($(@), 'transform', 'recents')
    $('article').each () ->
      $(@).velocity
        properties:
          translateX: Math.random() * 600
          translateY: Math.random() * 600
        options:
          duration: 1000
          easing: [75, 10]
          complete: () ->
            switchProperties($(@), 'absolute', 'packs')
  else # Switch to recents
    $('.container').data 'uiState', 'recents'
    $('article').each () ->
      switchProperties($(@), 'transform', 'packs')
    $('article').each () ->
      $(@).velocity
        properties:
          translateX: $(@).data 'packeryLeft'
          translateY: $(@).data 'packeryTop'
        options:
          duration: 1000
          easing: [75, 10]
          complete: () ->
            switchProperties($(@), 'absolute', 'recents')
$ ->
  initItems()
  initOnLoad()
    
  $(window).resize () -> onResize()
  onResize()
  initDrag()
  
  $('.container').data 'uiState', 'recents'
  
  $('body').click () ->
    unless $('.velocity-animating').length > 0 # only toggle state if not animating
      toggleState()
