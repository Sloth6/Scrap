panelHeadersHidden = false
window.droppableCoordinates = []

lastScrollTop = 0

scale       = 1 / 1.5
stackOffset = 6
duration    = 1000
easing      = [20, 10]
packeryDurationMS = duration / 2
packeryDuration = "#{packeryDurationMS / 1000}s"

cardSize = if $(window).width() < 768 then 18 else 36
gutter   = if $(window).width() < 768 then 12 else 24


scrollPageTo = (offset) ->
  $('html').velocity 'scroll', {
    offset: offset
    duration: duration
    easing: easing
  }

drag = (event, $dragging, droppableCoordinates) ->
  mouseX = event.clientX
  mouseY = event.clientY
  x = mouseX
  y = $(window).height() - mouseY
    
  w = 200# contentModel.getSize($dragging)
  h = 200# Math.max($dragging.find('.content').height(), 200)
  
  offsetPercentX = ($dragging.data('mouseOffsetX') - (w / 2)) / (w/2)
  offsetPercentY = ($dragging.data('mouseOffsetY') - (h / 2)) / (h/2)
  
  scaleOffsetX = (w/2)*(1-scale)*offsetPercentX
  scaleOffsetY = (h/2)*(1-scale)*offsetPercentY
  offsetX = - $dragging.data('mouseOffsetX')
  offsetY = - $dragging.data('mouseOffsetY')
  $dragging.velocity {
    translateY: x - $dragging.data 'mouseOffsetX'
    translateX: y - $dragging.data 'mouseOffsetY'
  }, { duration: 1 }
  
  # check for mouseover articles
  overAnyTarget = false
  for droppable in window.droppableCoordinates
    if mouseX >= droppable.left and mouseX <= droppable.right
      if mouseY >= droppable.top and mouseY <= droppable.bottom
        makeDropTarget $dragging, droppable.$element
        overAnyTarget = true
# Unless an article is hovered over, defocus all articles
  makeDropTarget($dragging, null) unless overAnyTarget
  
makeDropTarget = ($label, $dropTarget) ->
# If no article is hovered over, un-defocus all articles
  if $dropTarget is null
    $('.droppable').removeClass('defocus').removeClass('dropTarget')
  else
    $dropTarget.removeClass 'defocus'
    $dropTarget.addClass 'dropTarget'
    $('.droppable').not($dropTarget).addClass('defocus').css('backgroundColor', '')
    color = $label.data 'color'
    $dropTarget.css 'backgroundColor', "hsl(#{color.h},100%,#{color.l}%)"
    
applyLabel = ($label, $target, duration) ->
  color = $label.data 'color'
  $a = $label.find('a')
  $translate = $label.find('.translate')
  $scale = $label.find('.scale')
  $labelIndicator = $('<li></li>').addClass('labelIndicator').html($label.find('a').html()).css
    backgroundColor: "hsl(#{color.h},100%,#{color.l}%)"
    opacity: 0
  $labelIndicator.velocity
    properties:
      translateX: [0, $translate.offset().left - $labelIndicator.offset().left]
      translateY: [0, $translate.offset().top  - $labelIndicator.offset().top]
      scaleX: [1, 50] #$label.width()  / $labelIndicator.width()]
      scaleY: [1, 6 ] #$label.height() / $labelIndicator.height()]
      opacity: [1, 0]
    options:
      duration: duration
      easing: easing
      begin: ->
        $labelIndicator.appendTo $target.find('ul.labelIndicators')
  # translate label to top left of article
  $translate.velocity
    properties:
      translateY: $target.offset().top  - $translate.offset().top
      translateX: $target.offset().left - $translate.offset().left
    options:
      duration: duration
      easing: easing
  # scale label down to 0 as it translates up/left
  $scale.velocity
    properties:
      scaleX: $labelIndicator.width() / $label.width() 
      scaleY: $labelIndicator.height() / $label.height()
      opacity: 0
    options:
      duration: duration
      easing: easing
      complete: ->
        # reset transformations on transformation divs
        $scale.css
          backgroundColor: ''
          border: ''
          opacity: ''
        $.Velocity.hook $scale,     'scaleX',      '1'
        $.Velocity.hook $scale,     'scaleY',      '1'
        $.Velocity.hook $translate, 'translateX', '0px'
        $.Velocity.hook $translate, 'translateY', '0px'
        $a.hide()
  $target.addClass($label.data('pack') + ' ')
  console.log 'abel', $label.data('pack'), $target.attr('class') 
  
stopDragging = (mouseUpEvent, $dragging) ->
  $dragging.removeClass('dragging')
  $panel = $dragging.parents('ul.panel')
  $menu = $panel.find('li.menu')
  $header = $panel.find('li.panelHeader')
  $target = $('.dropTarget')
# If mouse is over a drop target
  if $target.length > 0
    classRemoveDelay = 500
    applyLabel $dragging, $target, classRemoveDelay
