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
    
window.menuController =
  init: ($menus) ->
    $menus.each ->
      $menu = $(@)
      $button = menuModel.getButton $menu
      $list = menuModel.getList $menu
      $items = menuModel.getListItems $menu

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
