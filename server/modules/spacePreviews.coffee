webshot = require 'webshot'
s3 = require '../adapters/s3.coffee'

options =
	windowSize:
		width: 300
		height: 200
	streamType: 'jpg'
	customCSS: ".form {
								visibility:hidden;
							}"
	phantomConfig:
		'load-images': 'false'


module.exports = (spaceKey) ->
	url = "http://localhost:9001/s/#{spaceKey}"
	webshot url, options, (err, stream) ->
		return console.log err if err?
		s3.uploadSpacePreview { spaceKey, stream }