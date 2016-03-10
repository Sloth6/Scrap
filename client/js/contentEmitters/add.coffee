emitNewArticle = (content, collectionKey) ->
  if !collectionKey
    throw 'no collectionKey given to emitNewArticle'

  collectionKey = "#{collectionKey}"

  content = encodeURIComponent content
  if content != ''
    console.log "emiting '#{content}' to #{collectionKey}"
    socket.emit 'newArticle', { content, userId, collectionKey }
