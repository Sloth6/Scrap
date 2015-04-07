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

  delete: ({key}, cb) ->
    s3.deleteObject { Bucket, Key: key }, cb

  deleteImage: ({ spaceKey, key, type }, cb) ->
    if type is 'gif'
      deletes = [
        ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/normal.gif" }, cb),
        ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/normal.png" }, cb)
      ]
    else
      deletes = [
        ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/small.jpg" }, cb),
        ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/medium.jpg" }, cb),
        ((cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/normal.jpg" }, cb)
      ]
    async.parallel deletes, cb