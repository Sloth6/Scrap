initForm = () ->
  $toggleButton = $('a.formToggle')
  $forms        = $('section.form ul.form')
  $logInForm    = $('section.form ul.form.logIn')
  $signUpForm   = $('section.form ul.form.signUp')
  $currentForm  = $logInForm
  toggleForm = () ->
    $forms.not($currentForm).hide()
    $currentForm.show()
    if $currentForm is $logInForm
      $toggleButton.html('Create account')
      $currentForm = $signUpForm
    else
      $toggleButton.html('Sign in')
      $currentForm = $logInForm
  toggleForm()
  $toggleButton.on 'click', () ->
    event.preventDefault()
    toggleForm()

$ ->
  initForm();
  setTimeout( () ->
    $('section.form').velocity
      properties:
        opacity: 1
      options:
        easing: [20, 10]
        duration: 1000
    $('.collection').find('.card.left').each(() ->
      $(@).velocity
        properties:
          opacity: 1
          translateZ: 0
          rotateZ: (Math.random() * 10) + (Math.random() * -10)
        options:
          easing: [20, 10]
          duration: 1000
    )
    
    if $(window).width() > 640
      # Animate in
      $('.collection').velocity
        properties:
          translateZ: 0
          translateX: $(window).width() / 16
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.intro').velocity
        properties:
          translateZ: 0
          opacity: 1
          rotateZ: (Math.random() * 20) + (Math.random() * -20)
          translateX: $(window).width()/2
          translateY: $(window).height()/2 - $(@).height()/3
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.logo').velocity
        properties:
          translateZ: 0
          opacity: 1
          translateX: ($(window).width() * .75) * Math.random()
          translateY: -$(window).width()/6
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.logo h1').velocity
        properties:
          translateZ: 0
          rotateZ: (Math.random() * 45) + (Math.random() * -45)
        options:
          easing: [20, 10]
          duration: 1000
    else
      $('.collection').velocity
        properties:
          translateZ: 0
          translateY: $('.card.intro').height() * 2
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.intro').velocity
        properties:
          translateZ: 0
          opacity: 1
          rotateZ: (Math.random() * 20) + (Math.random() * -20)
          translateY: -$(@).height()/6
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.logo').velocity
        properties:
          translateZ: 0
          opacity: 1
          translateX: ($(window).width() * .25) * Math.random()
          translateY: -$('.card.intro').height() * 2.5
        options:
          easing: [20, 10]
          duration: 1000
      $('.card.logo h1').velocity
        properties:
          translateZ: 0
          rotateZ: (Math.random() * 20) + (Math.random() * -20)
        options:
          easing: [20, 10]
          duration: 1000
  , 1000)

# $ ->
#   if $(window).width() > 640
#     # Animate in
#     $('.collection').find('.card.left').each(() ->
#       $(@).velocity
#         properties:
#           opacity: 1
#           translateZ: 0
#           rotateZ: (Math.random() * 10) + (Math.random() * -10)
#         options:
#           easing: [20, 10]
#           duration: 1000
#     )
#     $('.collection').find('.card.right').velocity
#       properties:
#         translateZ: 0
#         opacity: 1
#         rotateZ: (Math.random() * 10) + (Math.random() * -10)
#         translateX: $(window).width()/2
#         translateY: $(window).height()/2 - $(@).height()/3
#       options:
#         easing: [20, 10]
#         duration: 1000