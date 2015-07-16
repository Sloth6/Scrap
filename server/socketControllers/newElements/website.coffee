webPreviews = require '../../modules/webPreviews.coffee'

module.exports = (spaceKey, attributes, callback) ->
  url = attributes.content
  webPreviews url, (err, pageData) ->
    if err?
      attributes.content = JSON.stringify { 
        title: url.match(/www.([a-z]*)/)[1]
        url: encodeURIComponent(url)
        description: ''
      }
    else
      pageData.url = encodeURIComponent pageData.url
      attributes.content = JSON.stringify pageData
    callback null, attributes