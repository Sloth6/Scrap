# videoScreenshot = require '../../modules/videoScreenshot.coffee'              

module.exports = (rawInput, callback) ->
  # videoScreenshot attributes.content, (err) ->
  #   return callback 'Error creating video screenshot'+ err if err
  callback null, { url: rawInput }