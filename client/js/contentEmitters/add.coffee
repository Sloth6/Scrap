emitNewArticle = (content, collectionkey) ->
  if !collectionkey
    throw 'no collectionkey given to emitNewArticle'
  content = encodeURIComponent(content)
  if content != ''
    console.log "emiting '#{content}' to #{collectionkey}"
    socket.emit 'newArticle', { content, userId, collectionkey }