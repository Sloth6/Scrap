request = require 'request'
webPreviews = require '../../modules/webPreviews.coffee'

getId = (url) ->
  regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
  match = url.match(regExp)
  if match && match[2].length == 11 then match[2] else null

module.exports = (rawInput, callback) ->
  id = getId rawInput
  if id == null
    return callback "failed to get youtube id  #{rawInput}"
  
  webPreviews "https://www.youtube.com/watch?v=#{id}", (err, data) ->
    return callback err if err
    data.id = id
    data.url = encodeURIComponent data.url
    callback null, data