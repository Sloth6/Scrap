window.randomColor = ->
  h = Math.random() * 360
  l = Math.random() * 10 + 75
  "hsl(#{h},100%,#{l}%)"

window.constants =
  style:
    color: randomColor()
    gutter: 12
    minGutter: 12
    
cardView =
  init: ($cards) ->
    $('.pack.filler').each () ->
      cardView.initFiller $(@).find('.card')
    $cards.css
      backgroundColor: constants.style.color
  
  initFiller: ($card) ->
    $object = $card.find $('object')
    size = Math.ceil((Math.random() + .5)* 8) * 24
    # make monoline
    svgView.monoline $object
#     cardView.colorBorderless($object) # if borderless
    packView.repack()
#     $cardMask = $('<div></div>').addClass('cardMask').css
#       position: 'absolute'
#       zIndex: 3
#       top: 0
#       left: 0
#       bottom: 0
#       right: 0
#     $card.append $cardMask
    $card.addClass 'svg'
    $card.css
      width: size
  
  colorBorderless: ($object) ->
    $object[0].addEventListener 'load', ->
      $fillable = $($object[0].contentDocument).find('path, circle, rect, polyline, polygon, clipPath')
      $fillable.attr('style', "fill: #{constants.style.color}")
    , true    
            
getRotateValues = ($element, scale, event) ->
  offsetY = $element.offset().top - $(window).scrollTop()
  offsetX = $element.offset().left - $(window).scrollLeft()
  progressY = Math.max(0, Math.min(1, (event.clientY - offsetY) / ($element.height() * scale)))
  progressX = Math.max(0, Math.min(1, (event.clientX - offsetX) / ($element.width()  * scale)))
  rotateX = 40 * (progressY - .5)
  rotateY = 40 * (Math.abs(1 - progressX) - .5)
  { x: rotateX, y: rotateY}
  
# initHoverEffect = ->
#   $elements = $('.card')
#   $elements.parent().css
#     'perspective': '400px'
#     '-webkit-perspective': '400px'
#   $elements.each ->
#     $element = $(@)
#     scale = 1.25
#     $element.mouseenter (event) ->
#       rotate = getRotateValues($element, scale, event)
#       $element.parent().css
#         zIndex: 999
#       $(@).velocity
#         properties:
#           translateZ: 0
#           scale: scale
#           rotateX: rotate.x
#           rotateY: rotate.y
#         options:
#           duration: 250
#           easing: [60, 10]
#     $element.mousemove (event) ->
#       rotate = getRotateValues($element, scale, event)
#       $.Velocity.hook $element, 'rotateX', "#{rotate.x}deg"
#       $.Velocity.hook $element, 'rotateY', "#{rotate.y}deg"
#     $element.mouseleave ->
#       $(@).velocity
#         properties:
#           scale: 1
#           rotateX: 0
#           rotateY: 0
#         options:
#           duration: 250
#           easing: [40, 10]
          
packView =
  init: ->
    console.log 'init'
    $('.pack').each () ->
      console.log constants.style.minGutter + ((Math.random()+.5) * constants.style.gutter)
      $(@).css
        marginLeft:   constants.style.minGutter + ((Math.random()+.5) * constants.style.gutter)
        marginTop:    constants.style.minGutter + ((Math.random()+.5) * constants.style.gutter)
        marginBottom: constants.style.minGutter + ((Math.random()+.5) * constants.style.gutter)
        marginRight:  constants.style.minGutter + ((Math.random()+.5) * constants.style.gutter)
    packView.repack()
    
  repack: ->
    $('.content').packery
      itemSelector: '.pack'
      transitionDuration: '0s'
    $('.content').packery 'stamp', $('.stamp')

window.onResize = ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 3 else 6
  packView.repack()
  toggleExtraFillers()
  packView.repack()
  setTimeout ->
    toggleExtraFillers()
    packView.repack()
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
  #       packView.repack()

window.svgView =
  monoline: ($object) ->
    $object[0].addEventListener 'load', ->
      $shapes = $($object[0].contentDocument).find('path, circle, rect, line, polyline, polygon, clipPath')
      $shapes.attr('vector-effect', 'non-scaling-stroke')
    , true
    
  
window.headerView =
  init: ($header) ->
    headerView.initH1 $header
    svgView.monoline $header.find('object')
    
  initH1: ($header) ->
    $h1 = $header.children('h1') #.hide()
    $h1s = $h1.add($h1.clone()).add($h1.clone()).prependTo($header)
    $h1s.css
      '-webkit-text-fill-color': constants.style.color
    duration = 1500
    
    $h1s.each ->
      $(@).hide()
      setTimeout =>
        $(@).show()
        headerView.animateH1 $(@), duration
        setInterval =>
          headerView.animateH1 $(@), duration
        , duration
      , (duration / $h1s.length) * ($(@).index() + 1)

  animateH1: ($h1, duration) ->
    # Reposition Yum to random spot
    $.Velocity.hook $h1, 'rotateZ',    "#{(Math.random() - .5) * 90}deg"
    $.Velocity.hook $h1, 'translateY', "#{Math.random() * ($(window).height() / 4)}px"
    $.Velocity.hook $h1, 'translateX', "#{Math.random() * ($(window).width() - $h1.width())}px"
    # Fade in
    $h1.velocity('stop', true).velocity
      properties:
        opacity: [1, 0]
      options:
        duration: 125
        complete: ->
    # Fade out
    $h1.velocity('stop', true).velocity
      properties:
        opacity: [0, 1]
      options:
        delay: 125
        duration: duration - 125
        
window.onScroll = ->
  top = $(document).scrollTop()
  progress = top / $(window).height()
  opacity = Math.max(0, Math.min(1, 1 - progress))
  $.Velocity.hook $('body'), 'backgroundColorAlpha', opacity
  console.log opacity

$ ->
#   letteringView.init $('.lettering')
  headerView.init $('header.main')
  cardView.init $('.card')
#   initHoverEffect()
  packView.init()
  
  $(window).resize () -> onResize()
  onResize()
  $(window).scroll () -> onScroll()
  onScroll()

  loadAnimation()
  
  $('body').css({
    backgroundColor: constants.style.color
  })
  
  $('.typeOutlineClear, .typeHeaderOutline').css
    '-webkit-text-fill-color': constants.style.color
  
  $('.logIn .card').css
    borderRadius: '400pt / 200pt' # doesn't work in SCSS
    
  $('.card.form').click ->
    if $(@).hasClass 'unfocused'
      openForm $(@)