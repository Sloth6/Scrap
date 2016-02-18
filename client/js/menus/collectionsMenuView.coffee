
window.collectionsMenuView =
	open: () ->
    isHome        = window.openCollection is 'recent'
    $menu         = $(constants.dom.collectionsMenu)
    $container    = $(constants.dom.articleContainer)
    $menuItems    = $menu.children()
    $button       = $menuItems.filter('.openMenuButton')
    $labelsButton = $menuItems.filter('li.labelsButton')
    $labels       = $menuItems.not('li.labelsButton')
    $openLabel    = $menuItems.filter("li.#{window.openCollection}")
    options       =
      duration: 1000
      easing:   constants.velocity.easing.smooth
      
    $menuItems.show()
    
    # Animate in labels
    $labels.each ->
      $label = $(@)
      $contents = $label.find('.contents')
      $contents.css 'opacity', 0 # Hide to prevent flash before animating in
      if $label.is $openLabel
        translateY = if $label.is('.recents') then -500 else -$label.offset().top
        unparallax $openLabel.find('.transform'), options.duration, options.easing
      else if $openLabel.index() < $label.index() # below
        translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
      else
        translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
      $contents.not($labelsButton).velocity
        properties:
          translateY: [-$labelsButton.height(), translateY]
          opacity: [1, 1]
        options:
          duration: options.duration # + ($label.index() * 60)
          easing:   options.easing
          delay:    $label.index() * 60    
    # Animate up labels button
    $labelsButton.velocity
      properties:
        translateY: -$labelsButton.height()
      options:
        duration: options.duration # + ($label.index() * 60)
        easing:   options.easing

    articleView.obscure $container.find('article')
    extendNav()

  close: () ->
    isHome        = window.openCollection is 'recent'
    $menu         = $(constants.dom.collectionsMenu)
    $container    = $(constants.dom.articleContainer)
    $menuItems    = $menu.children()
    $button       = $menuItems.filter('.openMenuButton')
    $labelsButton = $menuItems.filter('li.labelsButton')
    $labels       = $menuItems.not('li.labelsButton')
    $openLabel    = if isHome then $labelsButton else $menuItems.filter("li.#{window.openCollection}") 
    $destinationLabel  = if isHome then $labelsButton else $menu.children(".#{window.openCollection}")
    options       =
      duration: 750
      easing:   constants.velocity.easing.smooth
      
    $button.removeClass        'openMenuButton'
    $destinationLabel.addClass 'openMenuButton'

    $menuItems.each ->
      $label = $(@)
      $contents = $label.find('.contents')
      if $label.is $destinationLabel
        translateY = -$destinationLabel.offset().top
        delay = 0
      else if $destinationLabel.index() < $label.index() # below
        translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
        delay = $destinationLabel.index() - $label.index()
      else
        translateY = -$(window).height()
        delay = $label.index() - $destinationLabel.index()
      $contents.velocity
        properties:
          translateY: translateY
        options:
          duration: options.duration + 250 * Math.abs delay
          easing:   options.easing
          delay:    0 # 400 * Math.abs delay 
          complete: ->
            if $label.index() is $labels.length - 1
#               $menuItems.not($destinationLabel).hide() 
              console.log 'done closing'
              
    unparallax $destinationLabel.find('.transform'), options.duration, options.easing
    articleView.unobscure $container.find('article')
    extendNav()
    
