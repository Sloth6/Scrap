window.collectionsMenuController =
  init: ($menu) ->
    $openMenuButton = $menu.siblings('.openMenuButton').children('a')
    $openMenuButton.click (event) ->
      event.stopPropagation()
      event.preventDefault()
      collectionsMenuView.open()
      console.log 'clicked'
    parallaxHover $menu.find('li a'), 250, 1.25
    # Close menu on body click
    $('body').click -> collectionsMenuView.close()
    $menu.find('li').not('.openMenuButton, .openCollection').hide()
    collectionsMenuView.close()
    $menu.data 'canOpen', true
