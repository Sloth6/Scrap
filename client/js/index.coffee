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
  $covers   = $('.card.cover')
  delay     = 0
  
  $covers.css background: randomColor

  $cards.each(() ->
    delay++
    if $(@).hasClass 'left'
      translateX = Math.random() * 100
    else
      translateX = ($(window).width() / 2) - (Math.random() * 100)
    rotateZ = (Math.random() * 40) + (Math.random() * -40)
    # Set starting position
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
        translateY: ($(window).height() / 2) - ($(@).height() / 2)
        rotateZ: rotateZ
      options:
        easing: [20, 10]
        duration: 1000
        delay: delay * 125
  )

  console.log "Hello World"
  $('.signUpLogInForms li.form').on 'click', () ->
    $(@).addClass('open').removeClass('closed')
    $('.signUpLogInForms li.form').not($(@)).removeClass('open').addClass('closed')
