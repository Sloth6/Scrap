width = $(window).width()
basicSpring = [60, 10]
fancySpring = [100, 10]
easingSmooth = [20, 10]
coverWidth = 0
coverHeight = 0
scaleRatio = coverWidth / $(window).width()
previousStep = 0
collectionOpenDuration = 1000
rotateZRandomMax = 45

updateScaleRatio = () ->
  scaleRatio = coverWidth / $(window).width()

scaleCover = (scrollProgress, $cover, $caption) ->
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
  # Bring caption to top on scroll
  if scrollProgress < .9
    $caption.css
      zIndex: 0
    $caption.find('.createAccount').css
      opacity: 0
  else
    $caption.css
      zIndex: $cover.css('z-index') + 1
    $caption.find('.createAccount').css
      opacity: 1
  $('nav ul.menu li.first').css
    opacity: if $cover.offset().top < $('nav ul.menu li.first').height() * 3 then .2 else 1
    
animateOutPop = ($element) ->
  if $element.data('hasAnimatedIn')
    $element.velocity {
      translateZ: 0
      translateY: coverHeight
      scaleX: 0
      scaleY: 2
      rotateZ: (Math.random() - .5) * rotateZRandomMax + 'deg'
      opacity: 0
    }, {
      duration: collectionOpenDuration
      easing: fancySpring
      delay: collectionOpenDuration / 8
    }
    $element.data 'hasAnimatedIn', false
        
animateInPop = ($element) ->
  unless $element.data 'hasAnimatedIn'
    $element.velocity {
      translateZ: 0
      translateY: [0, coverHeight]
      scaleY: 1
      scaleX: 1
      rotateZ: '0deg'
      opacity: 1
    }, {
      duration: collectionOpenDuration
      easing: fancySpring
      delay: collectionOpenDuration / 8
    }
  $element.data 'hasAnimatedIn', true
  
closeCollection = ($section, $collection, $cover, $cards) ->
  $cover.velocity 'reverse'
  $cards.parent('.exampleContent').velocity 'reverse'
  $cards.each -> $(@).velocity 'reverse'
  $collection.data('stackHasOpened', false)

openCollection = ($section, $collection, $cover, $cards) ->
  cardSpacing             = 4
  maxRotate               = 12
  translateXToWindowLeft  = (cardSpacing * 1.5) + ((coverWidth / 2) - ($(window).width()/2))
  translateY              = 0
  $cover.velocity {
    translateZ:   0
    translateX:   if $section.hasClass 'join' then 0 else translateXToWindowLeft
    translateY:   if $section.hasClass 'join' then -$(window).height() / 4 else 0
  }, {
    duration: collectionOpenDuration
    easing: basicSpring
  }
  
  $cards.parent('.exampleContent').velocity {
    opacity: 1
  }, {
    duration: collectionOpenDuration / 2
    easing: easingSmooth
  }

  $cards.each () ->
    # Sum width of previous cards
    widthOfPreviousCards = 0
    $(@).prevAll().each () ->
      widthOfPreviousCards += $(@).width()
    translateXStart   = (-$(window).width() / 2) + coverWidth + cardSpacing * 4
    translateX        = widthOfPreviousCards + translateXStart + (($(@).index() + 2) * cardSpacing)
    rotateZ           = '0deg'
    $(@).velocity({
      translateZ: 0
      translateY: [translateY, Math.random() * (coverHeight / 2)]
      translateX
      rotateZ: [rotateZ, (Math.random() - .5) * rotateZRandomMax + 'deg']
      scaleX: [1, 1]
      scaleY: [1, 0]
    }, {
      duration: collectionOpenDuration
      easing: basicSpring
      delay: Math.random() * (collectionOpenDuration / 4)
    })
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
  $cover            = $collection.find('.cover')
  $translateCover   = if $cover.hasClass 'scale' then $cover.parent('.translate') else $cover
  $exampleCards     = $collection.children('.exampleContent').find('article')
  $caption          = $section.find('.caption')
  collectionTopPercentage       = .1 # Percentage of window height
  collectionTop                 = $(window).height() * collectionTopPercentage
  windowTopToCollectionBottom   = collectionTop + coverHeight
  sectionTopToCollectionBottom  = $section.height() + coverHeight

  openCollectionThreshold = if $cover.hasClass('scale') then 2 else 1
  
  updateSectionScrollValues $section, scrollTop

  # Scale content section down unless halfway scrolled through first screen
  if $cover.hasClass 'scale'
    scaleCover(Math.max(0, Math.min(1, ($section.data('sectionTopToWindowTopProgress')  - 1) * 4)), $cover, $caption)

  if $section.data('sectionTopToWindowTopProgress') >= openCollectionThreshold
    animateInPop($section.find('.animateInOnCollectionOpen'))
    if ($section.hasClass 'join') and ($caption.css('z-index') < $cover.css('z-index'))
      setTimeout (() ->
        $caption.css('z-index', $cover.css('z-index') + 1)
      ), collectionOpenDuration
    unless $collection.data('stackHasOpened')# or $section.hasClass 'cantOpen'
      openCollection($section, $collection, $translateCover, $exampleCards)
    if $section.hasClass('intro')
      animateOutPop($section.find('.animateOutOnCollectionOpen'))
  else
    animateOutPop($section.find('.animateInOnCollectionOpen'))
    if $section.hasClass 'join'
      $caption.css 'z-index', 0
    if $collection.data('stackHasOpened') # or not $section.hasClass 'cantOpen'
      closeCollection($section, $collection, $translateCover, $exampleCards)
    if $section.hasClass('intro')
      animateInPop($section.find('.animateOutOnCollectionOpen'))

  if $section.data('sectionTopToWindowTopProgress') >= 1
    if $section.data('sectionBottomToWindowBottomProgress') <= 1
      if $collection.data('status') != 'current'
        positionElement($collection, 'current', 'fixed', 0)
        positionElement($caption, 'current', 'fixed', 0)
    else if $collection.data('status') != 'above'
      # Section is scrolled past
      positionElement($collection, 'above', 'absolute', $section.height() - $collection.height())
      positionElement($caption, 'above', 'absolute', $section.height() - $(window).height())
  else
    if ($collection.data('status') != 'below')
      positionElement($collection, 'below', 'absolute', 0)
      positionElement($caption, 'below', 'absolute', 0)
            
