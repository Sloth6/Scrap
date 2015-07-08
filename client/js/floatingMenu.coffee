floatingMenuController =

  #  Open closed menu items
  init: (menu) ->
    menu.find("li.closed").not("hidden").mouseenter () ->
      $(@)
        .removeClass "closed"
#         .removeClass "hidden"
        .addClass "open"
#       $(@).find('.label').hide()
      menu.find("li").not($(@))
        .addClass "closed"
#         .addClass "hidden"
        .removeClass "open"
      $(@).find('input:text,textarea').focus()

  reset: (menu) ->
    menu.find "li.expandable"
      .addClass "closed"
      .removeClass "hidden"
      .removeClass "open"
    menu.find $('.text input,textarea').val('')