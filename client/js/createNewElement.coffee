'use strict'
createNewElement = (element) ->  
  newArticle = $(element).appendTo $('.content')
  contentType = newArticle.data('contenttype')
  console.log 'NEW ELEMENT', contentType, newArticle

  switch contentType
    when 'gif'
      createGif newArticle, content
    when 'file'
      makeDownloadable newArticle

  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  makeModifiable newArticle
  makeResizeable newArticle, socket
  newArticle