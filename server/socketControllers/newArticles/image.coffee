models = require '../../../models'
# thumbnails = require '../../modules/thumbnails.coffee'

module.exports = (rawInput, callback) ->
  original_url = rawInput
  content = { original_url, key: null }
  return callback null, content

  # imageKey = Math.random().toString(36).slice(2)
  # thumbnailOptions =
  #   url: attributes.content
  #   # contentType: attributes.contentType
  #   path: "#{collectionKey}/#{imageKey}"
  #   copy: true

  # s3_prefix = 'https://s3-us-west-2.amazonaws.com/scrapimagesteamnap'
  # if attributes.content.indexOf(s3_prefix) is 0
  #   options.copy = false

  # thumbnails thumbnailOptions, (err, key) ->
  #   return console.log 'Err:'+err if err?
  #   models.
  #   attributes.content = key
