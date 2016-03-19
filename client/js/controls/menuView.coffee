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
    itemsTranslateXTo = if $menu.data('flush') is 'left' then -$list.data('nativeWidth') else $list.data('nativeWidth')
    $items.each ->
      $(@).velocity('stop', true).velocity 
        properties:
          height: 0
          translateX: itemsTranslateXTo
        options:
          duration: menuModel.animation.duration
          easing: menuModel.animation.easing
#           delay: $(@).index() * (250 /  $items.length)
          delay: ($items.length - $(@).index()) * (250 /  $items.length)
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
    itemsTranslateXFrom = if $menu.data('flush') is 'left' then -$list.data('nativeWidth') else $list.data('nativeWidth')
    $items.hide().each ->
      $(@).velocity 
        properties:
          height: [$(@).data('nativeHeight'), 0]
          translateX: [0, itemsTranslateXFrom]
        options:
          duration: menuModel.animation.duration
          easing: menuModel.animation.easing
          delay: $(@).index() * (250 /  $items.length)
          begin: ->
            $(@).css
              height: 0
            $(@).show()
    $list.velocity('stop', true).velocity
      properties:
        width: [$list.data('nativeWidth'), 0]
      options:
        duration: menuModel.animation.duration / 2
        easing: menuModel.animation.easing
        begin: -> $list.show()
