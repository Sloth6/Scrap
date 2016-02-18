window.collectionsMenuView =
	open: () ->
    $menu         = $(constants.dom.collectionsMenu)
    $container    = $(constants.dom.articleContainer)
    $menuItems    = $menu.children()
    $button       = $menuItems.filter('.openMenuButton')
    $labelsButton = $menuItems.filter('li.labelsButton')
    $labels       = $menuItems.not('li.labelsButton')
    $openLabel    = $menuItems.filter("li.#{window.openCollection}")
    isHome        = window.openCollection is 'recent'
    options       =
      duration: 1000
      easing:   constants.velocity.easing.smooth
      
    $menuItems.show()
#     $menu.addClass 'open'
#     # animate in labels
#     $labels.not($openLabel).find('.contents').css
#       opacity: 0
#     $menuItems.show()
#     console.log 'OPEN MENU'
#     $.Velocity.hook($openLabel.find('.contents'), 'translateY', "#{-$openLabel.offset().top}px")
#     $menu.css
#       width: $menu.width()
#     if isHome
#       $labelsButton.find('.contents').velocity
#         properties:
#           translateY: -$button.height() * 3
#           scaleY: 2
#           scaleX: .125
#           rotateZ: 45 * (Math.random() - .5)
#         options:
#           duration: options.duration
#           easing:   options.easing
#           delay:    0
#     $openLabel.removeClass('openMenuButton')
#     $labels.each ->
#       $label = $(@)
#       if $openLabel.index() is $label.index()
#         translateY = -500
#       else if $openLabel.index() < $label.index() # below
#         translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
#       else
#         translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
#       scaleY = if $openLabel.index() is $label.index() then 1 else 2
#       scaleX = if $openLabel.index() is $label.index() then 1 else .125
#       rotateZ = if $openLabel.index() is $label.index() then 1 else 22 * (Math.random() - .5)
#       $label.find('.contents').velocity
#         properties:
#           translateY: [-$button.height(), translateY]
#           scaleY: [1, scaleY]
#           scaleX: [1, scaleX]
#           rotateZ: [0, rotateZ]
#           opacity: [1, 1]
#         options:
#           duration: options.duration # + ($label.index() * 60)
#           easing:   options.easing
#           delay:    $label.index() * 60
#           begin: ->
#             $label.css
#               position: ''
#               top: ''
#           complete: ->
#             $menu.data 'canOpen', false
#     articleView.obscure $container.find('article')
#     extendNav()

  close: () ->
    isHome        = window.openCollection is 'recent'
    $menu         = $(constants.dom.collectionsMenu)
    $container    = $(constants.dom.articleContainer)
    $menuItems    = $menu.children()
    $button       = $menuItems.filter('.openMenuButton')
    $labelsButton = $menuItems.filter('li.labelsButton')
    $labels       = $menuItems.not('li.labelsButton')
    $openLabel    = if isHome then $labelsButton else $menuItems.filter("li.#{window.openCollection}") 
    options       =
      duration: 1000
      easing:   constants.velocity.easing.smooth
      
    $menuItems.not($openLabel).hide()
    
#     isHome      = window.openCollection is 'recent'
#     $menu       = $(constants.dom.collectionsMenu )
#     $container  = $(constants.dom.articleContainer)
#     $menuItems  = $menu.children()
#     $oldButton     = $menu.find('.openMenuButton')
#     $labelsButton = $menu.find('li.labelsButton')
#     $dragging   = $menu.find 'ui-draggable-dragging'
#     $labels     = $menuItems.not('.ui-draggable-dragging, .openMenuButton')
#     $articleContents = $container.find('article .card').children().add($container.find('article ul, article .articleControls'))
#     $destinationLabel  = if isHome then $labelsButton else $menu.children(".#{window.openCollection}")
#     options     =
#       duration: 500
#       easing:   constants.velocity.easing.smooth

#     $menu.removeClass 'open'
# 
#     if isHome
#       $labelsButton.find('.content').velocity 'reverse', {
#         delay: 60 * $labels.length
#       }
#     else
#       $oldButton.removeClass('openMenuButton')
#     $destinationLabel.addClass('openMenuButton')
#     $destinationLabel.find('.contents').velocity
#       properties:
#         translateY: -$destinationLabel.offset().top
#         rotateZ: 0
#         scaleY: 1
#         scaleX: 1
#       options:
#         duration: options.duration
#         easing:   options.easing
#     $destinationLabel.find('span').trigger('mouseleave')
#     $labels.not($destinationLabel).each ->
#       $label = $(@)
#       if $destinationLabel.index() < $label.index() # below
#         translateY = $(window).height() - ($label.offset().top - $label.height() * 2)
#       else
#         translateY = -$(window).height() #- ($label.offset().top - $label.height() * 2)
#       $label.find('.contents').velocity
#         properties:
#           translateY: translateY
#           scaleY: 2
#           scaleX: .125
#           rotateZ: 22 * (Math.random() - .5)
#         options:
#           duration: options.duration
#           easing:   options.easing
#           delay:    0 #60 * (($labels.length ) - $label.index())
#           complete: ->
#             if $label.index() is $labels.length - 1
#               $menuItems.not('.openMenuButton, .ui-draggable-dragging').hide()
#               $.Velocity.hook($destinationLabel.find('.contents'), 'translateY', 0)
#               $menu.data 'canOpen', true
#               # if window.triedToOpen and $menu.is(':hover') # if user tried to open menu before ready, and is still hovering
#               #   events.onOpenCollectionsMenu() # open menu after close animation finishes
#               #   window.triedToOpen = false
#     articleView.unobscure $container.find('article')
#     extendNav()
