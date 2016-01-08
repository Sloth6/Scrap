lastScrollTop = 0

stackOffset = 6
duration    = 1000
easing      = [20, 10]
packeryDurationMS = duration / 2
packeryDuration = "#{packeryDurationMS / 1000}s"

cardSize = if $(window).width() < 768 then 18 else 36
gutter   = if $(window).width() < 768 then 12 else 24

randomColor = () ->
  h = Math.random() * 360
  s = 100
  l = Math.random() * 10 + 70
  {
    h: h
    s: s
    l: l
  }
#   "hsl(#{h},100%,#{l}%)"

packRecents = () ->
  $('.container.recents').packery
    itemSelector: 'article'
    gutter: gutter
    transitionDuration: packeryDuration
  setTimeout ->
    saveArticleRecentsViewPositions()
  , packeryDurationMS
    
packPacks = () ->
  $('.container.packs').packery
    itemSelector: '.packs'
    gutter: gutter
    transitionDuration: packeryDuration
  setTimeout ->
    savePacksViewPositions()
  , duration  
    
packOpenPack = () ->
  $('.pack.open').packery
    itemSelector: '.packable'
    gutter: gutter
    transitionDuration: packeryDuration
  setTimeout ->
    saveOpenPackPositions()
  , duration  

resizeCards = (minSize, gutter) ->
  null
#   $('article').each ->
#     $(@).css({
#       'padding-left':   gutter
#       'padding-top':    gutter
#       'padding-bottom': gutter
#       'padding-right':  gutter
# #       'padding-left':   if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
# #       'padding-top':    if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
# #       'padding-bottom': if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
# #       'padding-right':  if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#     })
    
saveArticleRecentsViewPositions = () ->
  $('article').each ->
    $(@).data('recentsTop',  parseInt $(@).css('top'))
    $(@).data('recentsLeft', parseInt $(@).css('left'))

savePacksViewPositions = () ->
  $('.pack').each () ->
    $(@).data('packsLeft', parseInt $(@).css('left'))
    $(@).data('packsTop',  parseInt $(@).css('top'))
  $('article').each ->
    packName = "#{$(@).data('pack')}"
    $pack  = $(".pack.#{packName}")
    i = $(@).index("article.#{packName}")
    n = $("article.#{packName}").length
    packX = parseInt($pack.data('packsLeft'))
    packY = parseInt($pack.data('packsTop'))
    $(@).data('packsLeft', parseInt(packX + (i * stackOffset)))
    $(@).data('packsTop',  parseInt(packY + (i * stackOffset)))
    
saveOpenPackPositions = () ->
  $('.pack.open .packable').each ->
    $(@).data('openPackLeft', parseInt($(@).css('left')))
    $(@).data('openPackTop',  parseInt($(@).css('top')))

initItems = () ->
  null
#   saveArticleRecentsViewPositions()
    
onResize = () ->
  if $('.content').data('layout') is 'recents'
    packRecents()
  else if $('.content').data('layout') is 'packs'
    if $('.content').data('packOpen')
      packOpenPack()
    else # if on main pack view and all packs closed
      console.log 'woefijwoeifjweofij'
      packPacks()
      
initOnLoad = () ->
  $('img').load () ->
    $('.pack').each -> sizePack($(@))
    if $('.content').data('layout') is 'recents'
      packRecents()
    else
      packPacks()

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
      top:  $article.data('packsTop')  - parseInt($pack.data('packsTop'))
      left: $article.data('packsLeft') - parseInt($pack.data('packsLeft'))
  else # switching to recents
    # reset pack top,left
    packTop   = $pack.css('top')
    packLeft  = $pack.css('left')
    # restore non-pack-dependent top,left values for articles
    $pack.children().each ->
      $(@).css
        top:  parseInt $(@).data('packsTop')
        left: parseInt $(@).data('packsLeft')
        
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
  
switchToPacks = ->
  if $('.content').data('layout') is 'recents' # Switch to packs
    $('.container.recents').packery('destroy')
    $('.content').data 'layout', 'packs'
    $('.container.packs').show()
    $('html').velocity('scroll', {
      duration: duration
      easing: easing
    })
    $('article').each -> # clear recents packery before doing anything else
      $(@).css {'top': $(@).data('recentsTop'), 'left': $(@).data('recentsLeft'), 'position': 'absolute'}
