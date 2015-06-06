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
	console.time('new webshot')
	webshot url, options, (err, stream) ->
		if err?
			return console.log 'Err in webshot', err
		s3.uploadSpacePreview { spaceKey, stream }, (err) ->
			console.timeEnd('new webshot')
			if err?
				console.log 'err in upload space preview', err
			