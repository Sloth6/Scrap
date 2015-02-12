AWS = require 'aws-sdk'
AWS.config.loadFromPath __dirname+'/../config.json'
s3 = new AWS.S3()
root = 'scrapimagesteamnap'

module.exports = 
  # getImage: ({bucket, path}, callback) ->
  #   params =
  #     Bucket: bucket
  #     Key: path
  #   s3.getObject params, callback

  putImage: ({ key, img, spaceKey, type }, callback) ->
    console.log 's3', "#{spaceKey}/#{type}/#{key}.jpg"
    params =
      Bucket: root
      Key: "#{spaceKey}/#{type}/#{key}.jpg"
      ACL: 'public-read'
      Body: img
      ContentType: 'image/jpg'
    s3.putObject params, callback

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