# Mouse is over nothing
  else
    classRemoveDelay = 0
  setTimeout ->
    $dragging.find('a').velocity 'reverse' # unrotate label 
    hidePanelMenu $panel, $menu, $header
    $('article').removeClass('defocus').removeClass('dropTarget').removeClass('droppable')
  , classRemoveDelay

startDragging = ($dragging, mouseDownEvent) ->
  $dragging.data 'mouseOffsetX', (mouseDownEvent.clientX - xTransform($dragging))
  $dragging.data 'mouseOffsetY', (mouseDownEvent.clientY - yTransform($dragging))
  $dragging.addClass 'dragging'
  
  # close menus
  $panel = $dragging.parents('ul.panel')
  $menu = $panel.find('li.menu')
  $header = $panel.find('li.panelHeader')
  hidePanelMenu $panel, $menu, $header
  
  # rotate label right-side-up
  $dragging.find('a').velocity
    properties:
      rotateZ: 90
    options:
      duration: 250
      easing: easing

  # make article droppable
  $('article').addClass 'droppable'
  $('.droppable').each ->
    window.droppableCoordinates.push {
        $element: $(this),
        left:     $(@).offset().left
        top:      $(@).offset().top
        right:    $(@).offset().left + $(@).width() * scale
        bottom:   $(@).offset().top + $(@).height() * scale
    }
  
  
makeDraggable = ($element) ->
  $element.find('a,img,iframe').bind 'dragstart', () -> false
  dragThreshold = 20
  
  $element.on 'mousedown', (mouseDownEvent) ->
    return unless mouseDownEvent.which is 1 # only work for left click
#     return if $(@).hasClass 'open'
#     return if $(@).hasClass 'editing'
#     return unless collectionModel.getParent($content).hasClass 'open'
#     $element.data 'originalCollection', contentModel.getCollection $content
    
    startX = mouseDownEvent.clientX
    startY = mouseDownEvent.clientY

    mousedownArticle = $element
    draggingArticle  = null
        
    $(window).mousemove (event) ->
      if draggingArticle == null
        dX = Math.abs(startX - event.clientX)
        dY = Math.abs(startY - event.clientY)
        if dX < dragThreshold and dY < dragThreshold
          return
        draggingArticle = mousedownArticle
        startDragging draggingArticle, mouseDownEvent
      drag event, draggingArticle
    
    $(window).mouseup (event) ->
      $(window).off 'mousemove'
      $(window).off 'mouseup'
      if draggingArticle?
        stopDragging(event, draggingArticle)

#   "hsl(#{h},100%,#{l}%)"

applyCloseCursor = ($element) ->
  $element.css 'cursor', 'url(/images/cursors/close.svg), auto'

removeCloseCursor = ($element) ->
  $element.css 'cursor', ''

packRecents = (animate) ->
#   resizeCards()
  $('.container.recents').packery
    itemSelector: 'article'
    gutter: gutter
    transitionDuration: if animate then packeryDuration else 0
  setTimeout ->
    saveArticleRecentsViewPositions()
  , packeryDurationMS
    
packPacks = (animate) ->
  $('.container.packs').packery
    itemSelector: '.packs'
    gutter: gutter
    transitionDuration: if animate then packeryDuration else 0
  setTimeout ->
    savePacksViewPositions()
  , duration  
    
packOpenPack = (animate) ->
  $('.pack.open').packery
    itemSelector: '.packable'
    gutter: gutter
    transitionDuration: if animate then packeryDuration else 0
  setTimeout ->
    saveOpenPackPositions()
  , duration  

resizeCards = () ->
  null
#   $('article').each ->
#     $(@).css({
# #       'padding-left':   gutter
# #       'padding-top':    gutter
# #       'padding-bottom': gutter
# #       'padding-right':  gutter
# #       'padding-left':   if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*cardSize}px" else (Math.random()+.5) * gutter
# #       'padding-top':    if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*cardSize}px" else (Math.random()+.5) * gutter
# #       'padding-bottom': if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*cardSize}px" else (Math.random()+.5) * gutter
# #       'padding-right':  if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*cardSize}px" else (Math.random()+.5) * gutter
#     })
    
saveArticleRecentsViewPositions = () ->
  $('article').each ->
    $(@).data('recentsTop',  parseInt($(@).css('top')))
    $(@).data('recentsLeft', parseInt($(@).css('left')))

savePacksViewPositions = () ->
  $('.pack').each () ->
    $(@).data('packsLeft', parseInt($(@).css('left')))
    $(@).data('packsTop',  parseInt($(@).css('top')))
  $('article').each ->
    packName = "#{$(@).data('pack')}"
    $pack  = $(".pack.#{packName}")
    i = $(@).index("article.#{packName}")
    n = $("article.#{packName}").length
    packX = 0 #$pack.data('packsLeft')
    packY = 0 #$pack.data('packsTop')
    $(@).data('packsLeft', parseInt(packX + (i * stackOffset)))
    $(@).data('packsTop',  parseInt(packY + (i * stackOffset)))
    
