async = require 'async'
AWS = require 'aws-sdk'
AWS.config.loadFromPath __dirname+'/../config.json'
s3 = new AWS.S3()
Bucket = 'scrapimagesteamnap'
async = require 'async'

# s3obj = new AWS.S3({params: {Bucket, Key: "#spaceKey/screenshot.jpg"}})
# console.log s3obj.upload
Stream = require('stream');

module.exports = 
  putImage: ({ key, img, spaceKey, path, type }, callback) ->
    params =
      Bucket: Bucket
      Key: "#{spaceKey}/#{key}/#{path}.#{type}"
      ACL: 'public-read'
      Body: img
      ContentType: "image/#{type}"
    s3.putObject params, callback

  uploadSpacePreview: ({spaceKey, stream}, callback) ->
    # params =
    #   Bucket: Bucket
    #   Key: "#spaceKey/screenshot.jpg"
    #   ACL: 'public-read'
    #   Body: stream
    #   ContentType: "image/jpg"
    s3obj = new AWS.S3({ params: { Bucket: Bucket, Key: "#{spaceKey}/screenshot.jpg" }})
    readableStream = new Stream.Readable().wrap(stream)
    s3obj.upload { Body: readableStream, ACL: 'public-read' }, (err, data) ->
      console.log err, data


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