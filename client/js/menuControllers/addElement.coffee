addElementController =
  #  Open closed menu items
  init: (menu) ->
    spacekey = menu.parent().parent().data 'spacekey'
    input = menu.find('.textInput')
    
    menu.click (event) ->
      $(@).css({
          "transition-duration": "1s",
          "-webkit-transition-duration": "1s"
      })
      $(@).addClass 'open'
      $(@).removeClass 'closed'

    menu.find('textarea').bind "paste", () ->
      setTimeout (() =>
        emitNewElement $(@).val(), spacekey
        addElementController.reset menu
      ), 20

    menu.find('a.submit').click (event) ->
      # console.log 'ere'
      emitNewElement input.val(), spacekey
      addElementController.reset menu
      event.preventDefault()

    menu.find('a.cancel').click (event) ->
      addElementController.reset menu
      event.preventDefault()

  close: (menu) ->
    # menu.removeClass('open').addClass 'closed'
    # setTimeout (() =>
    #   menu.css({
    #     "transition-duration": ".25s",
    #     "-webkit-transition-duration": ".25s"
    #   })
    # ), 500


  reset: (menu) ->
    # menu.find "li.expandable"
    #   .addClass "closed"
    #   .removeClass "hidden"
    #   .removeClass "open"
    menu.find('.text input,textarea').val('')

$ ->
  $('.addElementForm').each () ->
    addElementController.init $(@)

