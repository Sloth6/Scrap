width = $(window).width()
spring = [60, 10]
coverWidth = 300
scaleRatio = coverWidth / $(window).width()
previousStep = 0
introStackHasOpened = false

animateIntroCards = (coverTranslate, tagline, form) ->
  introStackHasOpened = true
  maxRotate = 12
  duration = 1000
    
  coverTranslate.velocity {
    translateZ: 0
    rotateZ: -Math.random() * maxRotate + 'deg'
    translateX: -width/6
  }, {
    duration
    easing: spring
  }
  tagline.velocity {
    translateZ: 0
    rotateZ: Math.random() * maxRotate + 'deg'
    translateX: width/6
    translateY: -100
  }, {
    duration
    easing: spring
    delay: 62.5
  } 
  form.velocity {
    translateZ: 0
    rotateZ: Math.random() * maxRotate + 'deg'
    translateX: width/6
    translateY: 100
  }, {
    duration
    easing: spring
    delay: 125
  }
  
reverseIntroCards = (coverTranslate, tagline, form) ->
  introStackHasOpened = false
  coverTranslate.velocity('reverse')
  tagline.velocity('reverse')
  form.velocity('reverse')

scaleContent = (scrollProgress, content) ->
  step              = Math.round(scrollProgress * 8)
  scaleRatio        = coverWidth / $(window).width()
  scale             = ((1-scrollProgress) / (1 / (1 - scaleRatio))) + scaleRatio
  stroke            = 1 / scale
  maxLetterSpacing  = -1 / 32
  letterSpacing     = Math.abs(1-scrollProgress) * (-1/48) + maxLetterSpacing # ems
  maxBorderRadius   = 4 / scaleRatio
  borderRadius      = scrollProgress * maxBorderRadius
  maxBorderWidth    = 1 / scaleRatio
  borderWidth       = scrollProgress * maxBorderWidth

  content.css({
    transform: "scale3d(#{scale}, #{scale}, 1)"
  })

  if step != previousStep
    previousStep = step
    content.css({
      borderRadius: "#{borderRadius}pt"
      borderWidth:  "#{borderWidth}px"
    })
    content.find('h1').css({
      '-webkit-text-stroke': "#{stroke}px black"
      'letter-spacing': "#{letterSpacing}em"
    })

onScroll = (content, coverTranslate, tagline, form) ->
  scrollTop       = $(window).scrollTop()
  scrollProgress  = scrollTop / Math.max(($(document).height() - $(window).height()), 1)
  scrollProgressFirstPage = scrollProgress / (($(window).height()/2) / $(document).height())
  
  # Scale content section down unless halfway scrolled through first screen
  scaleContent(Math.min(1, scrollProgressFirstPage), content)
  
  if scrollProgressFirstPage >= 1
    animateIntroCards(coverTranslate, tagline, form) unless introStackHasOpened
  else
    reverseIntroCards(coverTranslate, tagline, form) if introStackHasOpened
#   if introStackHasOpened and scrollProgressFirstPage <= 1.5
#     reverseIntroCards(coverTranslate, tagline, form)
#     introStackHasOpened = false

  # Make intro section fixed or scrolling
  if (scrollProgressFirstPage <= 3)
    $('.intro').css({
      position: 'fixed'
      top: 0
    })
  else
    $('.intro').css({
      position: 'absolute'
      top: $('.intro').offset().top
    })
  
$ ->
  content = $('header.intro .cover')
  coverTranslate = $('.intro .translate')
  tagline = $('.intro .tagline')
  form = $('.intro .form')
  
  callOnScroll = () ->
    onScroll(content, coverTranslate, tagline, form)

  callOnScroll()
  $(window).scroll(() ->
    callOnScroll()
  )
  $(window).resize(() ->
    callOnScroll()
  )
  
  $('.signUpLogInForms li.form').on 'click', () ->
    $(@).addClass('open').removeClass('closed')
    $('.signUpLogInForms li.form').not($(@)).removeClass('open').addClass('closed')