window.collectionsMenuController =
  init: ($menu) ->
    $lis = $menu.children()
    $newForm    = $menu.find('.newCollectionForm')
    $searchForm = $menu.find('.searchCollectionsForm')

    $menu.find('input, a').click (event) ->
      event.stopPropagation()

    $lis.not('.openMenuButton, .openCollection').hide()

    # Binding for search.
    $menu.find('li.searchCollections input').focus ->
      collectionsMenuView.searchFocus $(@)

    $menu.find('li.searchCollections input').on 'input', () ->
      collectionsMenuView.searchChange $menu, $(@)

    # Bindings for creating new collections.
    $newForm.find('input[type=text]').on 'input', () ->
      console.log 'input'
      $(@).siblings('label').removeClass 'invisible'

    $newForm.submit (event) ->
      name = $.trim($(@).find('input').val())
      # Dont take empty names or a name of only whitespace.
      if name != ''
        $(@).find('input').val('').blur()
        console.log 'emitting new collection', name
        socket.emit 'addCollection', { name }
        event.preventDefault()

  open: ($menu, $li, event) ->
    if $li.hasClass 'openMenuButton'
      console.log 'open called. Li has classes:', $li.attr 'class'
      collectionsMenuView.open(event)

  add: (name, collectionKey, color) ->
    $menu = $(constants.dom.collectionsMenu)

    # Copy existing DOM, making it less fragile if dom changes.
    # Todo. emit html from sever
    $label = $menu.find('.collection').not('.recent').first().clone()
    $label.removeClass()# $label.data('collectionkey')
    $label.addClass 'collection'
    $label.data('collectionkey', collectionKey)
    $label.addClass collectionKey

    console.log 'Label has clases', $label.attr('class')
    console.log 'Label has key', $label.data('collectionkey')

    $label.find('.contents > a').
      text(name).
      css { color }

    $label.insertBefore $menu.children().last()

    collectionController.init $label
    # console.log 'the new label', $label.attr('class'), $label
#
