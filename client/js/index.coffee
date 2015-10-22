width = $(window).width()
basicSpring = [60, 10]
fancySpring = [100, 10]
easingSmooth = [20, 10]
coverWidth = 0
coverHeight = 0
scaleRatio = coverWidth / $(window).width()
previousStep = 0
collectionOpenDuration = 1000
rotateZRandomMax = 22.5

updateScaleRatio = () ->
  scaleRatio = coverWidth / $(window).width()

scaleCover = (scrollProgress, $cover) ->
  $h1                 = $cover.find('h1')
  step                = Math.round(scrollProgress * 8)
  scaleRatio          = coverWidth / $(window).width()
  scale               = ((1-scrollProgress) / (1 / (1 - scaleRatio))) + scaleRatio
  stroke              = 1 / scale
  finalLetterSpacing  = -1 / 32
  letterSpacing       = Math.abs(1-scrollProgress) * (-1/48) + finalLetterSpacing # ems
  finalBorderRadius   = 2 / scaleRatio
  borderRadius        = scrollProgress * finalBorderRadius
  finalBorderWidth    = 1 / scaleRatio
  borderWidth         = scrollProgress * finalBorderWidth

  $cover.css
    transform: "scale3d(#{scale}, #{scale}, 1)"

  if step isnt previousStep or scrollProgress is 0
    $cover.css
      borderRadius: "#{borderRadius}pt"
      borderWidth:  "#{borderWidth}px"
    $h1.css
      '-webkit-text-stroke': "#{stroke}px black"
      'letter-spacing': "#{letterSpacing}em"
      
animateOutPop = ($element) ->
  if $element.data('hasAnimated')
    $element.velocity 'reverse'
    $element.data 'hasAnimated', false
        
animateInPop = ($element) ->
  if not $element.data('hasAnimated')
    $element.velocity {
      translateZ: 0
      translateY: 0
      scale: 1
      rotateZ: '0deg'
      opacity: 1
    }, {
      duration: collectionOpenDuration
      easing: fancySpring
      delay: collectionOpenDuration / 8
    }
  $element.data 'hasAnimated', true
  
reverseAnimateCollection = ($section, $collection, $cover, $cards) ->
  $cover.velocity 'reverse'
  $cards.parent('.exampleContent').velocity 'reverse'
  $cards.each () ->
    $(@).velocity 'reverse'
  $collection.data('stackHasOpened', false)

animateCollection = ($section, $collection, $cover, $cards) ->
  duration                = collectionOpenDuration
  maxRotate               = 0
  cardSpacing             = 24
  translateXToWindowLeft  = (cardSpacing/2) + ((coverWidth / 2) - ($(window).width()/2))

  $cover.velocity {
    translateZ:   0
    scale:        if $cover.hasClass 'scale' then scaleRatio else 1
    rotateZ:      -Math.random() * maxRotate + 'deg'
    translateX:   translateXToWindowLeft
  }, {
    duration
    easing: basicSpring
  }
  
  $cards.parent('.exampleContent').velocity {
    opacity: 1
  }, {
    duration
    easing: easingSmooth
  }
  
  $cards.each () ->
    translateXStart   = (-$(window).width() / 2) + coverWidth + cardSpacing * 1.5
    translateX        = translateXStart + ($(@).index() * ($(@).width() + cardSpacing))
    $(@).velocity({
      translateZ: 0
      translateY: 0
      rotateZ: Math.random() * maxRotate - (Math.random() * maxRotate) + 'deg'
      translateX
      scale: 1
    }, {
      duration
      easing: basicSpring
      delay: Math.random() * (duration / 6)
    })
    $(@).css 'opacity', 1
  $collection.data('stackHasOpened', true)
  
updateSectionScrollValues = ($section, scrollTop) ->
  $section.data 'sectionTopToWindowTop',                $section.offset().top - scrollTop
  $section.data 'sectionTopToDocumentTop',              $(window).height() - $section.data('sectionTopToWindowTop')
  $section.data 'sectionBottomToDocumentTop',           $section.height() + $section.position().top
  $section.data 'sectionTopToWindowTopProgress',        ($(window).height() - $section.data('sectionTopToWindowTop')) / $(window).height()
  $section.data 'sectionBottomToWindowTopProgress',     $section.data('sectionTopToDocumentTop') / $section.data('sectionBottomToDocumentTop')
  $section.data 'sectionBottomToWindowBottomProgress',  (scrollTop + $(window).height()) / $section.data('sectionBottomToDocumentTop')
  
positionElement = ($element, status, position, top) ->
  $element.data 'status', status
  $element.css {
    position
    top
  }
  
