webshot = require 'webshot'
s3 = require '../adapters/s3.coffee'

options =
	windowSize:
		width: 600
		height: 400
	streamType: 'jpg'
	customCSS: ".form {
								visibility:hidden;
							}"
	phantomConfig:
		'load-images': 'true'


module.exports = (spaceKey) ->
	url = "http://localhost:9001/s/#{spaceKey}"
	webshot url, options, (err, stream) ->
		if err?
			return console.log 'Err in webshot', err
		console.log 'new webshot', spaceKey
		s3.uploadSpacePreview { spaceKey, stream }