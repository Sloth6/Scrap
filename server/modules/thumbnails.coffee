s3 = require '../adapters/s3'
request = require 'request'
images = require 'images'
async = require 'async'

sizes =
  small: 100
  medium: 400

rand_key = () -> Math.random().toString(36).slice(2)

module.exports = ({ url, spaceKey, key, contentType }, callback) ->
  request.get { url, encoding: null }, (err, res, body) ->
    normal = images(body).encode("jpg", {quality: 100})
    medium = images(body).size(sizes.medium).encode("jpg", {quality: 100})
    small = images(body).size(sizes.small).encode("jpg", {quality: 100})
    uploads = [
      ((cb) -> s3.putImage { key, spaceKey, img: small, path: 'small', type: 'jpg' }, cb),
      ((cb) -> s3.putImage { key, spaceKey, img: medium, path: 'medium', type: 'jpg' }, cb),
      ((cb) -> s3.putImage { key, spaceKey, img: normal, path: 'normal', type: 'jpg' }, cb),
    ]
    if contentType is 'gif'
      uploads.push ((cb) ->
        s3.putImage { key, spaceKey, img: body, path: 'gif', type: 'gif' }, cb
      )
    async.parallel uploads, (err) ->
      return callback err if err?
      callback null