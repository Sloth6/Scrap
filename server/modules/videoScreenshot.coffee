s3 = require '../adapters/s3'
ffmpeg = require 'fluent-ffmpeg'
Bucket = 'scrapimagesteamnap'
fs = require 'fs'
stream = require('stream')
async = require 'async'

parseVideoUrl = (url) ->
  bucket = 'scrapimagesteamnap'
  keys = url.split(bucket)[1].split('/')
  [_, spaceKey, key, name] = keys
  { spaceKey, key, name }

module.exports = (video_url, callback) ->
  temp_file_name = Math.random().toString(36).substr(2)+'.png'
  temp_folder = './server/tmp/'
  temp_path = "#{temp_folder}/#{temp_file_name}"

  try
    { spaceKey, key, name } = parseVideoUrl video_url
  catch e
    return callback "malformed video_url: '#{video_url}'"
  
  cmd = ffmpeg(video_url)
    .screenshots
      timestamps: [0]
      filename: temp_file_name
      folder: temp_folder
    .on 'end', () ->
      console.log 'successfully created video screenshot'
      fs.readFile temp_path, (err, data) ->
        return callback err if err
        upload_options = { key, img:data, spaceKey, path:name, type: 'png' }
        s3.putImage upload_options, (err) ->
          console.log 'successfully uplaoded video screenshot'
          return callback err if err
          fs.unlink temp_path, (err) ->
            console.log 'successfully deleted screenshot'
            callback err