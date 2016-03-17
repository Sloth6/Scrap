# Post message stop scroll on page; remove frame doesn't work

window.constants =
  style:
    easing: 'cubic-bezier(0.19, 1, 0.22, 1)'
  velocity:
    easing:
      smooth: [30, 10]
      spring: [70, 10]
    duration: 1000

randomRotate = ->
  90 * (Math.random() - .5)

fancyHover = ($elements) ->
  getProgressValues = ($element, pointer, scale) ->
    offsetX = $element.offset().left - $(window).scrollLeft()
    offsetY = $element.offset().top  - $(window).scrollTop()
    progressY = Math.max(0, Math.min(1, (pointer.y - offsetY) / ($element.height() * scale)))
    progressX = Math.max(0, Math.min(1, (pointer.x - offsetX) / ($element.width()  * scale)))
    { x: progressX, y: progressY }
  getRotateValues = ($element, progress) ->
    maxRotateY = 22
    maxRotateX = 22
    rotateX = maxRotateY * (progress.y - .5)
    rotateY = maxRotateX * (Math.abs(1 - progress.x) - .5)
    { x: rotateX, y: rotateY }
  $elements.each ->
    $element = $(@)
    $parent = $element.parent()
    scale = 1.25
    perspective = $element.width() / 4
    duration = 250
    $element.on 'touchstart mouseenter', (event) ->
      pointer = getPointer(event)
      progress = getProgressValues($element, pointer, scale)
      rotate = getRotateValues($element, progress)
      $element.transition
        scale: scale
        easing: constants.style.easing
        duration: duration
      $element.css
        perspective: perspective
      $parent.css
        zIndex: 2
    $element.on 'touchmove mousemove', (event) ->
      pointer = getPointer(event)
      progress = getProgressValues($element, pointer, scale)
      rotate = getRotateValues($element, progress)
      $element.css
        scale: scale
#         z: 250
        rotateX: "#{rotate.x}deg"
        rotateY: "#{rotate.y}deg"
    $element.on 'touchend mouseleave', ->
      $element.css
        zIndex: 0
      $element.parents('.contents').css
        zIndex: 0
      $element.transition
        scale: 1
        rotateX: 0
        rotateY: 0
        easing: constants.style.easing
        duration: duration

launch = ($header, $menuItems) ->
  $flash = $('.flash').hide()
  $openMenuButton = $menuItems.filter('li.openMenuButton')
  $header.css('opacity', 0).hide()
  $menuItems.hide()
  $.Velocity.hook $header, 'rotateZ', "#{randomRotate()}deg"
  $header.velocity
    properties:
      opacity: [1, 0]
    options:
      duration: 250
      easing: constants.velocity.easing.smooth
      begin: -> $header.show()
      complete: ->
        $openMenuButton.velocity('stop', true).velocity
          properties:
            translateY: [0, -$openMenuButton.height()]
          options:
            delay: 500
            duration: 1000
            easing: constants.velocity.easing.smooth
            begin: ->
              $openMenuButton.show()
              $('ul.collectionsMenu').css 'z-index', 10
        $header.velocity
          properties:
            opacity: [0, 1]
          options:
            duration: 4000
            easing: constants.velocity.easing.smooth
  $flash.velocity
    properties:
      opacity: [1, 0]
    options:
      duration: 250
      easing: constants.velocity.easing.smooth
      begin: -> $flash.show()
      complete: ->
        $flash.velocity
          properties:
            opacity: [0, 1]
          options:
            duration: 2000
            easing: constants.velocity.easing.smooth
  # Set body background for smooth transition on close
  $.Velocity.hook $('body'), 'backgroundColor', '#ffffff'
  $.Velocity.hook $('body'), 'backgroundColorAlpha', '0'

