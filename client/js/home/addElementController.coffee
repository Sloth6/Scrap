addElementController =
  #  Open closed menu items
  init: (menu) ->
    menu.find("li.closed").not("hidden").mouseenter () ->
      $(@)
        .removeClass "closed"
        .addClass "open"
      menu.find("li").not($(@))
        .addClass "closed"
        .removeClass "open"

      $(@).find('input:text, textarea').focus()
      # spacekey = 
      input = $(@).find('.textInput')
      input.on 'keyup', (event) ->
        # on enter (not shift + enter)
        if event.keyCode is 13 and not event.shiftKey
          content = encodeURIComponent(input.val())
          socket.emit 'newElement', { content, userId, spacekey }
          addElementController.reset menu

  reset: (menu) ->
    menu.find "li.expandable"
      .addClass "closed"
      .removeClass "hidden"
      .removeClass "open"
    menu.find $('.text input,textarea').val('')

$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)