saveOpenPackPositions = () ->
  $('.pack.open .packable').each ->
    $(@).data('openPackLeft', parseInt($(@).css('left')))
    $(@).data('openPackTop',  parseInt($(@).css('top')))
    
closeArticle = ($article, scaleRatio, nativeDimensions) ->
  showPanelHeaders()
  $('.content').css
    position: ''
  $('.content').data 'articleOpen', false
  scrollPageTo($(document).data 'originalScroll')
  $('body').css
    maxHeight: ''
  $('.scale').velocity
    properties:
      scale: 1
      translateX: 0
      translateY: 0
    options:
      duration: duration
      easing: easing
  $('article, .packable').not($article).removeClass('defocus').velocity
      properties:
        opacity: 1
      options:
        duration: duration
        easing: easing
  $('body').off()
  $('body, article, .packable').css('cursor', '')
  $('.comments').velocity('reverse', {
    complete: -> $('.comments').hide().appendTo($('body'))
  })
  $('.comments').find('.comment').each -> $(@).velocity('reverse')
    
openArticleAnimations = ($article, scaleRatio, nativeDimensions) ->
  hidePanelHeaders()
  # Scroll to top
  $(document).data 'originalScroll', $(document).scrollTop()
  scrollPageTo(0)
#   $('.content').css
#     position: 'fixed'
#   $('body').css
# #     height: $(window).height() 
#     overflow: 'hidden'
  $card = $article.find('.card')
  translateX =  (($(window).width() / 2) / scaleRatio)  - $card.offset().left - ($card.width()/2)*scale
  translateY =  (($(window).height() / 2) / scaleRatio) - $card.offset().top -  ($card.height()/2)*scale
#   translateX = ($('.scale').width()/2)  - $card.offset().left - ($card.width()/2) *scale
#   translateY = ($('.scale').height()/2) - ($(window).height() * 2) / scaleRatio# $card.offset().top 
#   transformOriginX  = 150 # * (($card.offset().left - ($(window).width())) / ($(window).width()))
#   transformOriginY  = 0
#   transformOrigin   = "#{transformOriginX}% #{transformOriginY}%"
#   console.log translateY, scaleRatio
  $('.scale').velocity
    properties:
      scale: scaleRatio
      translateX: translateX
      translateY: translateY
    options:
      duration: duration
      easing: easing
#       begin: ->
#         $('.scale').css
#           transformOrigin:       transformOrigin
#           webkitTransformOrigin: transformOrigin

#   $('.translate').velocity
#     properties:
#       translateX: translateX
#       translateY: translateY
#     options:
#       duration: duration
#       easing: easing
  # hide other articles
  $('article, .packable').not($article).addClass('defocus')
  # make sure article is visible
  $article.velocity
    properties:
      opacity: 1
    options:
      duration: duration
      easing: easing
  $card.velocity
    properties:
      borderWidth: "#{(1 / scale) / scaleRatio}px"
    options:
      duration: duration
      easing: easing
  $('.comments').show().appendTo($article).velocity
    properties:
      scale: (1 / scale) / scaleRatio
    options:
      duration: duration
      easing: easing
  $('.comments').find('.comment').each () ->
    $(@).velocity
      properties:
        opacity: [1, 0]
        translateY: [0, $(window).height() / 2]
      options:
        duration: duration/2
        easing: easing
        delay: $(@).index() * ((duration/2) / $('.comments').find('.comment').length)
  applyCloseCursor $('body, article, .packable')
  $article.css 'cursor', 'auto'
  $article.click (event) ->
    event.stopPropagation()
  setTimeout ->
    $('body').click ->
      closeArticle($article, scaleRatio, nativeDimensions)
  , duration
    
openArticle = ($article) -> 
  type = $article.data 'type'
  $('.content').data 'articleOpen', true
  if type is 'image'
    newImage = new Image()
    newImage.src = $article.find('img').attr('src')
    scaledDimensions = {
      width:  $article.find('img').width()
      height: $article.find('img').height()
    }
    $(newImage).load ->
      nativeDimensions = {
        width:  newImage.width
        height: newImage.height
      }
      scaleRatio = nativeDimensions.width / scaledDimensions.width
      openArticleAnimations($article, scaleRatio, nativeDimensions)
  else
    nativeDimensions = {
      width:  $article.width()  / scale
      height: $article.height() / scale
    }
    scaleRatio = 1 / scale
    openArticleAnimations($article, scaleRatio, nativeDimensions)
    
    
bindArticleOpenEvents = ($article) ->
  $article.click ->
    # only make openable if in recents view or pack is open
    if ($('.content').data('layout') is 'recents') or $('.content').data('packOpen')
      # don't run if article already open
      unless $('.content').data('articleOpen')
        openArticle($article)
  
