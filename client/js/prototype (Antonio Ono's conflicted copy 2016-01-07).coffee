stackOffset = 6
duration    = 2000
easing      = [20, 10]
packeryDuration = 0 # "#{duration / 1000}s"

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
  saveArticleRecentsViewPositions()
    
    
packPacks = () ->
  $('.container.packs').packery
    itemSelector: '.packs'
    gutter: gutter
    transitionDuration: packeryDuration
  savePacksViewPositions()
  
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
  console.log 'saveArticleRecentsViewPositions'
  $('article').each ->
    $(@).data('recentsTop', $(@).css('top').toString())
    $(@).data('recentsLeft', $(@).css('left').toString())

savePacksViewPositions = () ->
  $('.pack').each () ->
    $(@).data('packsLeft', $(@).css('left'))
    $(@).data('packsTop',  $(@).css('top'))
  $('article').each ->
    packName = "#{$(@).data('pack')}"
    $pack  = $(".pack.#{packName}")
    i = $(@).index(".#{packName}")
    n = $("article.#{packName}").length
    packX = parseInt $pack.data('packsLeft')
    packY = parseInt $pack.data('packsTop')
#     console.log packX, packY
    $(@).data('packsLeft', packX + (((n-1)-i) * stackOffset))
    $(@).data('packsTop',  packY + (((n-1)-i) * stackOffset))

initItems = () ->
  null
#   saveArticleRecentsViewPositions()
    
onResize = () ->
  if $('.content').data('layout') is 'recents'
    packRecents()
  else if $('.content').data('layout') is 'packs'
    packPacks()
  
initOnLoad = () ->
  $('img').load () ->
    packPacks()
    packRecents()
    resizePacks()

# initDrag = () ->
#   itemElems = $('.container').packery('getItemElements')
#   for elem in itemElems
#     draggie = new Draggabilly( elem )
# #     draggie.on( 'dragEnd', repack )
#     $('.container').packery 'bindDraggabillyEvents', draggie
    
# makePack = (title) ->
#   $packTitle = $('<h1></h1>').html(title).addClass('typeTitle packTitle')
#   $pack = $('<section></section>').addClass("pack #{title}").append($packTitle)
#   $('.container.packs').append($pack)
#   $pack
  
sizePack = ($pack) ->
  pack = $pack.data('pack')
  $children = $("article.#{pack}")
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
  
positionPack = ($pack) ->
  $h1 = $pack.children 'h1'
  if $('.content').data('layout') is 'packs'
    # transfer article top,left to its pack
    packTop   = $pack.children('article').first().css('top')
    packLeft  = $pack.children('article').first().css('left')
#     $pack.css {
#       top:  packTop
#       left: packLeft
#     }
    # make article top,left relative to pack's top,left
    switchProperties $h1, {x: $.Velocity.hook($h1, 'translateX'), y: $.Velocity.hook($h1, 'translateY') }, {x: '0px', y: '0px'}
    $pack.children().each ->
      $(@).css
        top:  parseInt($(@).css('top'))  - parseInt(packTop)
        left: parseInt($(@).css('left')) - parseInt(packLeft)
  else # switching to recents
    # reset pack top,left
    packTop   = $pack.css('top')
    packLeft  = $pack.css('left')
    $pack.css
      top:  0
      left: 0
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
      
toggleState = () ->
  if $('.content').data('layout') is 'recents' # Switch to packs
    $('.content').data 'layout', 'packs'
#     repack()
#     $('html').velocity('scroll', {
#       duration: duration
#       easing: easing
#     })
#     repack()
    $('.packs.container').show()
    $('article').each -> # Put articles into packs
      switchArticleProperties($(@), 'transform', 'recents')
      packName            = "#{$(@).data('pack')}"
      $pack               = $(".pack.#{packName}")
      $pack.prepend $(@) # enclose in pack element
#       $pack.css 'z-index', $pack.index('.pack')
    $('.container.recents').hide()
#     $('.container.recents').packery('destroy')
    $('article').each -> # animate to pack positions
      packName            = "#{$(@).data('pack')}"
      $pack               = $(".pack.#{packName}")
      $articlesOfSamePack = $("article.#{packName}")
      indexInPack         = $(@).index("article.#{packName}")
      siblingCount        = $articlesOfSamePack.length - 1
      if indexInPack is 0 # if first article
        startX = if Math.random() > .5 then -$('.container').width() * 1.5 else $('.container').width() * 1.5
        $pack.children('h1').velocity
          properties:
            translateX: [parseInt($articlesOfSamePack.last().data('packsLeft')) + stackOffset, startX]
            translateY: [parseInt($articlesOfSamePack.last().data('packsTop'))  + stackOffset, Math.random() * $(window).height()]
          options:
            duration: duration
            easing: easing
            begin: () ->
              $(@).show()
      color = $pack.data('color')
#       $('<div></div>').addClass('backgroundColor').css('background-color', "hsl(#{color.h},100%,#{(color.l+50)/2}%)").prependTo($(@))
#       $pack.children('h1').css('-webkit-text-fill-color', "hsl(#{color.h},100%,#{(color.l+100)/2}%)")
#       $(@).find('.card, .fakeCard').css('background-color', $pack.data('color'))
      $(@).velocity
        properties:
          translateX: $(@).data('packsLeft')
          translateY: $(@).data('packsTop')
        options:
          duration: duration
          easing: easing
          complete: () ->
            switchArticleProperties($(@), 'absolute', 'packs')
            if indexInPack is siblingCount # if last article
#               sizePack($pack)
              positionPack($pack)
  else # Switch to recents
    $('.content').data 'layout', 'recents'
    $('.pack').children('h1').velocity('reverse',
      {
        complete: () ->
          $(@).css {top: '', left: ''}
          $(@).hide()
      })
    $('.pack').each -> positionPack($(@))
    $('.container.recents').show()
    $('article').each ->
      $('.container.recents').prepend $(@)
#     $('.container.packs').hide()
    $('article').each ->
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
#             repack()
    packPacks()
#   setTimeout ->
#     packPacks()
#     packRecents()
#   , 2000
    
resizePacks = () ->
  $('.pack').each () ->
    sizePack($(@))
  $('.packs.container').packery {
    itemSelector: '.pack'
    gutter: gutter
    transitionDuration: packeryDuration
  }
  savePacksViewPositions()
    
initPacks = () ->
  resizePacks()
  setTimeout ->
    $('.packs.container').packery {
      itemSelector: '.pack'
      gutter: gutter
      transitionDuration: packeryDuration
    }
  , 2000
  $('.pack').each ->
    $(@).data 'color', randomColor()
  savePacksViewPositions()
  $('.packs.container').hide()
  
$ ->
  $('.content').data 'layout', 'recents'
  initItems()
  initPacks()
  initOnLoad()
  
  $(window).resize () -> onResize()
  onResize()
#   initDrag()
  
  
  $('body').click () ->
    if $('.velocity-animating').length < 1 # only toggle state if not animating
      toggleState()
