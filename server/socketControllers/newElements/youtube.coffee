request = require 'request'
webPreviews = require '../../modules/webPreviews.coffee'

getId = (url) ->
  regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
  match = url.match(regExp)
  if match && match[2].length == 11 then match[2] else null

module.exports = (spaceKey, attributes, callback) ->
  id = getId attributes.content
  if id == null
    return callback "failed to get youtube id  #{attributes.content}"
  
  webPreviews "https://www.youtube.com/watch?v=#{id}", (err, pageData) ->
    return callback err if err
    pageData.id = id
    pageData.url = encodeURIComponent pageData.url
    attributes.content = JSON.stringify pageData
    callback null, attributes