initItems = () ->
  $('article').each ->
    packName = $(@).data('pack')
    $label = $("li.label.#{packName}")
    color = $label.data('color')
    $labelIndicatorContainer = $('<ul></ul>').addClass('labelIndicators').appendTo($(@))
    $labelIndicator = $('<li></li>').addClass('labelIndicator').appendTo($labelIndicatorContainer).html($label.find('a').html()).css
      backgroundColor: "hsl(#{color.h},100%,#{color.l}%)"
    if $(@).hasClass('text')
      $(@).find('.card').css
        backgroundColor: "hsl(#{color.h},100%,95%)"
    #   null
    #   saveArticleRecentsViewPositions()
    bindArticleOpenEvents $(@)
  # hide placeholder comments
  $('.comments').hide()
    
onResize = () ->
  if $('.content').data('layout') is 'recents'
    packRecents(true)
  else if $('.content').data('layout') is 'packs'
    if $('.content').data('packOpen')
      packOpenPack(true)
    else # if on main pack view and all packs closed
      console.log 'woefijwoeifjweofij'
      packPacks(true)
      
initOnLoad = () ->
  $('img').load () ->
    $('.pack').each -> sizePack($(@))
    if $('.content').data('layout') is 'recents'
      packRecents(true)
    else
      packPacks(true)

# initDrag = () ->
#   itemElems = $('.container').packery('getItemElements')
#   for elem in itemElems
#     draggie = new Draggabilly( elem )
# #     draggie.on( 'dragEnd', repack )
#     $('.container').packery 'bindDraggabillyEvents', draggie
  
sizePack = ($pack) ->
  pack = $pack.data('pack')
  $children = $("article.#{pack}").add($pack.children('header'))
  widestWidth   = 0
  tallestHeight = 0
  # get measurements of tallest and widest articles
  $children.each () ->
    if $(@).width() > widestWidth
      widestWidth = $(@).width()
    if $(@).height() > tallestHeight
      tallestHeight = $(@).height()
  # add largest dimension to margins
  width  = widestWidth   + $children.length * stackOffset
  height = tallestHeight + $children.length * stackOffset
  $pack.css
    width: width
    height: height
  
positionPack = ($pack, $article, packName) ->
  $header = $pack.children 'header'
  if $('.content').data('layout') is 'packs'
    $article.css
      top:  $article.data('packsTop')
      left: $article.data('packsLeft')
  else # switching to recents
    # reset pack top,left
    packTop   = $pack.css('top')
    packLeft  = $pack.css('left')
    # restore non-pack-dependent top,left values for articles
    $pack.children().each ->
      $(@).css
        top:  $pack.data('packsTop')  + $(@).data('packsTop')
        left: $pack.data('packsLeft') + $(@).data('packsLeft')
        
# switch between top/left and translate x/y
switchProperties = ($element, absolute, transform) ->
  $element.css
    left: absolute.x
    top:  absolute.y
  $.Velocity.hook $element, 'translateX', transform.x
  $.Velocity.hook $element, 'translateY', transform.y
    
# switch articles between top/left and translate x/y, depending on UI state
switchArticleProperties = ($article, property, state) ->
  if property is 'transform'
    absolute = { x: '', y: '' }
    if state is 'packs'
      transform =
        x: $article.css 'left'
        y: $article.css 'top'
    else # recents
      transform =
        x: $article.data 'recentsLeft'
        y: $article.data 'recentsTop'
  else # absolute positioning
    transform = { x: '0px', y: '0px' }
    if state is 'packs'
      absolute =
        x: $.Velocity.hook $article, 'translateX'
        y: $.Velocity.hook $article, 'translateY'
    else # recents
      absolute =
        x: $article.data 'recentsLeft'
        y: $article.data 'recentsTop'
  switchProperties $article, absolute, transform
  
# switchToPacks = ->
#   if $('.content').data('layout') is 'recents' # Switch to packs
#     $('.container.recents').packery('destroy')
#     $('.content').data 'layout', 'packs'
#     $('.container.packs').show()
#     $('html').velocity('scroll', {
#       duration: duration
#       easing: easing
#     })
#     $('article').each -> # clear recents packery before doing anything else
#       $(@).css {'top': $(@).data('recentsTop'), 'left': $(@).data('recentsLeft'), 'position': 'absolute'}
# #     $('.pack').find('backgroundColor').css 'opacity', 1
#     $('article').each -> # animate to pack positions
#       packName            = "#{$(@).data('pack')}"
#       $pack               = $(".pack.#{packName}")
#       $articlesOfSamePack = $("article.#{packName}")
#       indexInPack         = $(@).index("article.#{packName}")
#       siblingCount        = $articlesOfSamePack.length - 1
#       switchArticleProperties($(@), 'transform', 'recents')
#       if indexInPack is 0 # if first article
#         animateHeaderIn($pack.children('header'), siblingCount)
# #       console.log $pack.data('left'), $pack.data('top')
#       $(@).velocity
#         properties:
#           translateX: $pack.data('packsLeft') + $(@).data('packsLeft')
#           translateY: $pack.data('packsTop')  + $(@).data('packsTop')
#         options:
#           duration: duration
#           easing: easing
#           complete: () ->
#             switchArticleProperties($(@), 'absolute', 'packs')
#             positionPack($pack, $(@), packName)
#             $pack.append $(@)
#   setTimeout ->
#     packPacks(true)
#   , duration
  
