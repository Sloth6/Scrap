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
    
    $(constants.dom.collections).each ->
#       console.log $(@).offset().top
      $(@).data 'offsetTop', $(@).offset().top
    
    $menu.find('li.newCollection input').click ->
    # TODO: Move into view
      event.stopPropagation()
      $(@).attr 'placeholder', ''
      $(@).siblings('label').removeClass 'invisible'
      
    $menu.find('li').not('.openMenuButton, .openCollection').hide()
    