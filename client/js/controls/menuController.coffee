window.menuModel =
  animation:
    easing: [30, 10] #constants.velocity.easing.smooth
    duration: 500

  getList: ($menu) ->
    $menu.children('ul.menuItems')
    
  getButton: ($menu) ->
    $menu.children('input.menuOpenButton')
    
  getListItems: ($menu) ->
    $list = menuModel.getList $menu
    $list.children('li')
    
  getSubmenus: ($menu) ->
    $menu.find('ul.submenu')
    
  getSubmenuButtons: ($menu) ->
    $menu.find('input.submenuOpenButton')
    
  getMenuFromSubmenu: ($submenu) ->
    $submenu.parents('.menuNeue')
    
  getSubmenuButton: ($submenu) ->
    submenuId = $submenu.data 'submenu'
    $menu = menuModel.getMenuFromSubmenu $submenu
    $buttons = menuModel.getSubmenuButtons $menu
    # Button that matches this submenu
    $button  = $buttons.filter("[data-submenu='#{submenuId}']")
    $button
    
  getSubmenuBackButton: ($submenu) ->
    $submenu.children('li.backButton').children('a')
    
  getSubmenuItems: ($submenu) ->
    $submenu.find 'li'
    
window.menuController =
  init: ($menus) ->
    $menus.each ->
      $menu = $(@)
      $button = menuModel.getButton $menu
      $list = menuModel.getList $menu
      $items = menuModel.getListItems $menu
      $submenus = menuModel.getSubmenus $menu
      
      $submenus.each ->
        menuController.initSubmenu $menu, $(@)

      menuView.init $menu
      
      # Capture original dimensions
      $list.data 'nativeWidth',  $list.width()
      $list.data 'nativeHeight', $list.height()
      $items.each ->
        $(@).data 'nativeWidth',  $(@).width()
        $(@).data 'nativeHeight', $(@).height()

      # Immediately close menu
      menuController.close $menu
      # Bind button to open/close menu
      $button.on 'touchend mouseup', ->
        event.stopPropagation()
        if $menu.data('isOpen')
          menuController.close $menu
        else
          menuController.open $menu
      # Stop propagation on all clickables
      $menu.find('a, input').on 'touchend mouseup click', (event) ->
        event.stopPropagation()
      
  close: ($menu) ->
    menuView.close $menu
    $menu.data 'isOpen', false
    $submenus = menuModel.getSubmenus $menu
#     $submenus.each ->
#       menuView.closeSubmenu $menu, $(@)
    
  open: ($menu) ->
    menuView.open $menu
    $menu.data 'isOpen', true
    
  initSubmenu: ($menu, $submenu) ->
    $button   = menuModel.getSubmenuButton $submenu
    $back     = menuModel.getSubmenuBackButton $submenu
    $items    = menuModel.getSubmenuItems $submenu
    
    # Capture native dimensions
    $submenu.data 'nativeHeight', $submenu.height()
    $submenu.data 'nativeWidth',  $submenu.width()
    $items.each ->
      $(@).data 'nativeHeight', $(@).height()
      $(@).data 'nativeWidth',  $(@).width()
    
    # Close submenus on load
    $submenu.hide()
#     menuView.closeSubmenu $menu, $submenu
    
    # Bind event to submenu open button
    $button.on 'touchend mouseup', (event) ->
      event.stopPropagation()
      menuView.openSubmenu $menu, $submenu
      
    # Bind back button
    $back.on 'touchend mouseup', (event) ->
      event.stopPropagation()
      menuView.closeSubmenu $menu, $submenu
      
