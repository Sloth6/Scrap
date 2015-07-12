init_scale = 0.8 #half the size of what will fit on screen
small_threshhold = 0.1 #scale that triggers 'small' class
viewOffsetX = viewOffsetY = 0
scrollTimer = null

screenFitScale = () ->
  scaleX = (window.innerWidth / (window.maxX - window.minX)) * .95
  scaleY = (window.innerHeight / (window.maxY - window.minY)) * .95
  (Math.min scaleX, scaleY)*init_scale

fitToCenter = () ->
  # cluster()
  scale = Math.min(screenFitScale(), 1/window.minScale)
  scale = if scale isnt 0 then scale else .5
  # scale = 1.0
  centerX = window.innerWidth / 2 / scale
  centerY = window.innerHeight / 2 / scale

  clusterCenterX = window.minX + (window.maxX - window.minX) / 2
  clusterCenterY = window.minY + (window.maxY - window.minY) / 2

  clusterCenterX = if isNaN clusterCenterX then 0 else clusterCenterX
  clusterCenterY = if isNaN clusterCenterY then 0 else clusterCenterY

  viewOffsetX = centerX - clusterCenterX
  viewOffsetY = centerY - clusterCenterY
  
  $('.content').css
    marginLeft: viewOffsetX * scale
    marginTop: viewOffsetY * scale

  $('.content').css { scale }

changeResolutions = () ->
  getSize = (e) ->
    s = $('.content').css 'scale'
    { w, h } = dimension e
    return 'small' if w * s < 100
    return 'medium' if w * s < 400
    'normal'
  
  switchImage = (img, key, size) ->
    root = 'https://s3-us-west-2.amazonaws.com/scrapimagesteamnap'
    # new images will not be stored in s3 with different sizes
    # and shoudl not be resized.
    if img.attr('src').indexOf(root) is 0
      url = "#{root}/#{spaceKey}/#{key}/#{size}.jpg"
      img.attr 'src', url

  $('.card.image').not('.animated,.gif').each () ->
    key = $(@).data('key')
    size = getSize $(@).parent()
    switchImage $(@).children('img'), key, size

scroll = (event) ->
  event.preventDefault()
  oldScale = $('.content').css 'scale'
  scaleDelta = (parseFloat(oldScale) * (event.deltaY / 100))
  newScale = oldScale - scaleDelta

  tooSmall = newScale < screenFitScale()/2 # zoom out
  tooBig = newScale > 1# 2/window.minScale # zoom in

  if not tooBig and not tooSmall
    viewOffsetX += (event.clientX / 100 / newScale) * event.deltaY
    viewOffsetY += (event.clientY / 100 / newScale) * event.deltaY

    if oldScale > small_threshhold and newScale <= small_threshhold
      $('article').addClass('small')
    
    if oldScale <= small_threshhold and newScale > small_threshhold
      $('article').removeClass('small')

    $('.content').css
      marginLeft: viewOffsetX  * newScale
      marginTop: viewOffsetY * newScale
      scale: newScale
    
    clearTimeout scrollTimer
    scrollTimer = setTimeout((() ->
      changeResolutions()
    ), 100)

