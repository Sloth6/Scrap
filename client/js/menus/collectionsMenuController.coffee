liClick = ($li, event) ->
  if $li.hasClass 'openMenuButton'
#     console.log 'liclick', $li.text(), $li.attr 'class'
    scrapState.waitToOpenCollectionsMenu = true
    collectionsMenuView.open()
  event.stopPropagation()
  event.preventDefault()

window.collectionsMenuController =
  init: ($menu) ->
    $lis    = $menu.children()

    parallaxHover $lis.find('.contents > a'), 250, 1.25

    $(constants.dom.collections).each ->
      $(@).data 'offsetTop', $(@).offset().top
      
    $lis.each ->
      $lis.find('.contents > a').on 'touchend mouseup', => liClick $(@), event

    $menu.find('li.newCollection input').click (event) ->
      $(@).attr 'placeholder', ''
      $(@).siblings('label').removeClass 'invisible'
      
    $menu.find('input, a').click -> event.stopPropagation()
    $lis.not('.openMenuButton, .openCollection').hide()

    $menu.find('li.searchCollections input').focus ->
      collectionsMenuView.searchFocus  $(@)

    $menu.find('li.searchCollections input').on 'input', () ->
      collectionsMenuView.searchChange $menu, $(@)

  add: (name, collectionKey, color) ->
    $menu = $(constants.dom.collectionsMenu)
    # Copy existing DOM, making it less fragile if dom changes.
    $label = $menu.find('.recent').clone()
    $label.data('collectionkey', collectionKey)
    $label.find('.contents > as').
      click(=> liClick $label, event).
      text(name).
      css { color }

    $label.insertBefore $menu.children().last()
    collectionController.init $label
    parallaxHover $label.find('.contents > a'), 250, 1.25

    $newLabelButton = $menu.find('li.newCollection input')
    $newLabelButton.attr 'placeholder', 'New label'
    $newLabelButton.siblings('label').addClass 'invisible'


