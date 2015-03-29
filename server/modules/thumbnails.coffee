s3 = require '../adapters/s3'
request = require 'request'
images = require 'images'
async = require 'async'

sizes =
  small: 100
  medium: 400

module.exports = ({ url, spaceKey, key, contentType }, callback) ->
  request.get { url, encoding: null }, (err, res, body) ->
    if contentType is 'gif'
      frame = images(body).encode "png"
      uploads = [
        ((cb) -> s3.putImage { key, spaceKey, img: frame, path: 'normal', type: 'png' }, cb)
        ((cb) -> s3.putImage { key, spaceKey, img: body, path: 'normal', type: 'gif' }, cb)
      ]
    else
      normal = images(body).encode("jpg", {quality: 100})
      medium = images(body).size(sizes.medium).encode("jpg", {quality: 100})
      small = images(body).size(sizes.small).encode("jpg", {quality: 100})
      uploads = [
        ((cb) -> s3.putImage { key, spaceKey, img: small, path: 'small', type: 'jpg' }, cb),
        ((cb) -> s3.putImage { key, spaceKey, img: medium, path: 'medium', type: 'jpg' }, cb),
        ((cb) -> s3.putImage { key, spaceKey, img: normal, path: 'normal', type: 'jpg' }, cb),
      ]
    
    async.parallel uploads, (err) ->
      return callback err if err?
      callback null