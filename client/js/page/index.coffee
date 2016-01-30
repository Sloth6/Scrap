repack = () ->
  $('.content').packery()
  
resizeCards = (minSize, gutter) ->
  $('.pack.filler').each () ->
    height  = minSize + (Math.round(Math.random() * (minSize*6)))
    width   = minSize + (Math.round(Math.random() * (minSize*6)))
#     $(@).find('.card').css({
#       'width':  "#{width}px"
#       'height': "#{height}px"
#     })
  $('.pack').each () ->
    $(@).css({
      'padding-left':  if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-top':   if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-bottom':  if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
      'padding-right':   if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
    })
    
spaceOutLetters = () ->
  width = 0
  left = 0
  marginLoaf = $(window).width()
  n = $('.lettering').children().length
  $('.lettering').children().each () -> marginLoaf -= $(@).width()
  $('.lettering').children().each () ->
    margin = if $(@).index() < n - 1 then marginLoaf * ((Math.random())/(n-$(@).index() - 1)) else marginLoaf
    marginLoaf -= margin
    left += if $(@).index() > 0 then $(@).prev().width() + margin else 0
    $(@).css {
      left: "#{left}px"
    }
  # get space between right edge of last letter and right edge of window
  spaceOnRight = $(window).width() - ($('.lettering').children().eq(n-1).width() + $('.lettering').children().eq(n-1).offset().left)
  # center whole word
  #   $('.lettering').css('left', spaceOnRight / 2)
#   repack()
  
initLettering = () ->
  $('.lettering').lettering();
  $('.lettering').children().addClass 'stamp'
  $('.lettering').children().each () ->
    top = ($(window).height()/2 - $(@).height()/2) + ((Math.random() - .5) * $(window).height()/2) # px
    $(@).css {
      position: 'absolute'
      top: "#{top}px"
    }
  spaceOutLetters()
  
initGlyphCards = ($card) ->
  if Math.random() < .75
    glyphCount = 89
    path = '/images/glyphs/border/glyph'
    classes = 'svg'
  else
    glyphCount = 9
    path = '/images/glyphs/borderless/glyph'
    classes = 'svg borderless'
  glyph = (Math.ceil(Math.random() * glyphCount)).toString()
  size = Math.ceil((Math.random() + .5)* 4) * 36
  if (glyph.length < 2)
    glyph = '0' + glyph
  $object = $("<object type='image/svg+xml' data='#{path}-#{glyph}.svg' id='glyph-#{glyph}-#{$(@).index()}'></object>").addClass('svg')
  $card.append $object
  setTimeout -> # wait until after svgs load
    $shapes = $($object[0].contentDocument).find('path, circle, rect, line, polyline, polygon, clipPath')
    $shapes.attr('vector-effect', 'non-scaling-stroke')
    repack()
  , 1000
  $card.addClass classes
  $card.css({
    'width':  size
  #           'height': size
  })
  
initCards = () ->
  $('.pack.filler').each () ->
    random = Math.floor(Math.random() * 4)
    $card = $(@).find('.card')
    switch random
      # card symbol
      when 0
        initGlyphCards($card)
      when 1
        initGlyphCards($card)
      when 2
        initGlyphCards($card)
      when 3
        random = Math.floor(Math.random() * 4)
        switch random
          when 0
            random = Math.floor(Math.random() * 4)
            $card.addClass 'typeOutlineClear symbol'
            $card.css({
              fontSize: Math.ceil(Math.random() * 4) * 24
            })
            switch random
              when 0 then $card.html '$'
              when 1 then $card.html '&'
              when 2 then $card.html '?'
              when 3 then $card.html '!'
          when 1
            $card.addClass 'typeOutlineClear symbol'
            $card.css({
              fontSize: Math.ceil(Math.random() * 4) * 24
              fontWeight: Math.ceil(Math.random() * 8) * 100
            })
            random = Math.floor(Math.random() * 4)
            switch random
              when 0 then text = 'Wow!'
              when 1 then text = 'Meh.'
              when 2 then text = 'Cool'
              when 3 then text = 'Amazing'
            $h1 = $('<h1></h1>').html(text)
            $card.append $h1
          when 2
            $card.html '2'
          when 3
            $card.html '3'
  
initLabelery = () ->
  $('.content').packery({
    itemSelector: '.pack',
    transitionDuration: '0s'
  });
  $('.content').packery( 'stamp', $('.stamp') );

onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 6 else 12
  repack()
  resizeCards(cardSize, gutter)
  repack()
  spaceOutLetters()
  repack()
  toggleExtraFillers()
  repack()
  setTimeout ->
    toggleExtraFillers()
    repack()
  , 100
    
loadAnimation = () ->
  duration = 2000
  easing = [20, 10]
  $('.stamp').each () ->
    $(@).velocity
      properties:
        opacity: [1, 1]
        scale: [1, 0]
        rotateZ: [0, (Math.random() - .5) * 45]
#         translateY: [0, 1000]
      options:
        duration: duration
        easing: easing
        delay: 250 + $(@).index() * 120
  $('.pack').each () ->
    $(@).velocity
      properties:
        opacity: [1, 1]
        scale: [1, 0]
        rotateZ: [0, (Math.random() - .5) * 45]
#         translateY: [0, 1000]
      options:
        duration: duration
        easing: easing
        delay: 750 + Math.random() * 500
        
randomColor = () ->
  h = Math.random() * 360
  l = Math.random() * 10 + 70
  "hsl(#{h},100%,#{l}%)"
  
toggleExtraFillers = () ->
#   $('.pack.filler').find('.card').each () ->
#     if $(@).offset().top > $(window).height()
#       $(@).css('background-color', 'blue')
#       $(@).hide()
#     else
#       $(@).css('background-color', 'red')
#       $(@).show()
      

$ ->
  initLettering()
  initCards()
  initLabelery()
  
  $(window).resize () -> onResize()
  onResize()
  setTimeout ->
    loadAnimation()
  , 1000
  
  $('body').css({
    backgroundColor: randomColor()
  })