switchToRecents = () ->
  $('.content').data 'layout', 'recents'
  animateHeaderOut($('.pack').children('header'))
  $('.container.recents').show()
  $('article').each ->
    packName            = "#{$(@).data('pack')}"
    $pack               = $(".pack.#{packName}")
    positionPack($pack, $(@), packName)
    $('.container.recents').append $(@)
    switchArticleProperties($(@), 'transform', 'packs')
    $(@).velocity
      properties:
        translateX: $(@).data 'recentsLeft'
        translateY: $(@).data 'recentsTop'
      options:
        duration: duration
        easing: easing
        complete: () ->
          switchArticleProperties($(@), 'absolute', 'recents')
  setTimeout ->
    packRecents(true)
  , duration * 1.1
  

animateHeaderIn = ($header, siblingCount) ->
  startX = if Math.random() > .5 then -$('.container').width() * 1.5 else $('.container').width() * 1.5
  $header.velocity
    properties:
      translateX: [(siblingCount+1) * stackOffset, startX]
      translateY: [(siblingCount+1) * stackOffset, Math.random() * $(window).height()]
    options:
      duration: duration
      easing: easing
      begin: () ->
        $header.show()

animateHeaderOut = ($header) ->
  $header.velocity
    properties:
      translateX: if Math.random() > .5 then -$('.container').width() * 1.5 else $('.container').width() * 1.5
      translateY: Math.random() * $(window).height() * 2
    options:
      duration: duration
      easing: easing
      complete: () ->
        $header.hide()
        $header.css {top: '', left: ''}

closePack = () ->
  console.log 'close'
  $pack       = $('.pack.open')
  $packs      = $('.pack')
  $otherPacks = $packs.not($pack)
  $articles   = $pack.children('article')
  $header     = $pack.children('header')
  $children   = $articles.add($header)
  $('.content').data 'packOpen', false
  switchProperties $pack, { x: '', y: '' }, { x: parseInt($pack.css('left')), y:  parseInt($pack.css('top')) }
  console.log $pack.data('packsLeft')
# collapse open pack
  $pack.packery # have to create new packery instance for some reason
    itemSelector: '.packable'
    gutter: gutter
    transitionDuration: 0
  $pack.packery 'destroy'
  $pack.css
    top: ''
    left: ''
    position: 'absolute'
  $children.each ->
    $(@).css
      position: 'absolute'
      top: 0
      left: 0
    switchProperties $(@), { x: '0', y: '0'}, { x:  $(@).data('openPackLeft'), y:  $(@).data('openPackLeft') }
    $(@).velocity
      properties:
        translateX:  $(@).data('packsLeft')
        translateY:  $(@).data('packsTop') 
      options:
        duration: duration
        easing: easing
  $pack.removeClass 'open'
  resizePacks() # reset open pack width
  # bring back other packs
  $packs.each ->
    $(@).velocity
      properties:
        translateX:  $(@).data('packsLeft') / 2
        translateY:  $(@).data('packsTop')  / 2
      options:
        duration: duration
        easing: easing
        complete: () ->
          switchProperties $(@), { x: $(@).data('packsLeft'), y: $(@).data('packsTop')} , { x: '0px', y: '0px' }
          if $(@).index() is ($packs.length - 1)
            packPacks(true)
  hideBackButton()
  
openPack = ($pack) ->
  $packs      = $('.pack')
  $otherPacks = $packs.not($pack)
  $articles   = $pack.children('article')
  $header     = $pack.children('header')
  $children   = $articles.add($header)
  $('.content').data 'packOpen', true
  # clear packery on packs view
  $('.container.packs').packery 'destroy'
  # restore packery locations so packs to move after 'destroy'
  $pack.addClass 'open'
  $packs.each ->
    $(@).css
      top:  $(@).data 'packsTop'
      left: $(@).data 'packsLeft'
    # switch packs to transform positioning to prepare for animations
    switchProperties $(@), { x: '', y: ''}, { x: "#{$(@).data('packsLeft')}px", y: "#{$(@).data('packsTop')}px" }
  # animate other packs off screen
  $otherPacks.each ->
    $(@).velocity
      properties:
        translateX: if $(@).data('packsLeft') > ($(window).width()  / 2) then $(window).width()  * ((Math.random()+1) * 2) else -$(window).width()  * ((Math.random()+1) * 2)
        translateY: if $(@).data('packsTop')  > ($(window).height() / 2) then $(window).height() * ((Math.random()+1) * 2) else -$(window).height() * ((Math.random()+1) * 2)
      options:
        duration: duration
        easing: easing
  # animate opened pack to top left
  $pack.velocity
    properties:
      translateX: 0
      translateY: 0
    options:
      duration: duration
      easing: easing
  # set pack height and width equal to container height and width
  $pack.css
    'position': 'absolute'
    'height': '100%'
    'width':  '100%'
  # store header stack top/left values
  $header.data('packsTop',  parseInt($.Velocity.hook($header, 'translateX')))
  $header.data('packsLeft', parseInt($.Velocity.hook($header, 'translateY')))
  # change header to absolute from transform
  switchProperties $header, { x: $header.data('packsLeft'), y: $header.data('packsTop') }, { x: '0px', y: '0px'}
  # make articles and header packable
  $children.addClass 'packable'
  # pack articles and header
