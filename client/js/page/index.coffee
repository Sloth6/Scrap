   
cardView =
  init: ($cards) ->
    $('.pack.filler').each () ->
      cardView.initFiller $(@).find('.card')
  
  initFiller: ($card) ->
    $object = $card.find $('object')
    size = Math.ceil((Math.random() + .5)* 8) * 24
    # make monoline
    svgView.monoline $object
#     cardView.colorBorderless($object) # if borderless
    containerView.repack()
    $card.addClass 'svg'
    $card.css
      width: size
  
  colorBorderless: ($object) ->
    $object[0].addEventListener 'load', ->
      $fillable = $($object[0].contentDocument).find('path, circle, rect, polyline, polygon, clipPath')
      $fillable.attr('style', "fill: #{globals.color}")
    , true    
          
containerView =
  init: ($content) ->
    $content.data('hasAnimated', false)
    $('.pack').each () ->
      $(@).css
        marginLeft:   globals.minGutter + ((Math.random()+.5) * globals.gutter)
        marginTop:    globals.minGutter + ((Math.random()+.5) * globals.gutter)
        marginBottom: globals.minGutter + ((Math.random()+.5) * globals.gutter)
        marginRight:  globals.minGutter + ((Math.random()+.5) * globals.gutter)
    containerView.repack()
    
  animateIn: ($content) ->
    duration = 2000
    easing = [20, 10]
    $content.data('hasAnimated', true)
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
    
  repack: ->
    $('.content').packery
      itemSelector: '.pack'
      transitionDuration: '0s'
    $('.content').packery 'stamp', $('.stamp')

window.onResize = ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 3 else 6
  containerView.repack()
  setTimeout ->
    containerView.repack()
  , 100

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
  #       containerView.repack()

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
  $('.bg').css 'opacity', opacity
  # Animate in packery elements
  if (top > 0) and not $('.content').data('hasAnimated')
    containerView.animateIn $('.content')
    
  
window.colorView =
  init: ($elements, property) ->
    # Set initial color
    colorView.set $elements, property
    # Set transition duration after initial color is set
    setTimeout ->
      transition = "#{property} #{globals.colorShiftDuration / 1000}s linear"
      $elements.css
        webkitTransition: transition
        mozTransition:    transition
        msTransition:     transition
        transition:       transition
    , globals.colorShiftDuration
    # Start incrementing color
    setInterval ->
      colorView.set $elements, property
    , globals.colorShiftDuration
    
  set: ($elements, property) ->
    $elements.css property, globals.color
    
  startIncrementing: ->
    setInterval ->
      globals.color = colorView.newColor()
    , globals.colorShiftDuration
    
  newColor: ->
    h = Math.random() * 360
    l = Math.random() * 10 + 75
    "hsl(#{h},100%,#{l}%)"    
    
window.globals =
  gutter: 12
  minGutter: 12
  color: colorView.newColor()
  colorShiftDuration: 4000
    
$ ->
  headerView.init $('header.main')
  cardView.init $('.card')
  containerView.init $('.content')
  
  $(window).resize () -> onResize()
  onResize()
  $(window).scroll () -> onScroll()
  onScroll()
  
  colorView.startIncrementing()
  
  # All color inits must be called at same time  
  colorView.init $('.bg'), 'background-color'
  colorView.init $('.typeOutlineClear, .typeHeaderOutline'), '-webkit-text-fill-color'
  colorView.init $('header.main h1'), '-webkit-text-fill-color'
  colorView.init $('.card'), 'background-color'
  
  $('.logIn .card').css
    borderRadius: '400pt / 200pt' # doesn't work in SCSS
    
  $('.card.form').click ->
    if $(@).hasClass 'unfocused'
      openForm $(@)