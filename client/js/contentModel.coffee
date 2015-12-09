window.contentModel = 
  init: ($content) ->
    isStack = $content.hasClass('.collection') and $content.data('contentType') is 'stack'
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
    
#     if isStack.mouseenter((event) ->
#       
#     )
    
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
    isPack = $content.hasClass('cover') or $content.hasClass('pack')
    normalTranslateY  = (Math.random() - .5) * $(window).height() / 8
    normalRotateZ     = (Math.random() - .5) * 20
    coverTranslateY   = ((Math.random() - .5) * $(window).height() / 3) + $(window).height() / 8
    coverRotateZ      = (Math.random() - .5) * 45
    
    margin =  if isPack then packMargin else articleMargin
    $content.data 'margin', margin

    $content.data 'jumble', {
      'translateY': if isPack then coverTranslateY else normalTranslateY
      'rotateZ':    if isPack then coverRotateZ else normalRotateZ
      'scale': 1
    }

