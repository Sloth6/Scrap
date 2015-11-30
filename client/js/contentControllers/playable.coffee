# Every playable type passes the function for creating its iframe
# All .playable types must have a preview and header
bindPlayableControls = ($content, getIframe) ->
  preview = $content.find '.preview'
  header  = $content.find 'header'

  unless preview.length
    throw 'playable object does not have preview'+ $content[0]

  unless header.length
    throw 'playable object does not have header'+ $content[0]
  
  #Load iframe, hide preview
  $content.click () ->
    unless $content.hasClass 'playing'
      getIframe($content).insertBefore preview
      preview.hide()
      $content.addClass 'playing'
      
  #Remove iframe, show preview
  header.click (event) ->
    if $content.hasClass 'playing'
      stopPlaying $content
      event.stopPropagation()

stopPlaying = ($content) ->
  $content.removeClass 'playing'
  $content.find('iframe').remove()
  $content.find('.preview').show()
