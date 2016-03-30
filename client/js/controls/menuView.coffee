window.menuView =
  init: ($menu) ->
    $list = menuModel.getList $menu
    
    # Right align menu if off-screen to right
    flush = if $list.width() + $list.offset().left > $(window).width() then 'right' else 'left'
    $list.css flush, 0
    $menu.data 'flush', flush
    
  close: ($menu) ->
    $button = menuModel.getButton $menu
    $list =   menuModel.getList $menu
    $items =  menuModel.getListItems $menu
    $items.each ->
      menuView.slideOutItem $menu, $(@), true, -> $list.css({opacity: 0})
      # Callback to hide menu mole

  open: ($menu) ->
    $button = menuModel.getButton $menu
    $list =   menuModel.getList $menu
    $items =  menuModel.getListItems $menu
    # Unhide list
    $list.css
      opacity: 1
    # Set direction from which items animate in
    $items.hide().each ->
      menuView.slideInItem $menu, $(@), true
    $list.show()

  slideInItem: ($menu, $item, isDelay) ->
    $list = menuModel.getList $menu
    $items = $item.siblings('li').add($item)
    translateXFrom = if $menu.data('flush') is 'left' then -$menu.width() * 2 else $menu.width() * 2
    $item.velocity 
      properties:
        height: [$item.data('nativeHeight'), 0]
        width: [$item.data('nativeWidth'), 0]
        translateX: [0, translateXFrom]
        opacity: 1
      options:
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
        delay: if isDelay then $item.index() * (250 /  $items.length) else 0
        begin: ->
          $item.css
            height: 0
          $item.show()
  
  slideOutItem: ($menu, $item, isDelay, callback) ->
    $list = menuModel.getList $menu
    $items = $item.siblings('li').add($item)
    translateXTo = if $menu.data('flush') is 'left' then   -$menu.width() * 2 else $menu.width() * 2
    $item.velocity('stop', true).velocity 
      properties:
        height: 0
        width: 0
        opacity: 0
        translateX: translateXTo
      options:
        delay: if isDelay then ($items.length - $item.index()) * (250 /  $items.length) else 0
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
        complete: ->
          if $item.index() is $items.length - 1 # is last item
            callback()
    
  closeSubmenu: ($menu, $submenu) ->
    $list = menuModel.getList $menu
    $listItems = menuModel.getListItems $menu
    $parentListItem = $submenu.parents 'li'
    $otherListItems = $listItems.not $parentListItem
    $submenuItems = menuModel.getSubmenuItems $submenu
    # Hide and collapse submenu container
    $submenu.velocity
      properties:
        height: 0
        width: 0
      options:
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
        complete: -> $submenu.hide()
    # Animate in other list items
    $otherListItems.each -> menuView.slideInItem $menu, $(@), true
    # Animate out submenu items
    $submenuItems.each -> menuView.slideOutItem $menu, $(@), true
    $list.css
      width: 'auto'
    $parentListItem.css
      height: ''
      width: ''
    
  openSubmenu: ($menu, $submenu) ->
    $list = menuModel.getList $menu
    $listItems = menuModel.getListItems $menu
    $parentListItem = $submenu.parents 'li'
    $otherListItems = $listItems.not $parentListItem
    $submenuItems = menuModel.getSubmenuItems $submenu
    # Show and expand submenu container
    $submenu.velocity
      properties:
        height: [$submenu.data('nativeHeight'), 0]
        width:  [$submenu.data('nativeWidth'),  0]
      options:
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
        begin: -> $submenu.show()
    # Animate out other list items
    $otherListItems.each -> menuView.slideOutItem $menu, $(@), true
    # Animate in submenu items
    $submenuItems.each -> menuView.slideInItem $menu, $(@), true
    $parentListItem.css
      height: 'auto'
      width: ''