#     $('.pack').find('backgroundColor').css 'opacity', 1
    $('article').each -> # animate to pack positions
      packName            = "#{$(@).data('pack')}"
      $pack               = $(".pack.#{packName}")
      $articlesOfSamePack = $("article.#{packName}")
      indexInPack         = $(@).index("article.#{packName}")
      siblingCount        = $articlesOfSamePack.length - 1
      switchArticleProperties($(@), 'transform', 'recents')
      if indexInPack is 0 # if first article
        startX = if Math.random() > .5 then -$('.container').width() * 1.5 else $('.container').width() * 1.5
        $pack.children('header').velocity
          properties:
            translateX: [(siblingCount+1) * stackOffset, startX]
            translateY: [(siblingCount+1) * stackOffset, Math.random() * $(window).height()]
          options:
            duration: duration
            easing: easing
            begin: () ->
              $(@).show()
      $(@).velocity
        properties:
          translateX: $(@).data('packsLeft')
          translateY: $(@).data('packsTop')
        options:
          duration: duration
          easing: easing
          complete: () ->
            switchArticleProperties($(@), 'absolute', 'packs')
            positionPack($pack, $(@), packName)
            $pack.append $(@)
  setTimeout ->
    packPacks()
  , duration
  
switchToRecents = () ->
  $('.content').data 'layout', 'recents'
  $('.pack').children('header').velocity('reverse',
    {
      complete: () ->
        $(@).css {top: '', left: ''}
        $(@).hide()
    })
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
    packRecents()
  , duration * 1.1
    
closePack = () ->
  $pack = $('.pack.open')
  $otherPacks = $packs.not($pack)
  $articles   = $pack.children('article')
  $header     = $pack.children('header')
  $children   = $articles.add($header)
  $pack.removeClass 'open'
  
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
    switchProperties $(@), { x: '', y: ''}, { x: "#{$(@).data('packsLeft')}", y: "#{$(@).data('packsTop')}"}
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
  $header.data('packsTop',  parseInt $.Velocity.hook($header, 'translateX'))
  $header.data('packsLeft', parseInt $.Velocity.hook($header, 'translateY'))
  # change header to absolute from transform
  switchProperties $header, { x: $header.data('packsLeft'), y: $header.data('packsTop') }, { x: '0px', y: '0px'}
  # make articles and header packable
  $children.addClass 'packable'
  # pack articles and header
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
    console.log $(@), "#{$(@).data('packsLeft')}px", "#{$(@).data('packsTop')}px"
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
            packOpenPack()
            
#   , 250
  # change nav
  hideNavBar()
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
    
initPacks = () ->
  resizePacks()
  $('.packs.container').packery {
    itemSelector: '.pack'
    gutter: gutter
    transitionDuration: packeryDuration
  }
  $('.pack').each ->
    packName = "#{$(@).data('pack')}"
    color = randomColor()
    # trigger pack open
    $(@).click ->
      unless $('.content').data 'packOpen'
        openPack($(@))
    $(@).data 'color', randomColor()
    $(@).children('header').css('background-color', "hsl(#{color.h},100%,#{color.l}%)")
#     $(@).children('h1').css('-webkit-text-fill-color', "hsl(#{color.h},100%,#{(color.l+100)/2}%)")
    $("article.#{packName}").each ->
      $('<div></div>').addClass('backgroundColor').css('background-color',"hsl(#{color.h},100%,#{color.l}%)").prependTo($(@))
#       $(@).find('.card, .fakeCard').css('background-color', "hsl(#{color.h},100%,#{(color.l+50)/2}%)")

#     top = $("article.#{packName}").length * stackOffset
#     $(@).css
#       'margin-top': "-#{top}"
#       'opacity': .1
  packPacks()
  savePacksViewPositions()
  
initNav = ->
# Tabs
  $nav = $('ul.tabs')
  $nav.find('.tab.recents').click (event) ->
    event.preventDefault()
    if $('.velocity-animating').length < 1 # only toggle state if not animating
      unless $('.content').data('layout') is 'recents'
        switchToRecents()
  $nav.find('.tab.packs').click (event) ->
    event.preventDefault()
    if $('.velocity-animating').length < 1
      unless $('.content').data('layout') is 'packs'
        switchToPacks()
# Back button
  $back = $('nav .backButton')
  $back.hide()
  hideBackButton()
  $back.click (event) ->
    event.preventDefault()
    if $('.content').data('packOpen')
      closePack()

onScroll = () ->
  scrollTop = $(document).scrollTop()
  direction = if scrollTop > lastScrollTop then 'down' else 'up'
  lastScrollTop = scrollTop
  $bar = $('nav .bar')
  unless $('.content').data('packOpen') # don't show/hide nav bar when pack open
    if scrollTop > $bar.height()
      if (direction is 'up')
        showNavBar() if ($bar.data('state') isnt 'visible')
      else
        if $bar.data('state') isnt 'hidden'
          hideNavBar()
    else
      if $bar.data('state') isnt 'visible'
        showNavBar()
    
$ ->
  $('.content').data 'layout', 'recents'
  $('.content').data 'packOpen', false
  initItems()
  initPacks()
  initOnLoad()
  initNav()
  
  $(window).resize () -> onResize()
  onResize()
  
  $(window).scroll () -> onScroll()
  onScroll()
  
#   initDrag()
  
  
