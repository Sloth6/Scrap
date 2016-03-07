liClick = (event) ->
  if $(@).parents('li').hasClass 'openMenuButton'
    collectionsMenuView.open()
  event.stopPropagation()
  event.preventDefault()

window.collectionsMenuController =
  init: ($menu) ->
    $menuItems    = $menu.children()
    $menuItems.find('a').click liClick
    parallaxHover $menuItems.find('.contents > a'), 250, 1.25

    $(constants.dom.collections).each ->
      $(@).data 'offsetTop', $(@).offset().top

    $menu.find('li.newCollection input').click (event) ->
      $(@).attr 'placeholder', ''
      $(@).siblings('label').removeClass 'invisible'
      
    $menu.find('input, a').click ->
      event.stopPropagation()
    
    $menuItems.not('.openMenuButton, .openCollection').hide()
    
    $menu.find('li.searchCollections input').focus ->
      collectionsMenuView.searchFocus  $(@)
    $menu.find('li.searchCollections input').change ->
      collectionsMenuView.searchChange $(@)
      console.log 'search input change'
          
  add: (name, collectionKey, color) ->
    $menu = $(constants.dom.collectionsMenu)
    # Copy existing DOM, making it less fragile if dom changes.
    $label = $menu.find('.recent').clone()
    $label.data('collectionkey', collectionKey)
    $label.find('a').
      click(liClick).
      text(name).
      css { color }

    $label.insertBefore $menu.children().last()
    collectionController.init $label
    parallaxHover $label.find('.contents > a'), 250, 1.25

    $newLabelButton = $menu.find('li.newCollection input')
    $newLabelButton.attr 'placeholder', 'New label'
    $newLabelButton.siblings('label').addClass 'invisible'
  

