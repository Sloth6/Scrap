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

  elements.click () ->
    url = window.location+"s/"+$(@).data().spaceid
    console.log url
    window.location = url

$ ->
  makeDraggable $('.draggable')