#   packOpenPack(false)
  $pack.packery
    itemSelector: '.packable'
    gutter: gutter
    transitionDuration: 0
  # capture destination packery values
  saveOpenPackPositions()
  # wipeout packery layout
  $pack.packery 'destroy'
  $children.css
    top: '0'
    left: '0'
    position: 'absolute'
  # switch packable elements to transform positioning to prepare for animations
#   setTimeout ->
  $children.each ->
    switchProperties $(@), { x: '', y: ''}, { x: "#{$(@).data('packsLeft')}px", y: "#{$(@).data('packsTop')}px"}
    $(@).velocity
      properties:
        translateX: $(@).data('openPackLeft')
        translateY: $(@).data('openPackTop')
      options:
        duration: duration
        easing: easing
        complete: () ->
          switchProperties $(@), { x: $(@).data('openPackLeft'), y: $(@).data('openPackTop') }, { x: '0px', y: '0px' }
          $.Velocity.hook $(@), 'translateX', '0px'
          $.Velocity.hook $(@), 'translateY', '0px'
          if $(@).index is $children.length - 1
#             $children.css
#               top: '0'
#               left: '0'
#               position: 'absolute'
            packOpenPack(true)

#   , 250
  # change nav
  showBackButton()
  
hideBackButton = ->
  $back = $('nav .backButton')
  $back.velocity
    properties:
      translateX: -$back.width()
    options:
      duration: duration
      easing: easing
      complete: () ->
        $back.hide()
  
showBackButton = ->
  $back = $('nav .backButton')
  $back.velocity
    properties:
      translateX: 0
    options:
      duration: duration
      easing: easing
      begin: () ->
        $back.show()
  
hideNavBar = ->
  $bar = $('nav .bar')
  $bar.data 'state', 'hidden'
  $bar.velocity
    properties:
      translateY: -$bar.height() * 2 # double height to keep out of Safari transparent zone
    options:
      duration: duration
      easing: easing
      complete: () ->
        $bar.hide()
  
showNavBar = ->
  $bar = $('nav .bar')
  $bar.data 'state', 'visible'
  unless $('.content').data('articleOpen')
    $bar.velocity
      properties:
        translateY: 0
      options:
        duration: duration
        easing: easing
        begin: () ->
          $bar.show()

resizePacks = () -> # stretch pack element around children
  $('.pack').each () ->
    sizePack($(@))
  $('.packs.container').packery {
    itemSelector: '.pack'
    gutter: gutter
    transitionDuration: packeryDuration
  }
  setTimeout ->
    savePacksViewPositions()
  , duration
    
initLabels = () ->
  $('li.label').each ->
    unless $(@).hasClass 'recent'
      color = $(@).data('color')
      labelName = "#{$(@).data('pack')}"
      $(@).children('a').css
        color: "hsl(#{color.h},100%,#{color.l}%)"
        '-webkit-text-fill-color' : "hsl(#{color.h},100%,#{color.l}%)"
      $("article.#{labelName}").each ->
        $('<div></div>').addClass('backgroundColor').css('background-color',"hsl(#{color.h},100%,#{color.l}%)").prependTo($(@))
      $(@).mouseenter ->
        unless $(@).hasClass 'open'
          $('li.label').not($(@)).each ->
            $(@).find('a').css
              color: 'white' # "hsl(#{color.h},100%,#{color.l}%)"
              '-webkit-text-fill-color' : 'white' # "hsl(#{color.h},100%,#{color.l}%)"
#           $(@).find('a').css
#             color: "white"
#             '-webkit-text-fill-color' : "white"
#           $('.content, article, article .card').css
#             'mix-blend-mode': 'multiply'
#           $('body, .backgroundColor').css
#             backgroundColor: "hsl(#{color.h},100%,#{color.l}%)"
      $(@).mouseout ->
        $('li.label').not($(@)).not('.recent').each ->
          color = $(@).data('color')
          $(@).find('a').css
            color: "hsl(#{color.h},100%,#{color.l}%)"
            '-webkit-text-fill-color' : "hsl(#{color.h},100%,#{color.l}%)"
