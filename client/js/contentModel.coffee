window.contentModel = 
  init: ($contents) ->    
    # $contents.addClass 'draggable'
    contentViewController.jumble $contents
    makeDraggable $contents.filter('.draggable')
    makeDeletable $contents

    $contents.mouseover( () ->
      $content = $(@)
      x = xTransform $content
      return if x < edgeWidth or (x > $(window).width - edgeWidth)
      return if $content.hasClass 'dragging'
      $content.data 'oldZIndex', $content.css('zIndex')
      $content.css 'zIndex', $.topZIndex('article')
    ).mouseout () ->
      $content = $(@)
      return if $content.hasClass 'dragging'
      return unless $content.data 'oldZIndex'
      $content.css 'zIndex', $content.data('oldZIndex')

    $contents.each () ->
      switch $(@).data('contenttype')
        when 'text'       then initText $(@)
        when 'video'      then initVideo $(@)
        when 'file'       then initFile $(@)
        when 'soundcloud' then initSoundCloud $(@)
        when 'youtube'    then initYoutube $(@)
        when 'addElementForm'
          addElementController.init $(@)
        when 'addProjectForm'
          addProjectController.init $(@)
        when 'collection'
          collectionModel.init $(@)
  
  setSize: ($contents, size) ->
    $contents.data 'size', size

  getSize: ($content) ->
    return $content.data('size') if $content.data('size')?
    return $content.find('.card').width() if $content.find('.card').width()
    console.log $content[0]
    throw 'Cannot get size'

  getCollection: ($content) ->
    if $content.hasClass('cover')
      $content.parent()
    else
      $content.parent().parent()

  getSpacekey: ($content) ->
    $collection = contentModel.getCollection $content
    return collectionModel.getState($collection).spaceKey