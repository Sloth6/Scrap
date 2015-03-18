draggableOptions = (socket) ->
  start: (event, ui) ->
    $(window).off 'mousemove'

    $(this).data 'startPosition', {
      left: parseFloat(elem.css('left')) #* screenScale
      top: parseFloat(elem.css('top')) #* screenScale
    }
    
  drag: (event, ui) ->
    screenScale = 1#$('.content').css('scale')
    diffX = event.clientX - click.x
    diffY = event.clientY - click.y

    start = $(this).data 'startPosition'
    $(this).css('left', (event.clientX - click.x + start.left)/screenScale)
    $(this).css('top', (event.clientY - click.y + start.top)/screenScale)
      # ui.position =
      #   left: (event.clientX - click.x + startPosition.left) / (screenScale)
      #   top: (event.clientY - click.y + startPosition.top) / (screenScale)
      
  stop: (event, ui) ->

makeDraggable = (elements) ->
  elements.draggable draggableOptions
    .on 'mouseout', ->
      $(this).css 'z-index', $(this).data 'oldZ'
    .on 'click', ->
      $(window).trigger 'mouseup'

  elements.each () ->
    url = window.location+"s/"+$(@).data().spaceid
    $(@).width 300#$(window).width()/7
    $(@).height 200#$(window).height()/7

    # $(@).width $(window).width()
      
    # $(@).height $(window).height()
    # $(@).css {
    #   width: 100/$(window).width()
    #   height: 100/$(window).height()
    # }
    # $.get url, (data) ->
    #   console.log data
      # html2canvas data, {
      #   onrendered: (canvas) ->
      #     console.log canvas.toDataURL()
      #     $(@).css('background-image', canvas.toDataURL())
      # }

  elements.click () ->
    url = window.location+"s/"+$(@).data().spaceid
    # toScale = $(window).width()/ me.width()
    $(@).css 'transform-origin', '0% 0%'
    $(@).zIndex 100

    $.get url, (data) =>
      $('<iframe />', {
        name: 'myFrame'
        id:   'myFrame'
        src: url
      }).css({
        top: 0
        left: 0
        "transform-origin": '0% 0%'
        position: 'relative'
        width: $(window).width()#'100%'
        height: $(window).height()#'100%'
        scale: 1/7
      }).click((event)->
        event.preventDefault()
        event.stopPropagation()
      ).prependTo($(@)).ready () =>
        setTimeout(() =>
          $(@).children('iframe').animate { scale: 1 }, 500
          $(@).animate({
            top: 0
            left: 0
            width: $(window).width()
            height: $(window).height()
          }, 500)
        ,500)
    

$ ->
  makeDraggable $('.draggable')
