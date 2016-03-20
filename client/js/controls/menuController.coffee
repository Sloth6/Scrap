window.menuModel =
  animation:
    easing: [30, 10] #constants.velocity.easing.smooth
    duration: 1000

  getList: ($menu) ->
    $menu.children('ul.menuItems')
    
  getButton: ($menu) ->
    $menu.children('input.menuOpenButton')
    
  getListItems: ($menu) ->
    $list = menuModel.getList $menu
    $list.children('li')
    
  getSubmenus: ($menu) ->
    $menu.find('ul.submenu')
    
  getSubmenuButton: ($menu) ->
    $menu.find('input.submenuOpenButton')
    
window.menuController =
  init: ($menus) ->
    $menus.each ->
      $menu = $(@)
      $button = menuModel.getButton $menu
      $list = menuModel.getList $menu
      $items = menuModel.getListItems $menu
      $submenus = menuModel.getSubmenus $menu
      
      menuController.closeSubmenu $submenus
      menuController.initSubmenuButtons $menu

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
    
  open: ($menu) ->
    menuView.open $menu
    $menu.data 'isOpen', true
    
  initSubmenuButtons: ($menu) ->
    $button = menuModel.getSubmenuButton $menu
    $submenus = menuModel.getSubmenus $menu
    $button.on 'touchend mouseup', (event) ->
      event.preventDefault()
      event.stopPropagation()
      console.log 'hello'
      submenuId = $button.data 'submenu'
      console.log $submenus.data('submenu'), 'YOYOYo'
      $submenu = $submenus.filter("[data-submenu='#{submenuId}']")
      menuController.openSubmenu $submenu
      
  closeSubmenu: ($submenu) ->
    $submenu.hide()

  openSubmenu: ($submenu) ->
    console.log $submenu.data('submenu'), 'OPEN'
    $submenu.show()
