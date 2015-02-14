$ ->
  content = $ '.content'
  viewOffsetX = viewOffsetY = 0

  screenFitScale = () ->
    scaleX = (window.innerWidth / (window.maxX - window.minX)) * .95
    scaleY = (window.innerHeight / (window.maxY - window.minY)) * .95
    Math.min scaleX, scaleY

  fitToCenter = () ->
    cluster()
    scale = Math.min(screenFitScale(), 1/window.minScale)
    scale = if scale isnt 0 then scale else 1

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
  
  # Set initial header scale value (relative to parent article)
  $('article > header').each () ->
    transform = $(this).css '-webkit-transform'
    matrix = new WebKitCSSMatrix(transform)
    headerScale = matrix.m11
    $(this).attr 'data-scale', headerScale

  changeResolutions = () ->
    getSize = (e) ->
      s = content.css 'scale'
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
  # scroll unless too far in or too far out
  $(window).on 'mousewheel', (event) ->
    event.preventDefault()
    oldScale = content.css 'scale'
    # console.log event.deltaY
    scaleDelta = (parseFloat(oldScale) * (event.deltaY / 100))
    newScale = oldScale - scaleDelta

    tooSmall = newScale < screenFitScale()/5 # zoom out
    tooBig = newScale > 1/window.minScale # zoom in

    if not tooBig and not tooSmall
      viewOffsetX += (event.clientX / 100 / newScale) * event.deltaY
      viewOffsetY += (event.clientY / 100 / newScale) * event.deltaY

      content.css
        marginLeft: viewOffsetX  * newScale
        marginTop: viewOffsetY * newScale

      content.css scale: newScale
      
      $('article > header').each () ->
        headerScale = $(this).attr 'data-scale'
        
        # headerScale = 1/(elementScale($(this)))
        newHeaderScale =  (1 / newScale) * headerScale
        $(this).css         'transform', 'scale(' + newHeaderScale + ')'
        $(this).css '-webkit-transform', 'scale(' + newHeaderScale + ')'
        console.log newHeaderScale
      
      clearTimeout(scrollTimer)
      scrollTimer = setTimeout((() ->
        changeResolutions()
      ), 100)

