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
      
    isCollection = $content.hasClass('collection')
    isStack = isCollection and $content.hasClass('stack')
    isPack  = isCollection and $content.hasClass('pack')
    
    $card = if isPack then $content.children('article').children('.content').children('.transform').children('.card') else $content.children('.content').children('.transform').children('.card')   
      
    $card.mouseenter((event) ->
      event.stopPropagation()
      unless $content.hasClass('dragging') or $content.hasClass('stack') or $content.parent().parent().hasClass('stack')
        console.log 'stack', $content, $content.parent(), $content.parent().parent().hasClass('stack')
        $(@).addClass 'hover'
    ).mouseleave((event) ->
      $(@).removeClass 'hover'
    )
    
    
#     if $content.hasClass('pack')
#       $content.mouseover((event) ->
#         if $content.hasClass('closed')
#           $content.velocity
#             properties:
#               rotateZ: $content.data('jumble').rotateZ/2
#             options:
#               duration: 500
#       ).mouseleave((event) ->
#         if $content.hasClass('closed')
#           $content.velocity
#             properties:
#               rotateZ: $content.data('jumble').rotateZ
#               
#       )
    
#     if $content.hasClass('stack')
# #       console.log('wowowowowo', $content)
#       $content.mouseenter((event) ->
#         console.log('wow')
#       ).css('opacity', .25)
    
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
    # Check if pack because pack covers are scaled
#     return $content.find('.card').width() * 2 if $content.find('.card').width() and $content.hasClass('pack')
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
    normalTranslateY  = (Math.random() - .5) * $(window).height() / 16
    normalRotateZ     = (Math.random() - .5) * 8
    coverTranslateY   = ((Math.random() - .5) * $(window).height() / 3) + $(window).height() / 16
    coverRotateZ      = (Math.random() - .5) * 25
    margin =  if isPack then packMargin else articleMargin
    $content.data 'margin', margin

    $content.data 'jumble', {
      'translateY': if isPack then coverTranslateY else normalTranslateY
      'rotateZ':    if isPack then coverRotateZ else normalRotateZ
      'scale':      .95
    }

