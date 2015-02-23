async = require 'async'
AWS = require 'aws-sdk'
AWS.config.loadFromPath __dirname+'/../config.json'
s3 = new AWS.S3()
Bucket = 'scrapimagesteamnap'
async = require 'async'
module.exports = 
  putImage: ({ key, img, spaceKey, path, type }, callback) ->
    params =
      Bucket: Bucket
      Key: "#{spaceKey}/#{key}/#{path}.#{type}"
      ACL: 'public-read'
      Body: img
      ContentType: "image/#{type}"
    s3.putObject params, callback


  deleteImage: ({ spaceKey, key, type }, cb) ->
    foo = [
      ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/small.jpg" }, cb),
      ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/medium.jpg" }, cb),
      ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/normal.jpg" }, cb)
    ]
    if type is 'gif'
      foo.push(
        (cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/gif.gif" }, cb
      )
    async.parallel foo, cb