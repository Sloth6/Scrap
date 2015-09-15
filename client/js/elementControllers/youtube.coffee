bindYoutubeControls = (elems) ->
    elems.each(() ->
        elem = $(@)
        elem.data 'contentPlaying', false
        content = $(@).data('content')
        id = content.id
        url = "http://www.youtube.com/embed/#{id}?autoplay=1"
        preview = $(@).find('.preview')
        header = $(@).find('header')
        
#       Load iframe, hide preview
        elem.click () ->
            if !(elem.data('contentPlaying'))
                $('<iframe>').attr({'src': url, width:560, height:315, frameborder: "0", allowfullscreen: true}).insertBefore preview
                preview.hide()
                elem.data 'contentPlaying', true
                
#       Remove iframe, show preview
        header.click (event) ->
            if elem.data('contentPlaying')
                stopPlaying(elem)
                event.stopPropagation()
    )

stopPlaying = (elem) ->
    elem.data 'contentPlaying', false
    elem.find('iframe').remove()
    elem.find('.preview').show()