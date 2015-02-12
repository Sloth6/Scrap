s3 = require '../adapters/s3'
request = require 'request'
images = require 'images'

sizes =
  small: 100

rand_key = () -> Math.random().toString(36).slice(2)

module.exports = ({ url, spaceId }, callback) ->
  console.log url, spaceId
  request.get { url, encoding: null }, (err, res, body) ->
    small = images(body).size(sizes.small).encode("png")
    normal = images(body).encode("png")
    name = rand_key()

    s3.putImage { name, spaceId, img: small }, (err, data) ->
      return callback err if err?
      callback null, name+'.png'
      

# download 'https://www.google.com/images/srpr/logo3w.png', 'google', 1, (err) ->
#   console.log 'done', err
