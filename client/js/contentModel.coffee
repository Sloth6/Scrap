window.contentModel = 
  init: ($content) ->
    $content.off() # remove old handlers
    $collection = contentModel.getCollection $content
    makeDraggable $content
    makeDeletable $content
    # contentModel.setJumble $content

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
    $content.data
      'translateY': (Math.random()-.5) * 50# + 50
      'rotateZ': 0#Math.random() * 4 + (Math.random() * -4)
      'scale': 1
