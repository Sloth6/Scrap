idToClusters = {}
clusterToIds = {}
socket = io.connect()

getIdsInCluster = (id) ->
  clusterToIds[idToClusters[id]] or []

cluster = () ->
  return
  leaves = (hcluster) ->
    # flatten cluster hierarchy
    if !hcluster.left
      [hcluster]
    else
      leaves(hcluster.left).concat(leaves(hcluster.right))

  getCoords = () ->
    porportionOFScreen = (e) ->
      elemWidth = e.w * $('.content').css('scale')
      screenWidth = window.innerWidth
      elemWidth / screenWidth
    $('.content').children().get().map((elem)->
      try
        $elem = $(elem)
        offset = $elem.offset()
        dimens = dimension $elem
        elem =
          id: Math.floor(parseInt($elem.attr('id')))
          x: Math.floor(parseInt($elem.css('left')))
          y: Math.floor(parseInt($elem.css('top')))
          w: Math.floor(dimens.w)
          h: Math.floor(dimens.h)
          # tooBig: false

        # if porportionOFScreen(elem) > .10
        #   elem.tooBig = true
        elem
      catch
        null).filter((elem) -> !!elem)

  worker = {}
  
  intersect = (a, b) ->
    offset = 0#10 / screenScale
    maxAx = a.x + a.w + offset
    maxAy = a.y + a.h + offset

    maxBx = b.x + b.w + offset
    maxBy = b.y + b.h + offset

    minAx = a.x - offset
    minAy = a.y - offset

    minBx = b.x - offset
    minBy = b.y - offset

    aLeftOfB  = maxAx < minBx;
    aRightOfB = minAx > maxBx;
    aAboveB   = minAy > maxBy;
    aBelowB   = maxAy < minBy;
    return !( aLeftOfB || aRightOfB || aAboveB || aBelowB );

  compare = (e1, e2) ->
    # if e1.tooBig || e2.tooBig
    #   return Infinity
    # screenScale = $('.content').css('scale')
    # Math.sqrt(Math.pow( (e1.x - e2.x) * screenScale, 2) + Math.pow(e1.y * screenScale - e2.y * screenScale, 2))
    if intersect e1, e2 then 0 else 50
  
  compare2 = (a,b) ->
    xa = a.x + a.w/2
    ya = a.y + a.h/2
    xb = b.x + b.w/2
    yb = b.x + b.h/2
    Math.sqrt(Math.pow( (xa - xb), 2) + Math.pow(ya - yb, 2))


  colorClusters = (clusters) ->
    $('.cluster').remove()
    idToClusters = {}
    clusterToIds = {}
    cid = 0
    # console.log clusters
    for clust in clusters
      continue if clust.length < 2
      maxX = Math.max.apply(null, clust.map (e) -> (e.x + e.w))
      maxY = Math.max.apply(null, clust.map (e) -> (e.y + e.h))
      minX = Math.min.apply(null, clust.map (e) -> e.x)
      minY = Math.min.apply(null, clust.map (e) -> e.y)
      width = (maxX - minX)
      height = (maxY - minY)
      $('<div />').addClass('cluster').css({
        top: minY - 20
        left: minX - 20
        width: width + 40
        height: height + 40 
        position: 'absolute'
        "transform-origin": "top left"
        'background-color': 'grey'
      }).data({
        elems: clust.map (e) -> e.id
      }).draggable(draggableOptions socket)
        .appendTo $('.content')

  flatten = (clusters) ->
    console.log clusters
    clusters = clusters.map((hcluster) ->
      leaves(hcluster).map((leaf) -> leaf.value))
    try
      colorClusters clusters
  
  makeDiv = ({ x, y, w, h }) ->
    style =
      top: y
      left: x
      width: w
      height: h
      opacity: 0.3
      'background-color': 'grey'
      "transform-origin": "top left"
      position:'absolute'
    div = $('<div>').css(style).addClass('cluster')
    $('.content').append div
  
  format = (obj) ->
    if obj.size is 1
      obj.value
    else
      L = format(obj.left)
      R = format(obj.right)
      d = Math.sqrt(Math.pow( (L.x - R.x), 2) + Math.pow(L.y - R.y, 2))
      # console.log
      x = Math.min L.x, R.x
      y = Math.min L.y, R.y
      w = (Math.max L.x+L.w, R.x+R.w) - x
      h = (Math.max L.y+L.h, R.y+R.h) - y
      makeDiv { x, y, w, h } if d < 200
      return { x, y, w, h }
 
  $('.cluster').remove()
  coords = getCoords()
  clusters = clusterfck.hcluster coords, compare2, 'single'
  console.log(format clusters)
