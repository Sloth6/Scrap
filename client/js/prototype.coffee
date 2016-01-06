stackOffset = 12
duration    = 1000
easing      = [20, 10]

repack = () ->
  if $('.container').data('layout', 'recents') # only repack when in recents review
    $('.container').packery {
      itemSelector: 'article'
      transitionDuration: 0
    }
    saveItemPositions()

resizeCards = (minSize, gutter) ->
  $('article').each ->
    $(@).css({
      'padding-left':   gutter
      'padding-top':    gutter
      'padding-bottom': gutter
      'padding-right':  gutter
#       'padding-left':   if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-top':    if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-bottom': if (parseInt($(@).css('left')) is 0) then "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
#       'padding-right':  if (parseInt($(@).css('top')) is 0) then  "#{(Math.random()+.5)*minSize}px" else (Math.random()+.5) * gutter
    })
    
saveItemPositions = () ->
  $('article').each ->
    i = $(@).index(".#{$(@).data('pack')}")
    n = $(".#{$(@).data('pack')}").length
    $(@).data('recentsTop', $(@).css('top').toString())
    $(@).data('recentsLeft', $(@).css('left').toString())
    $(@).data('packsTop',  $(@).data('pack') * 300 + ((n - i) * stackOffset))
    $(@).data('packsLeft', $(@).data('pack') * 300 + ((n - i) * stackOffset))


initItems = () ->
  saveItemPositions()
    
onResize = () ->
  cardSize = if $(window).width() < 768 then 18 else 36
  gutter   = if $(window).width() < 768 then 6 else 12
  resizeCards(cardSize, gutter)
  repack()
  
initOnLoad = () ->
  $('img').load () ->
    null
#     repack()

initDrag = () ->
  itemElems = $('.container').packery('getItemElements')
  for elem in itemElems
    draggie = new Draggabilly( elem )
#     draggie.on( 'dragEnd', repack )
    $('.container').packery 'bindDraggabillyEvents', draggie
    
makePack = (title) ->
  $packTitle = $('<h1></h1>').html(title).addClass('typeTitle packTitle')
  $pack = $('<section></section>').addClass("pack #{title}").append($packTitle)
  $('.container').append($pack)
  $pack
  
positionPacks = ($pack) ->
  $h1 = $pack.children 'h1'
  if $('.container').data('layout') is 'packs'
    # transfer article top,left to its pack
    packTop   = $pack.children('article').first().css('top')
    packLeft  = $pack.children('article').first().css('left')
    $pack.css {
      top:  packTop
      left: packLeft
    }
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
        
switchProperties = ($element, absolute, transform) ->
  $element.css
    left: absolute.x
    top:  absolute.y
  $.Velocity.hook $element, 'translateX', transform.x
  $.Velocity.hook $element, 'translateY', transform.y
    
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
  if $('.container').data('layout') is 'recents' # Switch to packs
    $('.container').data 'layout', 'packs'
    $('html').velocity('scroll', {
      duration: duration
      easing: easing
    })
    $('article').each -> # Put articles into packs
      switchArticleProperties($(@), 'transform', 'recents')
      packName            = "#{$(@).data('pack')}"
      # if article doesn't have matching pack element, make one
      $pack               = if $(".pack.#{packName}").length > 0 then $(".pack.#{packName}") else makePack(packName)
      $pack.prepend $(@) # enclose in pack element
#       $pack.css 'z-index', $pack.index('.pack')
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
      $(@).velocity
        properties:
          translateX: $(@).data('packsTop')
          translateY: $(@).data('packsLeft')
        options:
          duration: duration
          easing: easing
          complete: () ->
            switchArticleProperties($(@), 'absolute', 'packs')
            if indexInPack is siblingCount # if last article
              positionPacks($pack)
  else # Switch to recents
    $('.container').data 'layout', 'recents'
    $('.pack').children('h1').velocity('reverse',
      {
        complete: () ->
          $(@).css {top: '', left: ''}
          $(@).hide()
      })
    $('.pack').each -> positionPacks($(@))
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
            $('.container').prepend $(@)
$ ->
  initItems()
  initOnLoad()
    
  $(window).resize () -> onResize()
  onResize()
  initDrag()
  
  $('.container').data 'layout', 'recents'
  
  $('body').click () ->
    if $('.velocity-animating').length < 1 # only toggle state if not animating
      toggleState()
