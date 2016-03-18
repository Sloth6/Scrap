window.menuModel =
  getList: ($menu) ->
    $menu.children('ul.menuItems')
    
  getButton: ($menu) ->
    $menu.children('input.menuOpenButton')
    
window.menuController =
  init: ($menu) ->
    $button = menuModel.getButton $menu
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
    $list = menuModel.getList $menu
    $list.hide()
    $menu.data 'isOpen', false
    
  open: ($menu) ->
    $list = menuModel.getList $menu
    $list.show()
    $menu.data 'isOpen', true
