emitNewArticle = (content, collectionKey) ->
  collectionKey = "#{collectionKey}"
  if !collectionKey
    throw 'no collectionKey given to emitNewArticle'
  content = encodeURIComponent(content)
  if content != ''
    console.log "emiting '#{content}' to #{collectionKey}"
    socket.emit 'newArticle', { content, userId, collectionKey }