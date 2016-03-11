emitNewArticle = (content, collectionKey) ->
  # if !content
  #   throw 'no content given to emitNewArticle:'+content
  #   return
  if !collectionKey
    throw 'no collectionKey given to emitNewArticle'
    return

  collectionKey = "#{collectionKey}"
  content = encodeURIComponent content
  if content != ''
    console.log "emiting '#{content}' to #{collectionKey}"
    socket.emit 'newArticle', { content, userId, collectionKey }
