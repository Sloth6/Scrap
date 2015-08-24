openCollectionCurve = [20, 10]

randomColor = ->
  letters = '0123456789ABCDEF'.split('')
  color = '#'
  i = 0
  while i < 6
    color += letters[Math.floor(Math.random() * 16)]
    i++
  color
  
mouse = { x: null, y: null }
click = { x: null, y: null }

Array.max = (array) -> Math.max.apply Math, array
Array.min = (array) -> Math.min.apply Math, array

x = ($) ->
  currTrans = $.css('transform').split(/[()]/)[1]
  console.log currTrans
  currTrans.split(',')[4]

$ ->
  window.socket = io.connect()
  history.pushState { name: "home" }, "", "/"
  
  card_container.init.call $('.slidingContainer')
  
  $(window).scroll (event) ->
    if window.dontScroll is true
      window.dontScroll = false
    else
      card_container.scroll.call $('.slidingContainer')

  $(window).mousewheel (event) ->
    if Math.abs(event.deltaY) > 2
      $(window).scrollLeft($(window).scrollLeft() + event.deltaY)
      event.preventDefault()
    
  $(window).on 'mousemove', (event) ->
    mouse.x = event.clientX
    mouse.y = event.clientY
    
  $('.cover').each( () ->
      $(@).css({
          backgroundColor : randomColor,
          rotate : (Math.random() * 4) + (Math.random() * -4)
      })
  )
  
  # open a collection
  $('.cover').click () ->
    return if $(@).hasClass 'open'

    cover = $(@)
    collection = cover.parent()
    collectionContent = collection.children '.collectionContent'

    spacekey = cover.data('spacekey')
    history.pushState { name: "home" }, "", "/#{spacekey}"

    $('.open').removeClass 'open'
    
    $(@).velocity({
        rotateY : 0
    }, {
        duration : 1000,
        easing : openCollectionCurve
    })

    collection.removeClass('closed').addClass 'open'

    # window.oldWidth = $(window.document).width()
    # window.oldScroll = $(window).scrollLeft()
    
    $(window).scrollLeft 0
    collection.siblings().hide()
    collectionContent.show()
    
    collectionContent.css 'opacity', 0

    collectionContent.velocity
      properties:
        opacity:1
      options:
        duration: 1000
        easing: [500, 100]

    card_container.realign.call $('.slidingContainer')

  window.onpopstate = (event) ->
    console.log 'onpopstate'
    return unless $('.open').length

    collection = $('.open')
    cover = collection.children '.cover'
    collectionContent = collection.children '.collectionContent'
    spacekey = cover.data 'spacekey'
    
    collection.removeClass('open').addClass 'closing'
    
    collection.siblings().show()
    
    # elements to remove
    collectionContent.children().css 'zIndex', 0

    collectionContent.children().addClass 'collapsing'
    cover.addClass 'collapsing'

    padding = $('<div>').addClass('padding').addClass('sliding').css('width', $('.cover').width())
    collectionContent.append padding


    collectionContent.velocity
      properties:
        opacity:0
      options:
        duration: 1000
        easing: [500, 100]
        complete: () ->
          collectionContent.hide()
          collectionContent.css 'opacity', 1
          collectionContent.children().removeClass 'collapsing'
          cover.removeClass 'collapsing'
          padding.remove()
    
    card_container.realign.call $('.slidingContainer')
