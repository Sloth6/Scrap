bindYoutubeControls = (elems) ->
	elem.find('.iframeBlocker').click () ->
		$(@).siblings('iframe').trigger 'click'
