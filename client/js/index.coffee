width = $(window).width()
spring = [60, 10]
easingSmooth = [20, 10]
coverWidth = 0
scaleRatio = coverWidth / $(window).width()
previousStep = 0

scaleCover = (scrollProgress, $cover) ->
  step              = Math.round(scrollProgress * 8)
  scaleRatio        = coverWidth / $(window).width()
  scale             = ((1-scrollProgress) / (1 / (1 - scaleRatio))) + scaleRatio
  stroke            = 1 / scale
  maxLetterSpacing  = -1 / 32
  letterSpacing     = Math.abs(1-scrollProgress) * (-1/48) + maxLetterSpacing # ems
  maxBorderRadius   = 2 / scaleRatio
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
  
reverseIntroCards = ($section, $collection, $cover) ->
  $cover.velocity('reverse')
#   if $section.hasClass 'intro'
#     $section.children('.card.scale').css 'opacity', 1
  $collection.data('stackHasOpened', false)

animateIntroCards = ($section, $collection, $cover) ->
  maxRotate = 12
  duration = 1000

  $cover.velocity {
    translateZ: 0
    scale: if $cover.hasClass 'scale' then scaleRatio else 1
    rotateZ: -Math.random() * maxRotate + 'deg'
    translateX: (coverWidth / 2) - ($(window).width()/2)
  }, {
    duration
    easing: spring
  }
  $collection.data('stackHasOpened', true)
  
updateSectionScrollValues = ($section, scrollTop) ->
  $section.data 'sectionTopToWindowTop',                $section.offset().top - scrollTop
  $section.data 'sectionTopToDocumentTop',              $(window).height() - $section.data('sectionTopToWindowTop')
  $section.data 'sectionBottomToDocumentTop',           $section.height() + $section.position().top
  $section.data 'sectionTopToWindowTopProgress',        ($(window).height() - $section.data('sectionTopToWindowTop')) / $(window).height()
  $section.data 'sectionBottomToWindowTopProgress',     $section.data('sectionTopToDocumentTop') / $section.data('sectionBottomToDocumentTop')
  $section.data 'sectionBottomToWindowBottomProgress',  (scrollTop + $(window).height()) / $section.data('sectionBottomToDocumentTop')
  
positionCollection = ($collection, status, position, top) ->
  $collection.data 'status', status
  $collection.css {
    position
    top
  }
  
onScrollSection = ($section, scrollTop, scrollProgress) ->
  $collection       = $section.children('.collection')
  $cover            = $collection.find('.cover')
  $translateCover   = if $cover.hasClass 'scale' then $cover.parent('.translate') else $cover

  openCollectionThreshold = if $cover.hasClass('scale') then 1.25 else 1
  
  updateSectionScrollValues $section, scrollTop

  # Scale content section down unless halfway scrolled through first screen
  if $cover.hasClass 'scale'
    scaleCover(Math.max(0, Math.min(1, ($section.data('sectionTopToWindowTopProgress')  - 1) * 4)), $cover)

  if $section.data('sectionTopToWindowTopProgress') >= openCollectionThreshold
    animateIntroCards($section, $collection, $translateCover) unless $collection.data('stackHasOpened')
  else
    reverseIntroCards($section, $collection, $translateCover) if $collection.data('stackHasOpened') 

  # If section top is above window top
  if $section.data('sectionTopToWindowTopProgress') >= 1
    # If section bottom is below window bottom
    if $section.data('sectionBottomToWindowBottomProgress') <= 1
      if $collection.data('status') != 'current'
        positionCollection($collection, 'current', 'fixed', $(window).height()/4)
    # If bottom of section is above window bottom
    else if $collection.data('status') != 'above'
      positionCollection($collection, 'above', 'absolute', $section.height() - ($collection.height() + $(window).height()/4))
  # If section top is below window top
  else
    # If bottom of section is above window bottom
    if ($collection.data('status') != 'below')
      positionCollection($collection, 'below', 'absolute', $(window).height()/4)
  
# Make intro section fixed or scrolling
# If section top is above top of window and section bottom is above bottom of window
#   if sectionTopToWindowTopProgress >= .75 and sectionBottomToWindowBottomProgress <= .5
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
    
initScaleCover = ($scaleCover, $normalCover) ->
#   console.log $normalCover.css('padding')
#   $scaleCover.css {
#     padding: coverPadding / scaleRatio
#     backgroundColor: $normalCover[0].style.backgroundColor
#   }
  
#   $scaleCover.children('h1').css {
#     fontSize: parseFloat($normalCover.find('h1').css('font-size')) / scaleRatio + 'px'
#     lineHeight: parseFloat($normalCover.find('h1').css('line-height')) / scaleRatio + 'px'
#   }

initSections = ($sections) ->
  coverWidth = $sections.children('.collection').find('.cover').not('.scale').width()
  scaleRatio = coverWidth / $(window).width()
  $sections.each () ->
    updateSectionScrollValues $(@), 0
    $(@).data 'stackHasOpened', false
    $(@).children('.collection').each () ->
      $(@).data('status', null)
      if $(@).find('.cover').hasClass('scale')
        initScaleCover($(@).find('.cover'), $sections.children('.collection').find('.cover').not('.scale'))
    
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