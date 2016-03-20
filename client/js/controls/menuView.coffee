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
      menuView.slideOutItem $menu, $(@), ($items.length - $(@).index()) * (250 /  $items.length)
    $list.velocity('stop', true).velocity
      properties:
        width: 0
      options:
        delay: menuModel.animation.delay / 2
        duration: menuModel.animation.duration / 2
        easing: menuModel.animation.easing
        complete: ->
          $list.hide().css
            width: ''    

  open: ($menu) ->
    $button = menuModel.getButton $menu
    $list =   menuModel.getList $menu
    $items =  menuModel.getListItems $menu
    # Set direction from which items animate in
    $items.hide().each ->
      menuView.slideInItem $menu, $(@), $(@).index() * (250 /  $items.length)
    $list.velocity('stop', true).velocity
      properties:
        width: [$list.data('nativeWidth'), 0]
      options:
        duration: menuModel.animation.duration / 2
        easing: menuModel.animation.easing
        begin: -> $list.show()

  slideInItem: ($menu, $item, delay) ->
    $list = menuModel.getList $menu
    translateXFrom = if $menu.data('flush') is 'left' then -$list.data('nativeWidth') else $list.data('nativeWidth')
    $item.velocity 
      properties:
        height: [$item.data('nativeHeight'), 0]
        translateX: [0, translateXFrom]
      options:
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
        delay: delay
        begin: ->
          $item.css
            height: 0
          $item.show()
  
  slideOutItem: ($menu, $item, delay) ->
    $list = menuModel.getList $menu
    translateXTo = if $menu.data('flush') is 'left' then -$list.data('nativeWidth') else $list.data('nativeWidth')
    $item.velocity('stop', true).velocity 
      properties:
        height: 0
        translateX: translateXTo
      options:
        duration: menuModel.animation.duration
        easing: menuModel.animation.easing
    
  