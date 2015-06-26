createNewElement = (element) ->
  newArticle = $(element)
  contentType = newArticle.data('contenttype')
  creatorId = newArticle.data('creatorid')
  console.log 'NEW ELEMENT', {contentType, creatorId}

  newArticle.find('author').text(names[creatorId])
  { top, left } = newArticle.css(['top', 'left'])
  x = parseInt(left) + totalDelta.x
  y = parseInt(top) + totalDelta.y
  newArticle.css({ top: y, left:x }).appendTo $('.content')

  socket = io.connect()
  
  makeDeletable newArticle  
  makeDraggable newArticle, socket
  
  if contentType is 'text'
    makeTextChild newArticle
    makeModifiable newArticle, socket
  else if contentType is 'video'
    bindVideoControls newArticle
  else if contentType is 'file'
    bindFileControls newArticle
  else if contentType is 'soundcloud'
    bindSoundCloudControls newArticle

  newArticle