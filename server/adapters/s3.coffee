async = require 'async'
AWS = require 'aws-sdk'
AWS.config.loadFromPath __dirname+'/../config.json'
s3 = new AWS.S3()
Bucket = 'scrapimagesteamnap'
async = require 'async'
module.exports = 
  # getImage: ({bucket, path}, callback) ->
  #   params =
  #     Bucket: bucket
  #     Key: path
  #   s3.getObject params, callback

  putImage: ({ key, img, spaceKey, path, type }, callback) ->
    # console.log 's3', "#{spaceKey}/#{path}/#{key}.#{type}"
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
        (cb) -> s3.deleteObject { Bucket, Key: "#{spaceKey}/#{key}/gif.gif" }
      )
    async.parallel foo, cb
      
  # copyImage: ({ path, toBucket, fromBucket }, callback) ->
  #   params =
  #     Bucket: toBucket
  #     Key:    path
  #     ACL:    'public-read'
  #     ContentType: 'image/jpg'
  #     CopySource: "#{fromBucket}/#{path}"
  #   s3.copyObject params, callback

  # deleteImg: (id, cb) ->
  #   console.log 'deleting', id
  #   params =
  #     Bucket: 'facebookGraffiti'
  #     Key: id+'.jpg'
  #   s3.deleteObject params, cb