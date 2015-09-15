models = require '../../../models'
request = require 'request'
webPreviews = require '../../modules/webPreviews.coffee'

module.exports = (spaceKey, attributes, callback) ->
  options =
    uri: "http://soundcloud.com/oembed"
    method: 'POST'
    json:
      url: attributes.content
  request options, (err, response, body) ->
    return callback "Soundcloud err", err if err or !body
    attributes.content = JSON.stringify body
    callback null, attributes