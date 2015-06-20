webshot = require 'webshot'
s3 = require '../adapters/s3.coffee'

debounce = (wait, func) ->
	timeout = null
	() ->
		clearTimeout timeout
		timeout = setTimeout func, wait

space_timeouts = {}

options =
	windowSize:
		width: 900
		height: 600
	streamType: 'jpg'
	customCSS: ".form {
								visibility:hidden;
							}"
	phantomConfig:
		'load-images': 'true'

module.exports = (spaceKey) ->
	if space_timeouts[spaceKey]
		space_timeouts[spaceKey]()
	else
		space_timeouts[spaceKey] = debounce 4000, () ->
			url = "http://localhost:9001/s/#{spaceKey}"
			console.time('new webshot')
			webshot url, options, (err, stream) ->
				if err?
					return console.log 'Err in webshot', err
				s3.uploadSpacePreview { spaceKey, stream }, (err) ->
					console.timeEnd('new webshot')
					if err?
						console.log 'err in upload space preview', err
				