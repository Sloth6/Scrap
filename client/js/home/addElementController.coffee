addElementController =
  #  Open closed menu items
  init: (menu) ->
    console.trace()
    spacekey = menu.parent().data 'spacekey'
    input = menu.find('.textInput')
    
    menu.click (event) ->
      $(@).css({
          "transition-duration": "1s",
          "-webkit-transition-duration": "1s"
      })
      $(@).addClass 'open'
      $(@).removeClass 'closed'

    
    menu.find('.cancel a').click (event) ->
      event.preventDefault()
      console.log($(@))
      menu.removeClass 'open'
      menu.addClass 'closed'
      setTimeout (() =>
        menu.css({
          "transition-duration": ".25s",
          "-webkit-transition-duration": ".25s"
        })
      ), 500
      event.stopPropagation()

    menu.find('input').bind "paste", () ->
      setTimeout (() =>
        emitNewElement $(@).val(), spacekey
        addElementController.reset menu
      ), 20

    input.on 'keyup', (event) ->
      if event.keyCode is 13 and not event.shiftKey # on enter (not shift + enter)
        emitNewElement input.val(), spacekey
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
    menu.find('.text input,textarea').val('')

$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)

