bindYoutubeControls = (elems) ->
    elems.click () ->
        content = elems.data('content')
        id = content.id
        url = "http://www.youtube.com/embed/#{id}?autoplay=1"
        preview = $(@).find('.preview')
        console.log preview
        $('<iframe>').attr({'src': url, width:560, height:315, frameborder: "0", allowfullscreen: true}).insertBefore preview
        preview.hide()

# 	elem.find('.iframeBlocker').click () ->
# 		$(@).siblings('iframe').trigger 'click'
