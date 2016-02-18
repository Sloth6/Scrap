window.collectionsMenuController =
  init: ($menu) ->
#     $openMenuButton = $menu.siblings('.openMenuButton').children('a')
    $menu.find('li a').click (event) ->
      event.stopPropagation()
      event.preventDefault()
      if $(@).parents('li').hasClass 'openMenuButton'
        collectionsMenuView.open()
    parallaxHover $menu.find('li a'), 250, 1.25
    $('body').click -> collectionsMenuView.close() # Close menu on body click
    $menu.find('li').not('.openMenuButton, .openCollection').hide()
    collectionsMenuView.close()
    $menu.data 'canOpen', true
