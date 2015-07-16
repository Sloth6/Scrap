videoScreenshot = require '../../modules/videoScreenshot.coffee'              

module.exports = (spaceKey, attributes, callback) ->
  videoScreenshot attributes.content, (err) ->
    return callback 'Error creating video screenshot'+ err if err
    callback null, attributes