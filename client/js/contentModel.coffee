window.contentModel = 
  init: ($content) ->
    $content.off() # remove old handlers
    $collection = contentModel.getCollection $content
    makeDraggable $content
    makeDeletable $content
            
    switch $content.data('contenttype')
      when 'text'       then initText $content
      when 'video'      then initVideo $content
      when 'file'       then initFile $content
      when 'soundcloud' then initSoundCloud $content
      when 'youtube'    then initYoutube $content
      when 'collection' then collectionModel.init $content
      
    $content.find('.card').mouseenter((event) ->
      event.stopPropagation()
      unless $content.hasClass 'dragging'
        $(@).addClass 'hover'
    ).mouseleave((event) ->
      $(@).removeClass 'hover'
    )
    
    # $content.mouseover( () ->
    #   x = xTransform $content
    #   return if x < edgeWidth or (x > $(window).width - edgeWidth)
    #   return if $content.hasClass 'dragging'
    #   $content.data 'oldZIndex', $content.css('zIndex')
    #   $content.css 'zIndex', $.topZIndex('article')
    # ).mouseout () ->
    #   return if $content.hasClass 'dragging'
    #   return unless $content.data 'oldZIndex'
    #   $content.css 'zIndex', $content.data('oldZIndex')

  setSize: ($contents, size) ->
    $contents.data 'size', size

  getSize: ($content) ->
    return $content.data('size') if $content.data('size')?
    return $content.find('.card').width() if $content.find('.card').width()
    0

  getCollection: ($content) ->
    if $content.hasClass('cover')
      $content.parent()
    else
      $content.parent().parent()

  getCollectionkey: ($content) ->
    $collection = contentModel.getCollection $content
    return collectionModel.getState($collection).collectionKey

  setJumble: ($content) ->
    isCover           = $content.hasClass('.collection') and $content.data('contentType') is 'stack'
    normalTranslateY  = (Math.random() - .5) * $(window).height() / 12
    normalRotateZ     = (Math.random() - .5) * 4
    coverTranslateY   = (Math.random() - .5) * $(window).height()
    coverRotateZ      = (Math.random() - .5) * 22
    $content.data 'jumble', {
      'translateY': if isCover then coverTranslateY else normalTranslateY
      'rotateZ':    if isCover then coverRotateZ    else normalRotateZ
      'scale': 1
    }
