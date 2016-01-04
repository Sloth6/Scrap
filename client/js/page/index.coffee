
resizeCards = (minSize, gutter) ->
  $('.pack.filler').each () ->
    height  = minSize + (Math.round(Math.random() * (minSize*6)))
    width   = minSize + (Math.round(Math.random() * (minSize*6)))
    $(@).find('.card').css({
      'width':  "#{width}px"
      'height': "#{height}px"
    })
  $('.pack').each () ->
    $(@).css({
      'padding-left':  if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-top':   if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
    })
    
  
initLettering = () ->
  width = 0
  left = 0
  marginLoaf = $(window).width()
  $('.lettering').lettering();
  $('.lettering').children().addClass 'stamp'
  $('.lettering').children().each () -> marginLoaf -= $(@).width()
  n = $('.lettering').children().length
  $('.lettering').children().each () ->
    margin = if $(@).index() < n - 1 then marginLoaf * ((Math.random())/(n-$(@).index() - 1)) else marginLoaf
    marginLoaf -= margin
    left += if $(@).index() > 0 then $(@).prev().width() + margin else 0
    top = ($(window).height()/2 - $(@).height()/2) + ((Math.random() - .5) * $(window).height()/2) # px
    $(@).css {
      position: 'absolute'
      top: "#{top}px"
      left: "#{left}px"
    }
  # get space between right edge of last letter and right edge of window
  spaceOnRight = $(window).width() - ($('.lettering').children().eq(n-1).width() + $('.lettering').children().eq(n-1).offset().left)
  # center whole word
  $('.lettering').css('left', spaceOnRight / 2)
  
initCards = () ->
  $('.pack.filler').each () ->
    random = Math.floor(Math.random() * 4)
    $card = $(@).find('.card')
    switch random
      when 0
        $card.html 'apple'
      when 1
        $card.html 'orange'
      when 2
        $card.html 'grape'
      when 3
        $card.html 'lemon'
  
initPackery = () ->
  $('.container').packery({
    itemSelector: '.pack',
    transitionDuration: '0s'
  });
  $('.container').packery( 'stamp', $('.stamp') );

onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 6 else 12
  resizeCards(cardSize, gutter)
  $('.container').packery();
  
loadAnimation = () ->
  duration = 1000
  easing = [20, 10]
  $('.stamp').each () ->
    $(@).velocity
      properties:
        opacity: [1, 1]
        scale: [1, 0]
      options:
        duration: duration
        easing: easing
        delay: $(@).index() * 120
  $('.pack').each () ->
    $(@).velocity
      properties:
        opacity: [1, 1]
        scale: [1, 0]
      options:
        duration: duration
        easing: easing
        delay: 125 + Math.random() * 500
        
randomColor = () ->
  h = Math.random() * 360
  l = Math.random() * 10 + 70
  "hsl(#{h},100%,#{l}%)"

$ ->
  initLettering()
  initCards()
  initPackery()

  onResize()
  $(window).resize () -> onResize()
  
  loadAnimation()
  
  $('body').css({
    backgroundColor: randomColor()
  })