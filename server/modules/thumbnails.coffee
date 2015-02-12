s3 = require '../adapters/s3'
request = require 'request'
images = require 'images'
async = require 'async'

sizes =
  small: 100
  medium: 400

rand_key = () -> Math.random().toString(36).slice(2)

module.exports = ({ url, spaceId }, callback) ->
  request.get { url, encoding: null }, (err, res, body) ->
    normal = images(body).encode("jpg", {quality: 100})
    medium = images(body).size(sizes.medium).encode("jpg", {quality: 100})
    small = images(body).size(sizes.small).encode("jpg", {quality: 100})
    # console.log normal.compare(medium)
    # callback()
    name = rand_key()
    async.parallel [
      ((cb) -> s3.putImage { name, spaceId, img: small, type: 'small' }, cb),
      ((cb) -> s3.putImage { name, spaceId, img: medium, type: 'medium' }, cb),
      ((cb) -> s3.putImage { name, spaceId, img: normal, type: 'normal' }, cb),
    ], (err) ->
      return callback err if err?
      callback null, name+'.jpg'


module.exports {
  url: 'http://bigtent.tv/wp-content/uploads/2013/08/IMG_1604.jpg'
  spaceId: '17cbc8d6'
}, (err, id) ->
  console.log err, id

# download 'https://www.google.com/images/srpr/logo3w.png', 'google', 1, (err) ->
#   console.log 'done', err
