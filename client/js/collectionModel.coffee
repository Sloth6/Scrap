loadArticles = (collectionkey, callback) ->
  return callback 'ERR. collectionkey not passed to loadArticles' unless collectionkey  
  $.get "/collectionContent/#{collectionkey}", (data) ->
    callback $(data)

window.collectionModel =
  init: ($collection) ->
    $cover            = collectionModel.getCover $collection
    $parentCollection = contentModel.getCollection $collection
    collectionKey     = collectionModel.getState($collection).collectionKey
    $content          = collectionModel.getContent $collection
    clickBlock        = (event) -> event.preventDefault()

    $collection.click (event) ->
      event.stopPropagation()
      return if $(@).hasClass 'dragging'
      return if $(@).hasClass 'open'
      navigationController.open $(@)

    if $collection.data('hascover')
      $collection.data 'contenttype', 'pack'
      $collection.addClass 'pack'
      packCoverInit $cover, collectionKey
    else
      $collection.data 'contenttype', 'stack'
      $collection.addClass 'stack'
      $content.on 'click mouseup', clickBlock
      $collection.data 'previewState', 'compact'
      $collection.mouseenter () ->
        unless $collection.hasClass 'dragging'
          $collection.data 'previewState', 'expanded'
          collectionViewController.draw $collection, { animate:true }
          collectionViewController.draw $parentCollection, { animate:true }
      $collection.mouseleave () -> 
        $collection.data 'previewState', 'compact'
        collectionViewController.draw $collection, { animate:true }
        collectionViewController.draw $parentCollection, { animate:true }
        
      collectionViewController.draw $collection

  removeContent: ($collection) ->
    $collection.children('.contentContainer').empty()

  # Return all state attributess
  # 
  # @param $collection [jquery array] 
  getState: ($collection) ->
    open    = $collection.hasClass('open')
    size    = $collection.data('size')
    collectionKey = "#{$collection.data('collectionkey')}"
    return { open, size, collectionKey }

  # Return articles in a collection
  # 
  # @param $collection [jquery array] 
  getContent: ($collection) ->
    $contentContainer = $collection.children('.contentContainer')
    $contentContainer.children()

  # The collection and article to partition around
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

  getContentAt: ($collection, x) ->
    $contents = collectionModel.getContent $collection
    $content = $()
    for i in [0...$contents.length]
      $content = $($contents[i])
      if xTransform($content) + contentModel.getSize($content) > x
        return $content
    $content

  appendContent: ($collection, $content) ->
    $collection.children('.contentContainer').append $content

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
    $contents.filter('.addArticleForm')
    $collection.children('.addArticleForm,.addProjectForm')

  loadContent: ($collection, callback) ->
    collectionKey = collectionModel.getState($collection).collectionKey
    $contentContainer = $collection.children('.contentContainer')
    
    # A stack will already have content
    $.get "/collectionContent/#{collectionKey}", (data) ->
      $contentContainer.empty()
      $contentContainer.append $(data)
      callback()

  getContentOrder: ($collection) ->
    $content = collectionModel.getContent $collection
    # return $content.get()
    $content.get().map (content) ->
      $content = $(content)
      if $content.hasClass('collection')
        collectionModel.getState($content).collectionKey
      else
        $content.attr('id')

  # Return the parent collection
  # 
  # @param $collection [jquery array] 
  getParent: ($collection) ->
    if $collection.hasClass 'root'
      null
    else 
      $collection.parent().parent()
