
loadElements = (spacekey, callback) ->
  return callback 'ERR. spacekey not passed to loadElements' unless spacekey  
  $.get "/collectionContent/#{spacekey}", (data) ->
    callback $(data)

window.collectionModel =
  init: ($collection) ->
    console.log $collection
    $cover   = collectionModel.getCover $collection
    spaceKey = collectionModel.getState($collection).spaceKey

    $collection.click (event) ->
      event.stopPropagation()
      return if $(@).hasClass 'dragging'
      return if $(@).hasClass 'open'
      navigationController.open $(@)

    if $collection.data('hascover')
      $collection.data 'contenttype', 'pack'
      packCoverInit $cover
    else
      $collection.data 'contenttype', 'stack'
      collectionViewController.draw $collection 

  removeContent: ($collection) ->
    $collection.children('.contentContainer').empty()

  # Return all state attributess
  # 
  # @param $collection [jquery array] 
  getState: ($collection) ->
    open    = $collection.hasClass('.open')
    size    = $collection.data('size')
    spaceKey = $collection.data('spacekey')
    return { open, size, spaceKey }

  # Return articles in a collection
  # 
  # @param $collection [jquery array] 
  getContent: ($collection) ->
    $contentContainer = $collection.children('.contentContainer')
    $contents         = $contentContainer.children()
    $contents

  # The collection and element to partion around
  getContentPartitioned: ($collection, $content) ->
    $contentsBefore = $([])
    $contentsAfter  = $([])
    $contents       = collectionModel.getContent($collection)
    x               = xTransform($content)

    $contents.each () ->
      if @ != $content[0]
        if xTransform($(@)) < x
          $contentsBefore = $contentsBefore.add $(@)
        else
          $contentsAfter = $contentsAfter.add $(@)

    { $contentsBefore, $contentsAfter }

  getContentAfter: ($collection, x) ->
    $contents = collectionModel.getContent $collection
    for i in [0...$contents.length]
      $content = $($contents[i])
      if xTransform($content) + contentModel.getSize($content)/2 > x
        return $content
    $()

  appendContent: ($collection, $content) ->
    $collection.children('.contentContainer').append $content
    # console.log $collection, $content
    # $contents = collectionModel.getContent $collection
    # console.log 'last', $contents.last()
    # $contents.append $content
    # $content.insertBefore $contents.last()

  getFinalContent: ($collection) ->
    $contents = collectionModel.getContent $collection
    $contents.last()

  # Return this collections cover
  # 
  # @param $collection [jquery array] 
  getCover: ($collection) ->
    $collection.children '.cover'

  getAddForm: ($collection) ->
    $contents = collectionModel.getContent $collection
    $contents.filter('.addElementForm')
    $collection.children('.addElementForm,.addProjectForm')

  loadContent: ($collection, callback) ->
    spaceKey = collectionModel.getState($collection).spaceKey
    $contentContainer = $collection.children('.contentContainer')
    # $contentContainer.empty()
    # A stack will already have content
    return callback() if $contentContainer.children().length
    $.get "/collectionContent/#{spaceKey}", (data) ->
      $contentContainer.append $(data)
      callback()

  # Return the parent collection
  # 
  # @param $collection [jquery array] 
  getParent: ($collection) ->
    if $collection.hasClass 'root'
      null
    else 
      $collection.parent().parent()
