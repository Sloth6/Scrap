emitNewElement = (content, spacekey) ->
  if !spacekey
    throw 'no spacekey given to emitNewElement'
  content = encodeURIComponent(content)
  if content != ''
    console.log "emiting '#{content}' to #{spacekey}"
    socket.emit 'newElement', { content, userId, spacekey }