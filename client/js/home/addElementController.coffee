emit = (content, spacekey) ->
  content = encodeURIComponent(content)
  if content != ''
    console.log "emiting '#{content}' to #{spacekey}"
    socket.emit 'newElement', { content, userId, spacekey }

addElementController =
  #  Open closed menu items
  init: (menu) ->
    console.trace()
    spacekey = menu.parent().data 'spacekey'
    input = menu.find('.textInput')

    menu.find('input').bind "paste", () ->
      setTimeout (() =>
        emit $(@).val(), spacekey
        addElementController.reset menu
      ), 20

    input.on 'keyup', (event) ->
      if event.keyCode is 13 and not event.shiftKey # on enter (not shift + enter)
        emit input.val(), spacekey
        addElementController.reset menu

    menu.find("li.closed").not("hidden").mouseenter () ->
      $(@)
        .removeClass "closed"
        .addClass "open"
      menu.find("li").not($(@))
        .addClass "closed"
        .removeClass "open"

      $(@).find('input:text, textarea').focus()
      

  reset: (menu) ->
    menu.find "li.expandable"
      .addClass "closed"
      .removeClass "hidden"
      .removeClass "open"
    menu.find $('.text input,textarea').val('')

$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)

