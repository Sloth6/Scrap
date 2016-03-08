window.collectionsMenuView =
  open: () ->
    if scrapState.waitToOpenCollectionsMenu
      isHome        = window.openCollection is 'recent'
      yOffsetTop    = $(window).height() + $(window).scrollTop() # Top of page to bottom of window
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
      scrapState.collectionsMenuIsOpen = true
      scrapState.waitToOpenCollectionsMenu = false
      console.log 'OPEN'
      $menuItems.show()
      # Animate in labels
      $labels.each ->
        $label = $(@)
        $contents = $label.find('.contents')
        $contents.css 'opacity', 0 # Hide to prevent flash before animating in
        toY = if $label.is $labelsButton then -$labelsButton.height() else -$labelsButton.height()
        if $label.is $openLabel
          fromY = if $label.is('.recent') then yOffsetTop else -$label.offset().top
          unparallax $openLabel.find('.transform'), options.duration, options.easing
        else if $openLabel.index() < $label.index() # Below
          fromY = yOffsetTop - ($label.offset().top - $label.height() * 2)
        else # Above
          fromY = -$(window).height()
        $contents.not($labelsButton).velocity('stop', true).velocity
          properties:
            translateY: [toY, fromY]
            opacity: [1, 1]
  #           scaleY: [1, 2]
  #           scaleX: [1, 0]
            rotateZ: [0, 0]
          options:
            duration: options.duration # + ($label.index() * 60)
            easing:   options.easing
            delay:    $label.index() * 60
      # Animate up labels button
      $labelsButton.find('.contents').velocity('stop', true).velocity
        properties:
          translateY: -$labelsButton.height()
        options:
          duration: options.duration # + ($label.index() * 60)
          easing:   options.easing
          complete: ->
            $labelsButton.css 'opacity', 0
            scrapState.waitToOpenCollectionsMenu = false
#             collectionController.updateHeight $collection
      unparallax $labelsButton.find('.transform'), options.duration, options.easing
      articleView.obscure $container.find('article')
      extendNav()
      # Animate other header buttons away
      $('nav section.left .headerButton, nav section.right .headerButton').each ->
        $(@).velocity('stop', true).velocity
          properties:
            translateY: -$(@).height()
          options:
            duration: options.duration
            easing:   options.easing
      # Disable scroll
      $('body').css
        overflow: 'hidden'
      # Enable scrolls
      $menu.css
        overflowY: 'scroll'
      # Focus search
      $menu.find('li.searchCollections input').val('').focus()

      # Scroll to open label
      $openLabel.velocity('stop', true).velocity 'scroll', {
        container: $menu
        duration: options.duration
        easing: options.easing
        offset: -$openLabel.height()
      }

  close: () ->
    isHome        = window.openCollection is 'recent'
    yOffsetTop    = $(window).height() + $(window).scrollTop() # Top of page to bottom of window
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
    scrapState.collectionsMenuIsOpen = false
    scrapState.waitToOpenCollectionsMenu = false
    $button.removeClass        'openMenuButton'
    console.log 'CLOSE'
    $menuItems.each ->
      $label = $(@)
      $contents = $label.find('.contents')
      if $label.is $destinationLabel
        translateY = -$destinationLabel.offset().top
        delay = 0
        rotateZ = 0
      else if $destinationLabel.index() < $label.index() # below
        translateY = yOffsetTop - ($label.offset().top - $label.height() * 4)
        delay = $destinationLabel.index() - $label.index()
        rotateZ = 45 * (Math.random() - .5)
      else
        translateY = -$(window).height()
        delay = $label.index() - $destinationLabel.index()
        rotateZ = 45 * (Math.random() - .5)
      $contents.velocity('stop', true).velocity
        properties:
          translateY: translateY
          rotateZ: rotateZ
        options:
          duration: options.duration + 250 * Math.abs delay
          easing:   options.easing
          delay:    0 # 400 * Math.abs delay
          begin:    -> $label.css 'opacity', 1
          complete: ->
            if $label.index() is $labels.length - 1
              translateY = if isHome then 0 else -$labelsButton.height()
              $.Velocity.hook $destinationLabel.find('.contents'), 'translateY', "#{translateY}px"
              $labels.not('.openMenuButton').hide()
    unparallax $menuItems.find('.transform'), options.duration, options.easing
    articleView.unobscure $container.find('article')
    extendNav()
    # Animate other header buttons back in
    $('nav section.left .headerButton, nav section.right .headerButton').each ->
      $(@).velocity('stop', true).velocity
        properties:
          translateY: 0
        options:
          duration: options.duration
          easing:   options.easing
    # Enable scroll
    $('body').css
      overflow: ''
    $menu.css
      overflowY: 'visible'
    $menuItems.eq(0).velocity('stop', true).velocity 'scroll', {
      container: $menu
      duration: options.duration
      easing: options.easing
    }

    $labels.each ->
      # Hide settings menu on labels
      collectionView.hideSettings $(@)
    setTimeout ->
      $destinationLabel.addClass 'openMenuButton'
    , 1000


  searchFocus: ($input) ->
    return

  searchChange: ($menu, $input) ->
    $labels = $menu.find('li.collection').not('.recent')
    $recent = $menu.find('li.collection.recent')
    $newLabelInput = $menu.find('li.newCollection')
    search = $input.val().toLowerCase()

    if search.length == 0
      collectionView.show $recent.add($newLabelInput)
      collectionView.show $labels
    else
      collectionView.hide $recent.add($newLabelInput)
      $labels.each () ->
        key = $(@).data 'collectionkey'
        name = window.collections[key].name.toLowerCase()
        if name.indexOf(search) == -1
          collectionView.hide $(@)
        else
          collectionView.show $(@)
