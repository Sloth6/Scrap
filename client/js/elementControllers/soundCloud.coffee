bindSoundCloudControls = (elems) ->
  elems.mousedown (e) ->
    # $(@).data 'lastX', e.clientX
    # $(@).data 'lastY', e.clientY

  elems.click (e) ->
    # return if $(@).data('lastX') != e.clientX
    # return if $(@).data('lastY') != e.clientY

    if $(@).find('iframe').length
      SC.Widget($(@).find('iframe')[0]).toggle()
    else
      img = $(@).find('img')
      iframe = $($(@).data('content').html)
      iframe.load () ->
        widget = SC.Widget(@)
        widget.bind SC.Widget.Events.READY, () ->
          SC.Widget(iframe[0]).toggle()
      
      iframe.insertBefore img
      img.hide()
      $(@).find('header').hide()

$ ->
  bindSoundCloudControls $('.element.soundcloud')