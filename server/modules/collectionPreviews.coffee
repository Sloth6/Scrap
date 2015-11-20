webshot = require 'webshot'
s3 = require '../adapters/s3.coffee'

debounce = (wait, func) ->
  timeout = null
  () ->
    clearTimeout timeout
    timeout = setTimeout func, wait

collection_timeouts = {}

options =
  windowSize:
    width: 600
    height: 400
  streamType: 'jpg'
  errorIfStatusIsNot200: true
  phantomConfig:
    'web-security': 'no'
  customCSS: ".form {
                visibility:hidden;
              }
              .soundcloudThumbnail {
                visibility:visible;
              }
              "

module.exports = (collectionKey) ->
  return
  if collection_timeouts[collectionKey]
    collection_timeouts[collectionKey]()
  else
    collection_timeouts[collectionKey] = debounce 10000, () ->
      url = "http://localhost:9001/webpreview/#{collectionKey}"
      console.log url
      console.time('new webshot')
      webshot url, options, (err, stream) ->
        if err?
          return console.log 'Err in webshot', err
        s3.uploadCollectionPreview { collectionKey, stream }, (err) ->
          console.timeEnd('new webshot')
          if err?
            console.log 'err in upload collection preview', err