animateJoin = () ->
  $section = $('.join')
      
onScroll = ($sections) ->
  scrollTop       = $(window).scrollTop() 
  scrollProgress  = scrollTop / Math.max(($(document).height() - $(window).height()), 1)
  updateScaleRatio()
  $sections.each () ->
    onScrollSection($(@), scrollTop, scrollProgress)
  animateJoin()
    
initScaleCover = ($scaleCover, $normalCover) ->
  $normalH1 = $normalCover.find('h1')
  transformOrigin = "#{$(window).width() / 2}px 232pt"
  $scaleCover.css {
    transformOrigin: transformOrigin
    webkitTransformOrigin: transformOrigin
    padding:  parseFloat($normalCover.css('padding')) / scaleRatio + 'px'
    height:   parseFloat($normalCover.css('height')) / scaleRatio + 'px'
    width:    parseFloat($normalCover.css('width')) / scaleRatio + 'px'
#     backgroundColor: $normalCover[0].style.backgroundColor
  }
  
  $scaleCover.find('h1').css {
    letterSpacing: parseFloat($normalH1.css('letter-spacing')) / scaleRatio + 'px'
    lineHeight:    parseFloat($normalH1.css('line-height')) / scaleRatio + 'px'
    fontSize:      parseFloat($normalH1.css('font-size')) / scaleRatio + 'px'
    marginTop:     parseFloat($normalH1.css('margin-top')) / scaleRatio + 'px'
    marginLeft:    parseFloat($normalH1.css('margin-left')) / scaleRatio + 'px'
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

initElementAnimations = () ->
  $elements = $('.animateInPop')
  hasAnimatedIn = if $elements.hasClass 'animateInOnCollectionOpen' then false else true
  $elements.data 'hasAnimatedIn', hasAnimatedIn
  $elements.velocity {
    translateZ: 0
    translateY: -coverHeight/2
    opacity: 0
    rotateZ:  (Math.random() - .5) * rotateZRandomMax + 'deg'
    scaleX: 0
    scaleY: 2
  }, {
    duration: 0
    easing: fancySpring
  }

  
initJoinAnimations = () ->
  $join = $('.page.join')
  $cover = $join.find('.cover')
  
initCreateAccount = () ->
  $button = $('.page').children('.caption').find('p.createAccount a')
  $signUp = $('nav .signUp.card')
  duration = 1000
  signUpIsOpen = false
  $signUp.css {
    top:  $(window).height() / 2
    left: $(window).width()  / 2
    marginTop:  -$signUp.height() / 2
    marginLeft: -$signUp.width()  / 2
  }
  $signUp.velocity {
    translateZ: 0
    translateY: $(window).height() / 2 + $signUp.height() / 2
    scaleX: 0
    scaleY: .5
    rotateZ: (Math.random() * rotateZRandomMax/2) - (rotateZRandomMax/2) + 'deg'
  }, {
    duration: 0
    easing: basicSpring
  }
  $button.click (event) ->
    if signUpIsOpen is false
      $signUp.velocity {
        translateZ: 0
        translateY: 0
        scaleX: 1
        scaleY: 1
        rotateZ: 0
      }, {
        duration
        easing: fancySpring
      }
      $('.page.index .contentBlah').velocity {
        translateZ: 0
        opacity: .125
        blur: 10
      }, {
        duration
        easing: easingSmooth
      }
    event.stopPropagation()
    event.preventDefault()
    signUpIsOpen = true
  $('body').click (event) ->
    if signUpIsOpen
      signUpIsOpen = false
      $signUp.velocity 'reverse'
      $('.page.index .contentBlah').velocity 'reverse', { duration }

init = ($sections) ->
  initSections($sections)
  initElementAnimations()
  initJoinAnimations()
  initCreateAccount()

$ ->
  $sections = $('.page.index > .contentBlah > .example')
  init $sections
  onScroll $sections
  $(window).scroll -> onScroll $sections
  $(window).resize -> onScroll $sections