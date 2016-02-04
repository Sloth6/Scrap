$ ->
  $('ul.menu').each () ->
    $menu = $(@)
    console.log $menu
    inputIsFocused  = false
    subMenuIsOpen   = false
    canCloseMenu    = false
            
    openMenu = ->
      $menu.addClass 'open'
      
    closeMenu = ->
      $menu.removeClass 'open'
      resetSubmenu()
      canCloseMenu = false
  
    resetSubmenu = ->
      $menu.find($('ul.submenu li')).addClass 'hidden'
      $menu.find($('li.hideOnOpenSubmenu')).removeClass 'hidden'
      $menu.removeClass('paddingBottom')
      inputIsFocused = false
      subMenuIsOpen = false
      
    # Close menu when clicking outside
    $('body').click (event) ->
      event.stopPropagation()
      if $menu.hasClass 'open'
        closeMenu()
    
    # Prevent clicks inside menu from closing menu
    $menu.click (event) ->
      event.stopPropagation()
    
    $menu.children("li:first-child").click (event) ->
      unless inputIsFocused or subMenuIsOpen
        openMenu()
        setTimeout(()->
          canCloseMenu = true
        , 500)
  
    $menu.find('input').focus ->
      inputIsFocused = true
      openMenu
  
    # Settings menu
    $menu.find($('li.update')).click ->
      inputIsFocused = true
      subMenuIsOpen = true
      $('ul.submenu li.hidden').removeClass 'hidden'
      $('li.hideOnOpenSubmenu').addClass 'hidden'
      $menu.addClass('paddingBottom')
      console.log 'subMenuIsOpen'
  
    $menu.find($('.backButton a')).click (event) ->
      event.preventDefault()
      resetSubmenu()