floatingMenuController =

  #  Open closed menu items
  init: (menu) ->
    menu.find('li').css('width', 240)
    menu.find("li.closed").click () ->
      $(@)
        .removeClass "closed"
        .removeClass "hidden"
        .addClass "open"
      $(@).find('.label').hide()
      menu.find("li").not($(@))
        .addClass "closed"
        .addClass "hidden"
        .removeClass "open"
      $(@).find('input:text,textarea').focus()

  reset: (menu) ->
    menu.find "li"
      .addClass "closed"
      .removeClass "hidden"
      .removeClass "open"
    menu.find('.label').show()
    console.log menu.find $('.text input,textarea')
    menu.find $('.text input,textarea').val('')