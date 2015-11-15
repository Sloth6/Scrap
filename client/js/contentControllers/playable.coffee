# Every playable type passes the function for creating its iframe
# All .playable types must have a preview and header
bindPlayableControls = (elems, getIframe) ->
  elems.each () ->
    elem = $(@)
    elem.data 'contentPlaying', false
    preview = $(@).find '.preview'
    header  = $(@).find 'header'

    unless preview.length
      throw 'playable object does not have preview'+ elem[0]

    unless header.length
      throw 'playable object does not have header'+ elem[0]
    
    #Load iframe, hide preview
    elem.click () ->
      if !elem.data('contentPlaying')
        getIframe(elem).insertBefore preview
        preview.hide()
        elem.data 'contentPlaying', true
        
    #Remove iframe, show preview
    header.click (event) ->
      if elem.data 'contentPlaying'
        stopPlaying elem
        event.stopPropagation()

stopPlaying = (elem) ->
  elem.data 'contentPlaying', false
  elem.find('iframe').remove()
  elem.find('.preview').show()