#         $('.content, article, article .card').css
#           'mix-blend-mode': ''
#         $('body, .backgroundColor').css
#           backgroundColor: ''
    
#   resizePacks()
#   $('.packs.container').packery {
#     itemSelector: '.pack'
#     gutter: gutter
#     transitionDuration: packeryDuration
#   }
#   $('.pack').each ->
#     packName = "#{$(@).data('pack')}"
#     color = randomColor()
#     # trigger pack open
#     $(@).click ->
#       unless $('.content').data 'packOpen'
#         openPack($(@))
#     $(@).data 'color', randomColor()
#     $(@).children('header').css('background-color', "hsl(#{color.h},100%,#{color.l}%)")
# #     $(@).children('h1').css('-webkit-text-fill-color', "hsl(#{color.h},100%,#{(color.l+100)/2}%)")
#     $("article.#{packName}").each ->
#       $('<div></div>').addClass('backgroundColor').css('background-color',"hsl(#{color.h},100%,#{color.l}%)").prependTo($(@))
# #       $(@).find('.card, .fakeCard').css('background-color', "hsl(#{color.h},100%,#{color.l}%)")
# 
# #     top = $("article.#{packName}").length * stackOffset
# #     $(@).css
# #       'margin-top': "-#{top}"
# #       'opacity': .1
#   packPacks(true)
#   savePacksViewPositions()
  
showPanelHeaders = (stop) ->
  $('li.panelHeader').velocity
    properties:
      translateY: 0
    options:
      duration: duration
      easing: easing
      complete: -> $(@).velocity('stop', true) if stop? # prevent animations from piling up

hidePanelHeaders = ($panel) ->
  $headers = if $panel? then $panel.find($('li.panelHeader')) else $('li.panelHeader')
  $headers.velocity
    properties:
      translateY: [-$(@).height(), 0]
    options:
      duration: duration
      easing: easing
  
hidePanelMenuItem = ($menu, $menuItem) ->
  isDragging = $('.label.dragging').length > 0
  isOpeningLabel = $('.label.open').length > 0
  $menuItem.velocity
    properties:
      translateY: -$menu.height()
      translateX: 0
#       rotateZ: [90, 0]
    options:
      duration: duration
      easing: easing
      complete: () ->
        # If last menu item, hide whole menu on animation complete
        if ($(@).index() is ($menu.find('li').length - 1)) 
          $menu.hide() unless isDragging or isOpeningLabel
#           $menu.css
#             height: $menuItem.height()
#             overflow: 'hidden'
          
showPanelMenu = ($panel, $menu, $header) ->
#   $menu.css
#     height: ''
#     overflow: ''
  $menu.find('li').each ->
    $(@).css 'opacity', 0
    $(@).find('a').show() # reverse hiding of label after adding to article
    $.Velocity.hook $(@).find('a'), 'rotateZ', 0
    $(@).velocity
      properties:
#         rotateZ: [0, 90]
        translateY: [0, -$menu.height()]
      options:
        duration: duration/2 + ($(@).index() / $menu.find('li').length) * 1000
        easing: easing
        begin: () ->
          if $(@).index() is 0
            $menu.show()
          $(@).css 'opacity', 1
    makeDraggable $(@)
  hidePanelHeaders()
  $('.content').addClass 'blur'
  $('.content').append $('<div class="mask"></div>')
  applyCloseCursor $('body')
      
hidePanelMenu = ($panel, $menu, $header) ->
  isDragging = $('.label.dragging').length > 0
  isOpeningLabel = $('.label.open').length > 0
  $exemptMenuItem = if isDragging then $('.dragging') else if isOpeningLabel then $('.label.open')
  $menuItems = if isDragging or isOpeningLabel then $menu.find('li').not($exemptMenuItem) else $menu.find('li') # if dragging, exclude label being dragged from being hidden
  $menuItems.each ->
    hidePanelMenuItem $menu, $(@), isDragging
  showPanelHeaders() unless isDragging or isOpeningLabel # Put panel headers back, unless label has been dragged out or opening a label
  $('.content').removeClass 'blur'
  $('.content .mask').remove()
  removeCloseCursor $('body')
  $('body').off()
  
