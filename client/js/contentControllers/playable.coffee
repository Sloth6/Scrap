# Every playable type passes the function for creating its iframe
# All .playable types must have a $preview and header
bindPlayableControls = ($article, getIframe) ->
  $preview    = $article.find '.preview'
  $header     = $article.find 'header'
  $playButton = $article.find '.playButton'

  unless $preview.length
    throw 'playable object does not have preview'+ $article[0]

  unless $header.length
    throw 'playable object does not have header'+ $article[0]
  
  #Load iframe, hide preview
  $article.click () ->
    unless $article.hasClass 'playing'
      getIframe($article).insertBefore $preview
      $preview.hide()
      $playButton.hide()
      $article.addClass 'playing'

stopPlaying = ($article) ->
  $article.removeClass 'playing'
  $article.find('iframe').remove()
  $article.find('.playButton').show()
  $article.find('.preview').show()
