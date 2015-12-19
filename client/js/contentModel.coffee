window.contentModel = 
  init: ($content) ->
    isStack = $content.hasClass 'stack'
    isPack  = $content.hasClass 'pack'
    $collection = contentModel.getCollection $content
    $card = contentModel.getCard($content)

    $content.off() # remove old handlers
    makeDraggable $content
    contentModel.setJumble $content

    # Stacks will not have a cover
    if $card?
      $card.mouseenter((event) ->
        unless isStack or $content.hasClass 'dragging'
          $content.add($card).addClass 'hover'
        event.stopPropagation()
      ).mouseleave (event) ->
        $content.add($card).removeClass 'hover'

    switch $content.data 'contenttype'
      when 'text'       then initText $content
      when 'video'      then initVideo $content
      when 'file'       then initFile $content
      when 'soundcloud' then initSoundCloud $content
      when 'youtube'    then initYoutube $content
      when 'collection' then collectionModel.init $content

  getCard: ($content) ->
    return null if $content.hasClass 'stack'
    if $content.hasClass 'pack'
      collectionModel.getCover($content).find '.card'
    else
      $content.children('.content').children('.transform').children('.card')

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
      $content.parent().parent()
    else if $content.hasClass 'dragging'
      $content.data 'originalCollection'
    else
      $content.parent().parent().parent()

  getCollectionkey: ($content) ->
    $collection = contentModel.getCollection $content
    return collectionModel.getState($collection).collectionKey

  setJumble: ($content) ->
    isPack = $content.data('collectiontype') is 'pack'
    normalTranslateY  = (Math.random() - .5) * $(window).height() / 16
    normalRotateZ     = (Math.random() - .5) * 8
    coverTranslateY   = ((Math.random() - .5) * $(window).height() / 3) + $(window).height() / 16
    coverRotateZ      = (Math.random() - .5) * 25
    margin = if isPack then packMargin else articleMargin
    
    $content.data 'margin', margin
    $content.data 'jumble', {
      'translateY': if isPack then coverTranslateY else normalTranslateY
      'rotateZ':    if isPack then coverRotateZ else normalRotateZ
      'scale':      .95
    }

    
    
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

