jade = require 'jade'
jadeFn = jade.compileFile __dirname+'/../../views/partials/inviteEmail.jade'
module.exports = (user, collection) ->
  creator = collection.Creator
  domain  = 'http://tryScrap.com'
  title   = "<a href=\"#{domain}/s/#{collection.collectionKey}\">#{collection.name}</a>"
  subject = "#{creator.name} invited you to “#{collection.name}” on Scrap"  
  html    = jadeFn({user, collection})
  { html, subject }