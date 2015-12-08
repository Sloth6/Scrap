require('fs').readdirSync(__dirname + '/').forEach (file) ->
  if file.match(/\.coffee$/)? and file != 'index.coffee'
    name = file.replace '.coffee', ''
    exports[name] = require "./#{file}"