randomColor = ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  i = 0
  while i < 6
    color += letters[Math.floor(((Math.random() / 2) + .5) * 16)]
    i++
  color

$ ->
  $cards    = $('.card')
  delay     = 0
  
  $('.colored').css background: randomColor

  $cards.each(() ->
    # Desktop
    if $(window).width() > 640
    
      # Set X
      if $(@).hasClass 'left'
        translateX = ($(window).width() / 2) - ($(@).width() + (Math.random() * 100))
      else
        translateX = ($(window).width() / 2) + (Math.random() * 100)

      # Set Y
      verticallyCentered = ($(window).height() / 2) - ($(@).height() / 2)
      if $(@).hasClass 'top'
        translateY = (verticallyCentered / 2) * (Math.random() + .25)
      else
        translateY = verticallyCentered + 100 + (Math.random() * 100)
      
      # Set rotation
      rotateZ = (Math.random() * 40) + (Math.random() * -40)
    
    # Mobile
    else
      translateX = ($(window).width() / 2) - ($(@).width() / 2)
      translateY = (Math.random() * - 20) * delay # to prevent first card from being pulled past the top of the page
      rotateZ = (Math.random() * 10) + (Math.random() * -10)
    
    # Set starting positions
    $(@).velocity
      properties:
        translateZ: 0
        translateX: ($(window).width() / 2) - ($(@).width() / 2)
        translateY: $(window).height()
        opacity: 1
      options:
        duration: 0

    # Animate in
    $(@).velocity
      properties:
        translateZ: 0
        translateX: translateX
        translateY: translateY
        rotateZ: rotateZ
      options:
        easing: [20, 10]
        duration: 1000
        delay: delay * 125
    
    delay++
  )
  
  $cards.mouseenter(() ->
    $(@).velocity
      properties:
        translateZ: 0
        translateX: '+='+((Math.random() * 10) + (Math.random() * -10))
        translateY: '+='+((Math.random() * 10) + (Math.random() * -10))
        rotateZ: '+='+((Math.random() * 10) + (Math.random() * -10))
      options:
        easing: [20, 10]
        duration: 1500
  )
    
    
  console.log "Hello World"
  $('.signUpLogInForms li.form').on 'click', () ->
    $(@).addClass('open').removeClass('closed')
    $('.signUpLogInForms li.form').not($(@)).removeClass('open').addClass('closed')
