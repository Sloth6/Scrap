'use strict'
createNewElement = (element) ->  
  newArticle = $(element).appendTo $('.content')
  contentType = newArticle.data('contenttype')
  console.log 'NEW ELEMENT', contentType, newArticle

  creatorId = newArticle.data('creatorid')
  newArticle.find('author').text(names[creatorId])
  newArticle.find('.card').addClass("color#{colors[creatorId]}")
  newArticle.find('.card').removeClass("colorundefined")
  switch contentType
    when 'gif'
      createGif newArticle, content
    when 'file'
      makeDownloadable newArticle

  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  makeModifiable newArticle
  # makeResizeable newArticle, socket
  newArticle