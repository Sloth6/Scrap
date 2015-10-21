width = $(window).width()
spring = [60, 10]
coverWidth = 300
scaleRatio = coverWidth / $(window).width()
previousStep = 0

scaleContent = (scrollProgress, $cover) ->
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

  $cover.css({
    transform: "scale3d(#{scale}, #{scale}, 1)"
  })

  if step != previousStep
    previousStep = step
    $cover.css({
      borderRadius: "#{borderRadius}pt"
      borderWidth:  "#{borderWidth}px"
    })
    $cover.find('h1').css({
      '-webkit-text-stroke': "#{stroke}px black"
      'letter-spacing': "#{letterSpacing}em"
    })
  
reverseIntroCards = ($collection, $coverTranslate) ->
  $collection.data('stackHasOpened', false)
  $coverTranslate.velocity('reverse')

animateIntroCards = ($collection, $coverTranslate) ->
  $collection.data('stackHasOpened', true)
  maxRotate = 12
  duration = 1000
    
  $coverTranslate.velocity {
    translateZ: 0
#     rotateZ: -Math.random() * maxRotate + 'deg'
    translateX: width/6
  }, {
    duration
    easing: spring
  }
    
onScrollSection = ($section, scrollTop, scrollProgress) ->
  $collection       = $section.children('.collection')
  $cover            = $collection.find('.cover')
  $coverTranslate   = $cover.parent()
  sectionTopToWindowTop       = $section.offset().top - scrollTop
  sectionTopToDocumentTop     = $(window).height() - sectionTopToWindowTop
  sectionBottomToDocumentTop  = $section.height() + $(window).height()
  sectionBottomToWindowTopProgress  = sectionTopToDocumentTop / sectionBottomToDocumentTop
  sectionTopToWindowTopProgress  = ($(window).height() - sectionTopToWindowTop) / $(window).height()
  sectionBottomToWindowTopProgress     = (scrollTop + $(window).height()/2) /  sectionBottomToDocumentTop
  
  $section.data 'progressThroughSelf', sectionBottomToWindowTopProgress
  $section.data 'progressToWindowTop', sectionTopToWindowTopProgress

#   if $section.hasClass 'two'
#     console.log (scrollTop + $(window).height()/2) /  sectionBottomToDocumentTop

  # Scale content section down unless halfway scrolled through first screen
#   scaleContent(Math.min(1, sectionProgress), $cover)
  
  # If section top is above window top
  if sectionTopToWindowTopProgress >= 1
    animateIntroCards($collection, $coverTranslate) unless $collection.data('stackHasOpened')
    # If section bottom is below window bottom
    if sectionBottomToWindowTopProgress <= 1
      $collection.css({
        border: ''
        position: 'fixed'
        top:      0
      })
    # If bottom of section is above window bottom
    else
      $collection.css({
        border: 'red 2pt solid'
        position: 'absolute'
        top:      500
      })
  # If section top is below window top
  else
    reverseIntroCards($collection, $coverTranslate) if      $collection.data('stackHasOpened') 
    # If bottom of section is above window bottom
#     if sectionBottomToWindowTopProgress >= 1
    $collection.css({
      border: 'lime 2pt solid'
      position: 'absolute'
      top:      0
    })
      
  
  # Make intro section fixed or scrolling
  # If section top is above top of window and section bottom is above bottom of window
#   if sectionTopToWindowTopProgress >= .75 and sectionBottomToWindowTopProgress <= .5
#     $collection.css({
#       position: 'fixed'
#       top:      '25vh'
#     })
#   else 
#     $collection.css({
#       position: 'absolute'
#       top:      $section.offset().top
#     })

onScroll = ($sections) ->
  scrollTop       = $(window).scrollTop()
  scrollProgress  = scrollTop / Math.max(($(document).height() - $(window).height()), 1)
  
  $sections.each () ->
    onScrollSection($(@), scrollTop, scrollProgress)
  
initSections = ($sections) ->
  $sections.each(() ->
    $(@).data 'stackHasOpened', false
  )
  
$ ->
  $sections = $('.page > .example')

  initSections($sections)
  onScroll($sections)

  $(window).scroll(() ->
    onScroll($sections)
  )
  $(window).resize(() ->
    onScroll($sections)
  )