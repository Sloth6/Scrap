repack = () ->
  $('.content').packery 'stamp', $('.stamp')
  $('.content').packery({
    itemSelector: '.pack'
  #     transitionDuration: '0s'
  });
    
resizeCards = (minSize, gutter) ->
  $('.pack.filler').each () ->
    height  = minSize + (Math.round(Math.random() * (minSize*6)))
    width   = minSize + (Math.round(Math.random() * (minSize*6)))
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
  $('.lettering').children().addClass 'stamp letter'
  $('.lettering').children().each () ->
    letter = $(@).html()
    $(@).html('')
    $inner = $('<span></span>').addClass('inner').html(letter).appendTo($(@))
    top = ($(window).height()/2 - $(@).height()/2) + ((Math.random() - .5) * $(window).height()/2) # px
    $(@).css
      position: 'absolute'
      top: "#{top}px"
  spaceOutLetters()
  
initGlyphCards = ($card) ->
  if Math.random() < .75
    borderless = false
    glyphCount = 89
    path = '/images/glyphs/border/glyph'
  else
    borderless = true
    glyphCount = 9
    path = '/images/glyphs/borderless/glyph'
    $card.addClass 'borderless'
  glyph = (Math.ceil(Math.random() * glyphCount)).toString()
  size = Math.ceil((Math.random() + .5)* 8) * 12
  if (glyph.length < 2)
    glyph = '0' + glyph
  $object = $("<object type='image/svg+xml' data='#{path}-#{glyph}.svg' id='glyph-#{glyph}-#{$(@).index()}'></object>").addClass('svg')
  $card.append $object
  setTimeout -> # wait until after svgs load
    # make monoline
    $shapes = $($object[0].contentDocument).find('path, circle, rect, line, polyline, polygon, clipPath')
    $shapes.attr('vector-effect', 'non-scaling-stroke')
    if borderless
      $fillable = $($object[0].contentDocument).find('path, circle, rect, polyline, polygon, clipPath')
      $fillable.attr('style', "fill: #{window.color}")
    repack()
  , 1000
  $cardMask = $('<div></div>').addClass('cardMask').css
    position: 'absolute'
    zIndex: 3
    top: 0
    left: 0
    bottom: 0
    right: 0
  $card.append $cardMask
  $card.addClass 'svg'
  $card.css
    width: size
  
initCards = ->
  $('.pack.filler').each () -> initGlyphCards $(@).find('.card')
  $('.card').css
    backgroundColor: window.color
          
getRotateValues = ($element, scale, event) ->
  offsetY = $element.offset().top - $(window).scrollTop()
  offsetX = $element.offset().left - $(window).scrollLeft()
  progressY = Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
  progressX = Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))
  rotateX = 40 * (progressY - .5)
  rotateY = 40 * (Math.abs(1 - progressX) - .5)
  { x: rotateX, y: rotateY}
  
initHoverEffect = ->
  $elements = $('.card')
  $elements.parent().css
    'perspective': '400px'
    '-webkit-perspective': '400px'
  $elements.each ->
    $element = $(@)
    scale = 1.25
    $element.mouseenter (event) ->
      rotate = getRotateValues($element, scale, event)
      $element.parent().css
        zIndex: 999
      $(@).velocity
        properties:
          translateZ: 0
          scale: scale
          rotateX: rotate.x
          rotateY: rotate.y
        options:
          duration: 250
          easing: [60, 10]
    $element.mousemove (event) ->
      rotate = getRotateValues($element, scale, event)
      $.Velocity.hook $element, 'rotateX', "#{rotate.x}deg"
      $.Velocity.hook $element, 'rotateY', "#{rotate.y}deg"
    $element.mouseleave ->
      $(@).velocity
        properties:
          scale: 1
          rotateX: 0
          rotateY: 0
        options:
          duration: 250
          easing: [40, 10]
          
initPackery = ->
  repack()
  
onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 3 else 6
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
  l = Math.random() * 10 + 75
  "hsl(#{h},100%,#{l}%)"
  
toggleExtraFillers = () ->
#   $('.pack.filler').find('.card').each () ->
#     if $(@).offset().top > $(window).height()
#       $(@).css('background-color', 'blue')
#       $(@).hide()
#     else
#       $(@).css('background-color', 'red')
#       $(@).show()

openForm = ($card) ->
  $packable = $card.parent($('.pack'))
  $h1 = $card.find('h1')
  $form = $card.find('ul.form')
  duration = 500
  easing = [30, 10]
  $card.removeClass 'unfocused'
  $h1.velocity
    properties:
      translateY: -$h1.height()
      opacity: 0
    options:
      duration: duration
      easing: easing
      complete: -> $h1.hide()
  $form.velocity
    properties:
      translateY: [0, $form.height()]
      opacity: 1
    options:
      duration: duration
      easing: easing
      begin: ->
        $form.show()
        $form.css
          opacity: 0
          top: 0      
  $('.stamp').removeClass 'stamp'
  $packable.addClass('stamp').css
    height: $form.height() + 48
    width: '200px'
  $card.velocity
    properties:
      borderRadius: 0
      height: '100%'
      width: '100%'
    options:
      duration: duration
      easing: easing
  #       repack()

$ ->
  window.color = randomColor()
  initLettering()
  initCards()
  initHoverEffect()
  initPackery()
  
  $(window).resize () -> onResize()
  onResize()
  setTimeout ->
    loadAnimation()
  , 1000
  
#   $('body').css({
#     backgroundColor: window.color
#   })
  
  $('.typeOutlineClear, .typeHeaderOutline').css
    '-webkit-text-fill-color': window.color
  
  $('.logIn .card').css
    borderRadius: '400pt / 200pt' # doesn't work in SCSS
    
  $('.card.form').click ->
    if $(@).hasClass 'unfocused'
      openForm $(@)