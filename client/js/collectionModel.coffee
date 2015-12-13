loadArticles = (collectionkey, callback) ->
  return callback 'ERR. collectionkey not passed to loadArticles' unless collectionkey  
  $.get "/collectionContent/#{collectionkey}", (data) ->
    callback $(data)
    
redrawCollections = ($collection, $parentCollection, animate) ->
#   options = if animate then  { animate: true } else 0
  if animate
    collectionViewController.draw $collection, { animate: true }
    collectionViewController.draw $parentCollection, { animate: true }
  else
    collectionViewController.draw $collection
    collectionViewController.draw $parentCollection, { animate: true }
  
closePackPreview = ($collection, $parentCollection) ->
  unless $collection.hasClass('open') or $collection.data('previewState') is 'expanded'
    $collection.data 'previewState', 'none'
    $collection.velocity
      properties:
        rotateZ: $collection.data 'rotateZTemp'
        translateX: xTransform($collection)
    redrawCollections $collection, $parentCollection
#     setTimeout () ->
#       collectionModel.removeContent $collection
#       redrawCollections $collection, $parentCollection
#     , openCollectionDuration

window.collectionModel =
  init: ($collection) ->
    $cover            = collectionModel.getCover $collection
    $parentCollection = contentModel.getCollection $collection
    $contentContainer = $collection.find('.contentContainer')
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
      $cover = $collection.find('.cover')
      $collection.data 'previewState', 'none'
      $cover.mouseenter () ->
        unless $collection.hasClass 'open'
          collectionModel.loadContent $collection, () ->
            unless $collection.data 'contentLoaded'
              $collection.data 'contentLoaded', true
            $collection.data 'rotateZTemp', getRotateZ($collection)
            $contentContainer.css 'opacity', 0
            $collection.data 'previewState', 'none'
            $collection.data 'drawInstant', true
            redrawCollections $collection, $parentCollection, false
            $collection.data('drawInstant', false)
            setTimeout () ->
              $contentContainer.css 'opacity', 1
              $collection.data 'previewState', 'compactReverse'
              redrawCollections $collection, $parentCollection, true
            , 100
#             $cover.mouseover () ->
#               $collection.data 'previewState', 'compactReverse'
#               redrawCollections $collection, $parentCollection, true
      $contentContainer.mouseenter () ->
        unless $collection.hasClass 'open'
          $collection.data 'previewState', 'expanded'
          redrawCollections $collection, $parentCollection, true
          $collection.velocity
            properties:
              rotateZ: 0
              translateX: if $collection.offset().left < $cover.width() then 0 else xTransform($collection)
          redrawCollections $collection, $parentCollection, true
          $cover.off('mouseleave')
      $contentContainer.mouseleave () ->
        # if mouse is over cover
        if $collection.is(":hover")
          $collection.data 'previewState', 'compactReverse'
          $collection.velocity
            properties:
              rotateZ: $collection.data 'rotateZTemp'
              translateX: xTransform($collection)
        else
          $collection.data 'previewState', 'none'
        redrawCollections $collection, $parentCollection, true
        $cover.on('mouseleave', () -> closePackPreview($collection, $parentCollection))
      $cover.mouseleave () ->
        closePackPreview($collection, $parentCollection)
    else
      $collection.data 'contenttype', 'stack'
      $collection.addClass 'stack'
      $content.on 'click mouseup', clickBlock
      $collection.data 'previewState', 'compact'
      $collection.mouseenter () ->
        unless $collection.hasClass 'dragging'
          $collection.data 'previewState', 'expanded'
          redrawCollections $collection, $parentCollection, true
      $collection.mouseleave () -> 
        $collection.data 'previewState', 'compact'
        redrawCollections $collection, $parentCollection, true
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
