repack = () ->
  if $('.container').data('uiState', 'recents') # only repack when in recents review
    $('.container').packery {
      itemSelector: 'article'
      transitionDuration: 0
    }
    saveItemPositions()

resizeCards = (minSize, gutter) ->
  $('article').each () ->
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
  $('article').each () ->
#     console.log $(@).data('pack') * 300) + ($(@).index(".#{$(@).data('pack')}") * 12))
    $(@).data('recentsTop', $(@).css('top').toString())
    $(@).data('recentsLeft', $(@).css('left').toString())
    $(@).data('packsTop',  $(@).data('pack') * 300 + ($(@).index(".#{$(@).data('pack')}") * 12))
    $(@).data('packsLeft', $(@).data('pack') * 300 + ($(@).index(".#{$(@).data('pack')}") * 12))


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
  
positionPacks = () ->
  if $('.container').data('uiState') is 'packs'
    # transfer article top,left to its pack
    $('.pack').each () ->
      $pack     = $(@)
      packTop   = $pack.children('article').first().css('top')
      packLeft  = $pack.children('article').first().css('left')
      $pack.css {
        top:  packTop
        left: packLeft
      }
      # make article top,left relative to pack's top,left
      $pack.children('article').each () ->
        top =  parseInt($(@).data('packsTop'))  - parseInt(packTop)
        left = parseInt($(@).data('packsLeft')) - parseInt(packLeft)
        $(@).css {
#           border: '1px solid red'
          top:  top
          left: left
        }
  else # switching to recents
    $('.pack').each () ->
      # reset pack top,left
      $pack     = $(@)
      packTop   = $pack.css('top')
      packLeft  = $pack.css('left')
      $pack.css {
        top:  ''
        left: ''
      }
      # make article top,left relative to pack's top,left
      $pack.children('article').each () ->
        top =  parseInt($(@).data('packsTop'))  + parseInt(packTop)
        left = parseInt($(@).data('packsLeft')) + parseInt(packLeft)
        $(@).css {
#           border: '1px solid lime'
          top:  top
          left: left
        }  
    
    
switchProperties = ($article, property, state) ->
  if property is 'transform'
    absoluteLeft  = ''
    absoluteTop   = ''
    if state is 'packs'
      transformLeft = $article.css 'left'
      transformTop  = $article.css 'top'
    else # recents
      transformLeft = $article.data 'recentsLeft'
      transformTop  = $article.data 'recentsTop'
  else # absolute positioning
    transformLeft = '0px'
    transformTop  = '0px'
    if state is 'packs'
      absoluteLeft  = $.Velocity.hook $article, 'translateX'
      absoluteTop   = $.Velocity.hook $article, 'translateY'
    else # recents
      absoluteLeft  = $article.data 'recentsLeft'
      absoluteTop   = $article.data 'recentsTop'
  $article.css
    left: absoluteLeft
    top:  absoluteTop
  $.Velocity.hook $article, 'translateX', transformLeft
  $.Velocity.hook $article, 'translateY', transformTop
      
toggleState = () ->
  if $('.container').data('uiState') is 'recents' # Switch to packs
    $('.container').data 'uiState', 'packs'
    $('html').velocity('scroll', {
      duration: 1000
      easing: [20, 10]
    })
    $('article').each () ->
      switchProperties($(@), 'transform', 'recents')
      $(@).velocity
        properties:
          translateX: $(@).data('packsTop')
          translateY: $(@).data('packsLeft')
        options:
          duration: 1000
          easing: [20, 10]
          complete: () ->
            switchProperties($(@), 'absolute', 'packs')
            # enclose in pack element
            if $("section.pack.#{$(@).data('pack')}").length < 1
              # if article doesn't have matching pack element, make one
              makePack($(@).data('pack').toString())
            $pack = $(".pack.#{$(@).data('pack')}")
            $pack.append $(@)
            # if last article
            if $('article').length is $(@).index('article') + 1
              positionPacks()
  else # Switch to recents
    $('.container').data 'uiState', 'recents'
    positionPacks()
    setTimeout ->
      $('article').each () ->
        switchProperties($(@), 'transform', 'packs')
        $(@).velocity
          properties:
            translateX: $(@).data 'recentsLeft'
            translateY: $(@).data 'recentsTop'
          options:
            duration: 1000
            easing: [20, 10]
            complete: () ->
              switchProperties($(@), 'absolute', 'recents')
              $('.container').append $(@)
    , 500
$ ->
  initItems()
  initOnLoad()
    
  $(window).resize () -> onResize()
  onResize()
  initDrag()
  
  $('.container').data 'uiState', 'recents'
  
  $('body').click () ->
    if $('.velocity-animating').length < 1 # only toggle state if not animating
      toggleState()