openLabel = ($label) ->
  label = $label.data 'pack'
  $panel = $label.parents('ul.panel')
  $menu = $panel.find('li.menu')
  $header = $panel.find('li.panelHeader')
  $label.addClass 'open'
    
  # animate label back to edge
  $label.velocity
    properties:
      translateY: -$label.offset().left
    options:
      duration: duration
      easing: easing
  # close panel
  hidePanelMenu $panel, $menu, $header
  
  # click label to open menu again
  $label.find('a').off()
  $label.find('a').click ->
    event.stopPropagation()
    event.preventDefault()
    $label.removeClass 'open'
    showPanelMenu $panel, $menu, $header
    $label.find('a').off()
  
  # filter articles
  $articles = $("article.#{label}")
  $otherArticles = $('article').not($articles)
  # scroll to top
  scrollPageTo(0)
  # animate matching articles pack in if necessary
  $articles.each ->
    $(@).velocity 'reverse', {
      complete: ->
        $(@).show()
        packRecents(true)
    }
  # animate non-matching articles away, then hide()
  $otherArticles.each ->
    $(@).velocity
      properties:
        translateY: Math.random() * $(window).height()
        translateX: if $(@).offset().left > $(window).width()/2 then $(window).width()*1.5 else -$(window).width()*1.5
        rotateZ: (Math.random() - .5) * 360
      options:
        duration: duration/2
        easing: easing
        complete: ->
          $(@).hide()
          packRecents(true)
  # repack for good measure
  packRecents(true)
  
  # add button for going back to recents view
#   $recentsLabel = $label.clone().insertBefore($menu.find('li.label').first())
#   $recentsLabel.removeAttr 'data-pack'
#   $recentsLabel.removeClass 
  
  
initNav = ->
  $('nav.main ul.panel').each ->
    $panel = $(@)
    $menu = $panel.find('li.menu')
    $header = $panel.find('li.panelHeader')
    # hide submenu
    $menu.hide()
#     $.Velocity.hook $menu, 'translateY', "-#{$menu.height()}px"
    # open panel on header click
    $header.find('a').click (event) ->
      event.stopPropagation()
      event.preventDefault()
      showPanelMenu $panel, $menu, $header
      $('body').click ->
        hidePanelMenu $panel, $menu, $header
    if $panel.hasClass 'labels'
      $menu.find('li').each ->
        $label = $(@)
        $(@).find('a').click (event) ->
          event.preventDefault()
          event.stopPropagation()
          openLabel $label
# # Tabs
#   $nav = $('ul.tabs')
#   $nav.find('.tab.recents').click (event) ->
#     event.preventDefault()
#     if $('.velocity-animating').length < 1 # only toggle state if not animating
#       unless $('.content').data('layout') is 'recents'
#         if $('.content').data('packOpen') # if pack is open, close pack first
#           closePack()
#           setTimeout ->
#             switchToRecents()
#           , duration
#         else 
#           switchToRecents()
#           
#   $nav.find('.tab.packs').click (event) ->
#     event.preventDefault()
#     if $('.velocity-animating').length < 1
#       unless $('.content').data('layout') is 'packs'
#         switchToPacks()
# # Back button
#   $back = $('nav .backButton')
#   $back.hide()
#   hideBackButton()
#   $back.click (event) ->
#     event.preventDefault()
#     if $('.content').data('packOpen')
#       closePack()

onScroll = () ->
  isScrolling = true
  scrollTop = $(document).scrollTop()
  direction = if scrollTop > lastScrollTop then 'down' else 'up'
  articleIsOpen = $('.content').data 'articleOpen'
  hasScrolledSomeDistance = scrollTop isnt lastScrollTop # true if user has actually scrolled, and scroll event wasn't triggered without real movement
  
#   # hide side panels on scroll
# #   if hasScrolledSomeDistance and (scrollTop > 200) and (panelHeadersHidden isnt true)
#   unless panelHeadersHidden or articleIsOpen
#     hidePanelHeaders() if hasScrolledSomeDistance
#     panelHeadersHidden = true
#   clearTimeout $.data this, 'hidePanelHeadersTimer'
#   $.data this, 'hidePanelHeadersTimer', setTimeout ->
#     showPanelHeaders(true) if hasScrolledSomeDistance or not articleIsOpen
#     panelHeadersHidden = false
#   , 500
  
  lastScrollTop = scrollTop
  
  
#   $bar = $('nav .bar')
#   unless $('.content').data('packOpen') # don't show/hide nav bar when pack open
#     if scrollTop > $bar.height()
#       if (direction is 'up')
#         showNavBar() if ($bar.data('state') isnt 'visible')
#       else
#         if $bar.data('state') isnt 'hidden'
#           hideNavBar()
# #           $bar.css
# #             backgroundColor: 'transparent'
# #             borderColor: 'transparent'
#     else
#       if $bar.data('state') isnt 'visible'
#         showNavBar()
# #         setTimeout ->
# #         , duration
#     if scrollTop > 0
#       $bar.css
#         borderColor: 'black'
#     else
#       $bar.css
#         borderColor: 'transparent'

$ ->
  $('.content').data 'layout', 'recents'
  $('.content').data 'packOpen', false
  $('.content').data 'articleOpen', false
  initLabels()
  initItems()
  initOnLoad()
  initNav()
  
  $(window).resize -> onResize()
  onResize()
  
  $(window).scroll -> onScroll()
  onScroll()
  
#   initDrag()
  
  
