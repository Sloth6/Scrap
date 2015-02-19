onDelete = () ->
  window.dontAddNext = true
  # if (confirm "Delete?")
  elementId = $(@).parent().parent().attr 'id'
  detach $(@).parent()
  socket.emit 'removeElement', { elementId, userId }

makeDeletable = (elem) ->
  elem.find('a.delete').mouseup onDelete

$ ->
  socket = io.connect()
  $("article a.delete").mouseup onDelete

$ ->
  socket = io.connect()
  $('.delete').droppable(
    tolerance: "pointer"
    # delete the chunk of elements when dropped on the x
    drop: (event, ui) ->
      elem = ui.draggable
      if elem.data('children')?.length
        for child_id in elem.data('children')
          socket.emit 'removeElement', { elementId: child_id }
      socket.emit 'removeElement', { elementId: elem.attr('id') }
      $(this).css {
        'background-color': 'grey'
      }
      # getIdsInCluster( ui.draggable.attr('id') ).forEach (elementId) ->
      #   # don't update position of element to be deleted
      #   $("\##{elementId}").draggable null
      #   socket.emit 'removeElement', { elementId }
      # $(this).removeClass('rollover')

    over: (event, ui) ->
      $(this).addClass('rollover')
      $(this).css {
        'background-color': 'red'
      }

    out: (event, ui) ->
      $(this).removeClass('rollover')
      $(this).css {
        'background-color': 'grey'
      }
  )