slideInLabels = ($header, $menu, $menuItems, $openMenuButton) ->
  $menu.data 'open', true
  # Animate all menu items except openMenuButton, which has custom animation
  $menuItems.not($openMenuButton).each ->
    rotateZ = if $(@).index() > 1 then randomRotate() else 0
    $(@).velocity('stop', true).velocity
      properties:
        translateY: [0, $(window).height() + $(document).scrollTop]
        rotateZ: [0, rotateZ]
      options:
        delay: 31.25 * $(@).index()
        duration: constants.velocity.duration # / 1.5
        easing: constants.velocity.easing.smooth
        begin: -> $(@).show()
  $header.velocity('stop', true).velocity
    properties:
      translateY: -$header.height()
      rotateZ: randomRotate()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: ->
        $header.hide()
        fancyHover $menuItems.not($openMenuButton).find('a')
  # Custom animation for openMenuButton
  $openMenuButton.velocity('stop', true).velocity
    properties:
      translateY: (-$header.height() * 3) - $(window).height()
      height: 0
      rotateZ: randomRotate()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: -> $openMenuButton.hide()

  $('body').velocity('stop', true).velocity
    properties:
      backgroundColor: '#ffffff'
      backgroundColorAlpha: [0.9, 0]
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      begin: -> $('body').css 'background-color', 'transparent'
  $('body').css
    overflow: 'scroll'

removeFrame = ->
  parent.window.postMessage("removetheiframe", "*")

close = ($header, $menu, $menuItems) ->
  $chosen = $menuItems.filter('.chosen')
  $header.velocity('stop', true).velocity
    properties:
      translateY: -$header.height()
      rotateZ: randomRotate()
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
      complete: -> $header.hide()
  $menuItems.not('.chosen').each ->
    translateY = if $(@).index() > $chosen.index() then $(window).height() else -$(window).height()
    $(@).velocity('stop', true).velocity
      properties:
        translateY: translateY
        rotateZ: randomRotate()
      options:
        delay: if $chosen.length > 0 then 0 else 31.25 * (($menuItems.length - 1) - $(@).index())
        duration: constants.velocity.duration/1.25
        easing: constants.velocity.easing.smooth
        complete: ->
          unless $chosen.length > 0 # if no label chosen
            $(@).hide()
            removeFrame() if $(@).index() is $menuItems.length - 1 # if last collection
  $('body').velocity('stop', true).velocity
    properties:
      backgroundColor: '#ffffff'
      backgroundColorAlpha: 0
    options:
      duration: constants.velocity.duration
      easing: constants.velocity.easing.smooth
  if $chosen.length # If user selected a label
    $chosen.find('.contents').velocity('stop', true).velocity
      properties:
        translateY: - $chosen.offset().top
      options:
        delay: 0
        duration: constants.velocity.duration / 1.5
        easing: constants.velocity.easing.smooth
        complete: ->
          $chosen.find('.contents').velocity('stop', true).velocity
            properties:
              translateY: -$chosen.offset().top - ($chosen.height() * 4)
              rotateZ: randomRotate()
            options:
              delay: 2000
              duration: constants.velocity.duration
              easing: constants.velocity.easing.smooth
              complete: ->
                $menuItems.hide()
                removeFrame()
    $chosen.find('a').transition
      scale: 1
      rotateX: 0
      rotateY: 0
      easing: constants.style.easing
      duration: constants.velocity.duration

addCollection = ($collection) ->
  $collection.addClass('chosen')
  collectionKey = $collection.data 'collectionkey'
  $.post("/addArticleCollection", { articleId, collectionKey }).
    fail(() -> console.log 'Failed to addCollection')

$ ->
  $header = $('h1')
  $menu = $('ul.collectionsMenu')
  $menuItems = $menu.find('li')
  $collections = $menu.find('li.collection')
  $openMenuButton = $menu.find('li.openMenuButton')
  delayToAutoHide = 4000

  launch $header, $menuItems

  fancyHover $openMenuButton.find('a')

  $menu.find('li input').click ->
    event.stopPropagation()
    event.preventDefault()

#   rotateColor = ($element, hue)->
#     $element.css '-webkit-text-fill-color', "hsl(#{hue},100%,75%)"
#
#   $header.add($menuItems.first().find('a')).each ->
#     hue = Math.floor(Math.random() * 360)
#     $a = $(@)
#     rotateColor $a, hue
#     setInterval ->
#       hue += 30
#     , 1000

  $openMenuButton.on 'click', (event) ->
    event.stopPropagation()
    event.preventDefault()
    slideInLabels $header, $menu, $menuItems, $openMenuButton

  $collections.each ->
    $collection = $(@)
    $collection.find('a').on 'touchend mouseup', (event) ->
      event.stopPropagation()
      addCollection $collection
      close($header, $menu, $menuItems)
  $('body').click -> close($header, $menu, $menuItems)
  setTimeout ->
    close($header, $menu, $menuItems) unless $menu.data('open')
  , delayToAutoHide

