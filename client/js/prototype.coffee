resizeCards = (minSize, gutter) ->
  $('article').each () ->
    $(@).css({
      'padding-left':   if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-top':    if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-bottom': if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-right':  if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
    })


initItems = () ->
  $('.item').each () ->
    $(@).css {
#       height: Math.random() * 100
#       width: Math.random() * 100
    }
    
onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 6 else 12
  resizeCards(cardSize, gutter)

$ ->
  initItems()
    
  $(window).resize () -> onResize()
  onResize()

  $('.container').packery()