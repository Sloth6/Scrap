coverWidth = 300
scaleRatio = coverWidth / $(window).width()
previousStep = 0
introStackHasOpened = false

animateIntroCards = () ->
  introStackHasOpened = true
  cards = $('.intro .slideOver')
  $('.intro').css({
    position: 'absolute'
    top: $('.intro').offset().top
  })
  console.log(cards)

scaleContent = (scrollProgress, content) ->
  step              = Math.round(scrollProgress * 10)
  scaleRatio        = coverWidth / $(window).width()
  scale             = ((1-scrollProgress) / 1.333) + scaleRatio
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

onScroll = (content) ->
  scrollTop       = $(window).scrollTop()
  scrollProgress  = scrollTop / Math.max(($(document).height() - $(window).height()), 1)
  scrollProgressFirstPage = scrollProgress / (($(window).height()/2) / $(document).height())
  scaleContent(Math.min(1, scrollProgressFirstPage), content)
  if (scrollProgressFirstPage <= 1)
    introStackHasOpened = false
    $('.intro').css({
      position: 'fixed'
      top: 0
    })
  else
    unless introStackHasOpened
      animateIntroCards()
  
$ ->
  content = $('header.intro .cover')
  onScroll(content)
  $(window).scroll(() ->
    onScroll(content)
  )
  $(window).resize(() ->
    onScroll(content)
  )

  $('.signUpLogInForms li.form').on 'click', () ->
    $(@).addClass('open').removeClass('closed')
    $('.signUpLogInForms li.form').not($(@)).removeClass('open').addClass('closed')