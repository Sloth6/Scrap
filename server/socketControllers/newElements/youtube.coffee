getId = (url) ->
  regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
  match = url.match(regExp)
  if match && match[2].length == 11 then match[2] else null

module.exports = (spaceKey, attributes, callback) ->
  id = getId attributes.content
  if id == null
    callback "failed to get youtube id  #{attributes.content}"
  else
    attributes.content = id
    callback null, attributes