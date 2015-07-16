models = require '../../../models'
thumbnails = require '../../modules/thumbnails.coffee'

module.exports = (spaceKey, attributes, callback) ->
  options =
    url: attributes.content
    contentType: attributes.contentType
    spaceKey: spaceKey
    copy = true

  s3_prefix = 'https://s3-us-west-2.amazonaws.com/scrapimagesteamnap'
  
  if attributes.content.indexOf(s3_prefix) is 0
    options.copy = false

  thumbnails options, (err, key) ->
    return callback err if err?
    attributes.content = key
    return callback null, attributes