formatName = (name) ->
  name.split('/').pop().replace(/\s/g, '+')

fileuploadOptions = (collection, collectionKey) ->
  multipart = false

  url: "http://scrapimagesteamnap.s3.amazonaws.com" # Grabs form's action src
  type: 'POST'
  autoUpload: true
  dataType: 'xml' # S3's XML response
  add: (event, add_data) ->
    # videoHandler file for file in add_data.originalFiles
    $.ajax "/sign_s3", {
      type: 'GET'
      dataType: 'json'
      data:# Send filename to /signed for the signed response 
        title: add_data.files[0].name
        type: add_data.files[0].type
        collectionKey: collectionKey
      async: false
      success: (success_data) ->
        console.log success_data.path
        # file_name = formatName(success_data.key)
        # createLoadingArticle locations[file_name], file_name

        # Now that we have our data, we update the form so it contains all
        # the needed data to sign the request
        $('input[name=key]').val success_data.path
        $('input[name=policy]').val success_data.policy
        $('input[name=signature]').val success_data.signature
        $('input[name=Content-Type]').val success_data.contentType
    }
    add_data.submit()

  send: (e, data) ->
    # Determine if this was a multiple upload
    if data.originalFiles.length > 1
      multipart = true

  progress: (e, data)->
    percent = Math.round((e.loaded / e.total) * 100)
    console.log 'progress', percent

  fail: (e, data) ->
    console.log 'fail', e, data

  success: (data) ->
    # Find location value from XML response
    content = decodeURIComponent $(data).find('Location').text()
    # file_name = content.split('/').pop()
    # { x, y } = locations[file_name]
    emitNewArticle content, collectionKey