onScrollSection = ($section, scrollTop, scrollProgress) ->
  $collection       = $section.children('.collection')
  collectionTopPercentage     = .1 # Percentage of window height
  collectionTop     = $(window).height() * collectionTopPercentage
  $cover            = $collection.find('.cover')
  $translateCover   = if $cover.hasClass 'scale' then $cover.parent('.translate') else $cover
  $exampleCards     = $collection.children('.exampleContent').children('.card')
  $caption          = $section.find('.caption')
  windowTopToCollectionBottom = collectionTop + coverHeight
  sectionTopToCollectionBottom = $section.height() + coverHeight

  openCollectionThreshold = if $cover.hasClass('scale') then 2 else 1
  
  updateSectionScrollValues $section, scrollTop

  # Scale content section down unless halfway scrolled through first screen
  if $cover.hasClass 'scale'
    scaleCover(Math.max(0, Math.min(1, ($section.data('sectionTopToWindowTopProgress')  - 1) * 4)), $cover)

  if $section.data('sectionTopToWindowTopProgress') >= openCollectionThreshold
    animateCollection($section, $collection, $translateCover, $exampleCards) unless $collection.data('stackHasOpened')
    animateInPop(($caption).children('p'))
  else
    reverseAnimateCollection($section, $collection, $translateCover, $exampleCards) if $collection.data('stackHasOpened')
    animateOutPop(($caption).children('p'))

  if $section.data('sectionTopToWindowTopProgress') >= 1
    if $section.data('sectionBottomToWindowBottomProgress') <= 1
      if $collection.data('status') != 'current'
        positionElement($collection, 'current', 'fixed', 0)
        positionElement($caption, 'current', 'fixed', windowTopToCollectionBottom + (($(window).height() - windowTopToCollectionBottom) / 2) - ($caption.height() / 2))
    else if $collection.data('status') != 'above'
      positionElement($collection, 'above', 'absolute', $section.height() - $collection.height())
      positionElement($caption, 'above', 'absolute', ($section.height() - $(window).height()) + windowTopToCollectionBottom + (($(window).height() - windowTopToCollectionBottom) / 2) - ($caption.height() / 2))
  else
    if ($collection.data('status') != 'below')
      positionElement($collection, 'below', 'absolute', 0)
      positionElement($caption, 'below', 'absolute', windowTopToCollectionBottom + (($(window).height() - windowTopToCollectionBottom) / 2) - ($caption.height() / 2))
      console.log $caption.offset().top
      
onScroll = ($sections) ->
  scrollTop       = $(window).scrollTop() 
  scrollProgress  = scrollTop / Math.max(($(document).height() - $(window).height()), 1)
  updateScaleRatio()
  $sections.each () ->
    onScrollSection($(@), scrollTop, scrollProgress)
    
initScaleCover = ($scaleCover, $normalCover) ->
  $normalH1 = $normalCover.find('h1')
  $scaleCover.css {
    padding:  parseFloat($normalCover.css('padding')) / scaleRatio + 'px'
    height:   parseFloat($normalCover.css('height')) / scaleRatio + 'px'
    width:    parseFloat($normalCover.css('width')) / scaleRatio + 'px'
#     backgroundColor: $normalCover[0].style.backgroundColor
  }
  
  $scaleCover.children('h1').css {
    letterSpacing: parseFloat($normalH1.css('letter-spacing')) / scaleRatio + 'px'
    lineHeight:    parseFloat($normalH1.css('line-height')) / scaleRatio + 'px'
    fontSize:      parseFloat($normalH1.css('font-size')) / scaleRatio + 'px'
  }

initSections = ($sections) ->
  coverWidth = $sections.children('.collection').find('.cover').not('.scale').width()
  coverHeight = $sections.children('.collection').find('.cover').not('.scale').height()
  updateScaleRatio()
  $sections.each () ->
    updateSectionScrollValues $(@), 0
    $(@).data 'stackHasOpened', false
    $(@).children('.collection').each () ->
      $(@).data('status', null)
      if $(@).find('.cover').hasClass('scale')
        initScaleCover($(@).find('.cover'), $sections.children('.collection').find('.cover').not('.scale'))
      $(@).find('.exampleContent').css {
        opacity: 0
      }
      $(@).find('.exampleContent').find('.card').each () ->
        $(@).css 'height', (Math.random() * (coverHeight / 2)) + coverHeight / 2
        $(@).velocity {
          translateY: Math.random() * (coverHeight / 2)
          rotateZ: (Math.random() - .5) * rotateZRandomMax + 'deg'
        }, {
          duration: 0
          easing: basicSpring
        }

initElementAnimations = () ->
  $elements = $('.animateInPop')
  $elements.data 'hasAnimated', false
  $elements.velocity {
    translateZ: 0
    translateY: -coverHeight/2
    opacity: 0
    rotateZ:  (Math.random() - .5) * rotateZRandomMax + 'deg'
    scale: 0
  }, {
    duration: 0
    easing: fancySpring
  }

init = ($sections) ->
  initSections($sections)
  initElementAnimations()

$ ->
  $sections = $('.page > .example')

  init($sections)
  onScroll($sections)

  $(window).scroll(() ->
    onScroll($sections)
  )
  $(window).resize(() ->
    onScroll($sections)
  )