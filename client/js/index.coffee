$ ->
  $cards = $('.card')
  $cards.each(() ->
    $card = $(@)
    rotateZ = (Math.random() * 40) + (Math.random() * -40)

    # Set starting position
    $card.velocity
      properties:
        translateZ: 0
        translateX: ($(window).width() / 2) - ($card.width() / 2)
        translateY: $(window).height()
        opacity: 1
      options:
        duration: 0

    # Animate in
    $card.velocity
      properties:
        translateZ: 0
        translateY: 200
        rotateZ: rotateZ
      options:
        easing: [20, 10]
        duration: 1000
        delay: Math.random() * 1000
  )

  console.log "Hello World"
  $('.signUpLogInForms li.form').on 'click', () ->
    $(@).addClass('open').removeClass('closed')
    $('.signUpLogInForms li.form').not($(@)).removeClass('open').addClass('closed')
