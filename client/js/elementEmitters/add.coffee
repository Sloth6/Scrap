emitNewElement = (content, spacekey) ->
  content = encodeURIComponent(content)
  if content != ''
    console.log "emiting '#{content}' to #{spacekey}"
    socket.emit 'newElement', { content, userId, spacekey }