window.collectionsMenuController =
  init: ($menu) ->
    $menu.find('li a').click (event) ->
      event.stopPropagation()
      if $(@).parents('li').hasClass('openMenuButton') # only run if is the current open menu button
        if $menu.data('canOpen') # ready to open (i.e., not in middle of close animation)
          collectionsMenuView.open()
        else # not ready to open
          window.triedToOpen = true # register attempt to open
    $('body').click ->
      collectionsMenuView.close() if $menu.hasClass 'open'
    $menu.find('li').not('.openMenuButton').hide()
    $menu.data 'canOpen', true
