window.navigationController =
  open: ($collection) ->
    throw 'no collection passed' unless $collection?
    collectionState = collectionModel.getState $collection
    collectionKey        = collectionState.collectionKey


    #If leaving root collection, animate out back button
    if collectionModel.getParent($collection)?.hasClass('root')
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
    # update the url
    history.pushState newState, "", "/s/#{collectionKey}"

    collectionModel.loadContent $collection, () ->
      collectionViewController.open $collection 
      collectionViewController.draw $collection 
      size = contentModel.getSize($collection)
      console.log size
      $(document.body).css { width: size }

  # close the open collection and return the view to where it was 
  # when it was opened. which is stored in the state object
  close: ($collection, state) ->
    throw 'cannot close root' if $('.root.collection.open').length
    
    collectionPath.shift()
    $parentCollection         = collectionModel.getParent   $collection
    collectionViewController.close $collection

    # If entering root collection, animate out back button
    if collectionModel.getParent($collection).hasClass 'root'
      $('header.main .backButton.main').velocity { translateX: 0 }

    # return to the parents state last time we were there.
    $(document.body).css width: state.width
    $(window).scrollLeft state.scrollLeft
    $("body").css "overflow", "hidden"
    
    setTimeout (() ->
      $("body").css("overflow", "visible")
    ), openCollectionDuration
    collectionViewController.draw $parentCollection, {animate: true }

  goToStart: ($collection) ->
    $(window).scrollLeft 0
    collectionViewController.draw $collection, { animate: true }

  goToEnd: ($collection) ->
    $(window).scrollLeft 999999
    collectionViewController.draw $collection, { animate: true }