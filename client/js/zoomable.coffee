$ ->
  content = $ '.content'
  scale_constant = 2.0 #half the size of what will fit on screen
  viewOffsetX = viewOffsetY = 0
  
  screenFitScale = () ->
    scaleX = (window.innerWidth / (window.maxX - window.minX)) * .95
    scaleY = (window.innerHeight / (window.maxY - window.minY)) * .95
    (Math.min scaleX, scaleY)/scale_constant

  fitToCenter = () ->
    cluster()
    scale = Math.min(screenFitScale(), 1/window.minScale)
    scale = if scale isnt 0 then scale else .5

    centerX = window.innerWidth / 2 / scale
    centerY = window.innerHeight / 2 / scale

    clusterCenterX = window.minX + (window.maxX - window.minX) / 2
    clusterCenterY = window.minY + (window.maxY - window.minY) / 2

    clusterCenterX = if isNaN clusterCenterX then 0 else clusterCenterX
    clusterCenterY = if isNaN clusterCenterY then 0 else clusterCenterY

    viewOffsetX = centerX - clusterCenterX
    viewOffsetY = centerY - clusterCenterY
    
    content.css
      marginLeft: viewOffsetX * scale
      marginTop: viewOffsetY * scale

    content.css { scale }

  changeResolutions = () ->
    getSize = (e) ->
      s = content.css 'scale'
      # x = Math.floor(parseInt(e.css('left')))
      # y = Math.floor(parseInt(e.css('top')))
      { w, h } = dimension e
      return 'small' if w * s < 100
      return 'medium' if w * s < 400
      'normal'
    
    switchImage = (img, key, size) ->
      root = 'https://s3-us-west-2.amazonaws.com/scrapimagesteamnap'
      url = "#{root}/#{spaceKey}/#{size}/#{key}.jpg"
      img.attr 'src', url

    $('.card,.image').each () ->
      key = $(@).data('key')
      if key
        size = getSize $(@).parent()
        switchImage $(@).children().first(), key, size

  socket = io.connect()
  fitToCenter()
  scrollTimer = null
  changeResolutions()
  $('article > header, article > .resize').each () ->
    scaleControls($(this))
  
  # scroll unless too far in or too far out
  $(window).on 'mousewheel', (event) ->
    event.preventDefault()
    oldScale = content.css 'scale'
    # console.log event.deltaY
    scaleDelta = (parseFloat(oldScale) * (event.deltaY / 100))
    newScale = oldScale - scaleDelta

    tooSmall = newScale < screenFitScale()/5 # zoom out
    tooBig = newScale > 2/window.minScale # zoom in

    if not tooBig and not tooSmall
      viewOffsetX += (event.clientX / 100 / newScale) * event.deltaY
      viewOffsetY += (event.clientY / 100 / newScale) * event.deltaY

      content.css
        marginLeft: viewOffsetX  * newScale
        marginTop: viewOffsetY * newScale

      content.css scale: newScale
      
      $('article > header, article > .resize').each () ->
        scaleControls($(this))
      
      clearTimeout(scrollTimer)
      scrollTimer = setTimeout((() ->
        changeResolutions()
      ), 100)

