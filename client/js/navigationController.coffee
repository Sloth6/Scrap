window.navigationController =
  open: ($collection) ->
    collectionState    = collectionModel.getState $collection
    collectionKey      = collectionState.collectionKey
    $collectionContent = collectionModel.getContent $collection

    #If leaving root collection, animate out back button
    if collectionModel.getParent($collection)?
      $parentCollection        = collectionModel.getParent($collection)
      $parentCollectionContent = collectionModel.getContent($parentCollection)
      
      if $parentCollection.hasClass('root')
        $('header.main .backButton.main').velocity { translateX: 32 }


    collectionPath.unshift collectionKey

    # update the state object for this view so we can return to where we left
    history.replaceState {
      scrollLeft : $(window).scrollLeft()
      width : $(window.document).width()
      name: history.state.name
    }, ""

    # The object that will hold the state of the opening collection
    newState = { name: collectionKey }
    # Update the url.
    history.pushState newState, "", "/s/#{collectionKey}"

    onContentLoaded = () ->
      # Initialize new content to make it interactive
      collectionModel.getContent($collection).each () -> contentModel.init $(@)
      $addForm = collectionModel.getAddForm($collection)
      switch $addForm.data('contenttype')
        when 'addArticleForm' then addArticleController.init $addForm
        when 'addProjectForm' then addProjectController.init $addForm
  
      collectionViewController.open $collection

    if $collectionContent.length
      onContentLoaded()
    else
      collectionModel.loadContent $collection, () ->
        onContentLoaded()

  # close the open collection and return the view to where it was 
  # when it was opened. which is stored in the state object
  close: ($collection, state) ->
    return if $collection.hasClass('root')
    $parentCollection  = collectionModel.getParent  $collection
    $collectionContent = collectionModel.getContent $collection

    $collectionContent.off()

    collectionViewController.close $collection
    collectionPath.shift()

    # If entering root collection, animate out back button
    if $parentCollection.hasClass 'root'
      $('header.main .backButton.main').velocity { translateX: 0 }

    # return to the parents state last time we were there.
    $(document.body).css width: state.width
    $(window).scrollLeft state.scrollLeft
    $("body").css "overflow", "hidden"
    
    setTimeout (() ->
      $("body").css("overflow", "visible")
    ), openCollectionDuration
    collectionViewController.draw $parentCollection, { animate: true }

  goToStart: ($collection) ->
    $(window).scrollLeft 0
    collectionViewController.draw $collection, { animate: true }

  goToEnd: ($collection) ->
    $(window).scrollLeft 999999
    collectionViewController.draw $collection, { animate: true }