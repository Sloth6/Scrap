nodemailer = require 'nodemailer'
config = require('../config.json')

# create reusable transporter object using SMTP transport
transporter = nodemailer.createTransport {
  service: 'Gmail'
  auth:
    user: config.MAIL.user
    pass: config.MAIL.pass
}

module.exports =
  send: (options, callback) ->
    callback ?= ()->
    options.from = 'scrapcollections@gmail.com'
    transporter.sendMail options, (err, message) ->
      if err?
        console.log "Failed to send email:"+err
        callback err
      else
        console.log 'Email sent'
        callback null
