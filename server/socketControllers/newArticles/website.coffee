webPreviews = require '../../modules/webPreviews.coffee'

module.exports = (rawInput, callback) ->
  url = rawInput
  
  webPreviews url, (err, pageData) ->
    if err?
      console.log "did not find webpreview for #{url}"
      attributes = 
        title: url.match(/www.([a-z]*)/)[1]
        url: encodeURIComponent(url)
        description: ''

    else      
      attributes =  pageData
      attributes.url = encodeURIComponent attributes.url

    callback null, attributes