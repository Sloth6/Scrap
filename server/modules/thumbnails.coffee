s3 = require '../adapters/s3'
request = require 'request'
images = require 'images'
async = require 'async'

sizes =
  tiny: 40
  small: 100
  medium: 400

module.exports = ({ url, collectionKey, key, contentType }, callback) ->
  request.get { url, encoding: null }, (err, res, body) ->
    if contentType is 'gif'
      return callback()
      # frame = images(body).encode "png"
      # uploads = [
      #   ((cb) -> s3.putImage { key, collectionKey, img: frame, path: 'normal', type: 'png' }, cb)
      #   ((cb) -> s3.putImage { key, collectionKey, img: body, path: 'normal', type: 'gif' }, cb)
      # ]
    else
      normal = images(body).encode("jpg", {quality: 100})
      medium = images(body).size(sizes.medium).encode("jpg", {quality: 100})
      small = images(body).size(sizes.small).encode("jpg", {quality: 100})
      uploads = [
        ((cb) -> s3.putImage { key, collectionKey, img: small, path: 'small', type: 'jpg' }, cb),
        ((cb) -> s3.putImage { key, collectionKey, img: medium, path: 'medium', type: 'jpg' }, cb),
        ((cb) -> s3.putImage { key, collectionKey, img: normal, path: 'normal', type: 'jpg' }, cb),
      ]
    
    async.parallel uploads, (err) ->
      return callback err if err?
      callback null