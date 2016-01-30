models = require '../../../models'
request = require 'request'
webPreviews = require '../../modules/webPreviews.coffee'

module.exports = (rawInput, callback) ->
  options =
    uri: "http://soundcloud.com/oembed"
    method: 'POST'
    json:
      url: rawInput
  request options, (err, response, data) ->
    return callback "Soundcloud err", err if err or !data
    callback null, data