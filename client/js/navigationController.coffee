window.navigationController =
  open: ($collection) ->
    collectionState    = collectionModel.getState $collection
    collectionKey      = collectionState.collectionKey
    $collectionContent = collectionModel.getContent $collection
    $backButton        = $('header.main .backButton.main')

    return if $collection.hasClass('velocity-animating')
    
    onContentLoaded = () ->
      $collectionContent = collectionModel.getContent $collection
      # Initialize new content to make it interactive
      $collectionContent.each () -> contentModel.init $(@)
      $addForm = collectionModel.getAddForm($collection)
      switch $addForm.data('contenttype')
        when 'addArticleForm' then addArticleController.init $addForm
        when 'addProjectForm' then addProjectController.init $addForm
  
      #If leaving root collection, animate out back button
      if collectionModel.getParent($collection)?
        $parentCollection = collectionModel.getParent $collection
        if $parentCollection.hasClass 'root'
          $backButton.velocity { translateX: 32 }

      collectionPath.unshift collectionKey

      # Update the state object for this view so we can return to where we left
      history.replaceState {
        scrollLeft : $(window).scrollLeft()
        width : $(window.document).width()
        name: ""
      }, ""

      #Begin on the left side 
      $(window).scrollLeft 0

      # Update the url.
      path = if $collection.hasClass('root') then '/' else "/s/#{collectionKey}"
      # The object that will hold the state of the opening collection
      newState = { name: collectionKey }
      history.pushState newState, "", path#"/s/#{collectionKey}"

      collectionViewController.open $collection
      size = contentModel.getSize $collection
      $(document.body).css { width: size }

    if $collectionContent.length
      onContentLoaded()
    else
      collectionModel.loadContent $collection, () -> onContentLoaded()

  # close the open collection and return the view to where it was 
  # when it was opened. which is stored in the state object
  close: ($collection, state) ->
    $backButton = $('header.main .backButton.main')
    $parentCollection  = collectionModel.getParent  $collection
    $collectionContent = collectionModel.getContent $collection

    return if $collection.hasClass('root')
    return if $collection.hasClass('velocity-animating')

    # Remove event handlers so stack elements are not interactive
    $collectionContent.off()

    # calling init on a closed stack will cause it to lose the bindings it
    # had while open. This prevents interacting with elements while closed 
    if $collection.data('contenttype') == 'stack'
      collectionModel.init $collection

    # Return to the parents state last time we were there.
    $("body").css "overflow", "hidden"
    $(document.body).css width: state.width
    $(window).scrollLeft state.scrollLeft

    collectionPath.shift()

    setTimeout (() ->
      $(document.body).css 'overflow', 'visible'
    ), openCollectionDuration

    # If entering root collection, animate out back button
    if $parentCollection.hasClass 'root'
      $backButton.velocity { translateX: 0 }

    collectionViewController.close $collection
    collectionViewController.draw $parentCollection, { animate: true }
    
  goToStart: ($collection) ->
    $(window).scrollLeft 0
    collectionViewController.draw $collection, { animate: true }

  goToEnd: ($collection) ->
    $(window).scrollLeft 999999
    collectionViewController.draw $collection, { animate: true }