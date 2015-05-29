'use strict'
createNewElement = (element) ->
  newArticle = $(element)
  contentType = newArticle.data('contenttype')
  console.log 'NEW ELEMENT', contentType

  creatorId = newArticle.data('creatorid')
  newArticle.find('author').text(names[creatorId])

  { top, left } = newArticle.css(['top', 'left'])
  x = parseInt(left) + totalDelta.x
  y = parseInt(top) + totalDelta.y
  newArticle.css({ top: y, left:x }).appendTo $('.content')

  switch contentType
    when 'gif'
      createGif newArticle, content
    when 'file'
      makeDownloadable newArticle

  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  makeModifiable newArticle
  newArticle