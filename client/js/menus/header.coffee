$ ->
  $('ul.menu').each () ->
    $menu = $(@)
    inputIsFocused  = false
    subMenuIsOpen   = false
    canCloseMenu    = false
            
    openMenu = ->
      $menu.addClass 'open'
      articleView.obscure $(constants.dom.articles)
      
    closeMenu = ->
      $menu.removeClass 'open'
      resetSubmenu()
      canCloseMenu = false
      articleView.unobscure $(constants.dom.articles)
  
    resetSubmenu = ->
      $menu.find($('ul.submenu li')).addClass 'hidden'
      $menu.find($('li.hideOnOpenSubmenu')).removeClass 'hidden'
      $menu.removeClass('paddingBottom')
      inputIsFocused = false
      subMenuIsOpen = false
      
    # Close menu when clicking outside
    $('body').on 'touchend mouseup', (event) ->
      event.stopPropagation()
      if $menu.hasClass 'open'
        closeMenu()
    
    # Prevent clicks inside menu from closing menu
    $menu.on 'touchend mouseup', (event) ->
      event.stopPropagation()
    
    $menu.children("li:first-child").on 'touchend mouseup', (event) ->
      unless inputIsFocused or subMenuIsOpen
        openMenu()
        setTimeout(()->
          canCloseMenu = true
        , 500)
  
    $menu.find('input').focus ->
      inputIsFocused = true
      openMenu
  
    # Settings menu
    $menu.find($('li.update')).on 'touchend mouseup', ->
      inputIsFocused = true
      subMenuIsOpen = true
      $('ul.submenu li.hidden').removeClass 'hidden'
      $('li.hideOnOpenSubmenu').addClass 'hidden'
      $menu.addClass('paddingBottom')
  
    $menu.find($('.backButton a')).on 'touchend mouseup', (event) ->
      event.preventDefault()
      resetSubmenu()