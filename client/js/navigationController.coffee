window.navigationController =
  open: ($collection) ->
    collectionState    = collectionModel.getState $collection
    collectionKey      = collectionState.collectionKey
    $collectionContent = collectionModel.getContent $collection
    $backButton = $('header.main .backButton.main')

    # Cant open
    if $collection.hasClass('velocity-animating')
      console.log 'too soon to open!'
      return

    #If leaving root collection, animate out back button
    if collectionModel.getParent($collection)?
      $parentCollection        = collectionModel.getParent($collection)
      $parentCollectionContent = collectionModel.getContent($parentCollection)
      
      if $parentCollection.hasClass('root')
        $backButton.velocity {
          translateX: 32
        }, {
          easing: openCollectionCurve
          duration: openCollectionDuration
        }

    collectionPath.unshift collectionKey

    # update the state object for this view so we can return to where we left
    # console.log 
    history.replaceState {
      scrollLeft : $(window).scrollLeft()
      width : $(window.document).width()
      name: ''#history.state.name
    }, ""

    # The object that will hold the state of the opening collection
    newState = { name: collectionKey }
    
    #Begin on the left side 
    $(window).scrollLeft(0)

    # Update the url.
    path = if $collection.hasClass('root') then '/' else "/s/#{collectionKey}"
    history.pushState newState, "", path#"/s/#{collectionKey}"

    onContentLoaded = () ->
      $collectionContent = collectionModel.getContent $collection
      # Initialize new content to make it interactive
      $collectionContent.each () -> contentModel.init $(@)
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
    $backButton = $('header.main .backButton.main')

    if $collection.hasClass('velocity-animating')
      console.log 'too soon to close!'
      return

    $parentCollection  = collectionModel.getParent  $collection
    $collectionContent = collectionModel.getContent $collection

    collectionViewController.close $collection
    collectionPath.shift()

    # Remove event handlers so stack elements are not interactive
    $collectionContent.off()
    collectionModel.init $collection

    # If entering root collection, animate out back button
    if $parentCollection.hasClass 'root'
      $backButton.velocity {
        translateX: 0
      }, {
        easing: openCollectionCurve
        duration: openCollectionDuration
      }

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