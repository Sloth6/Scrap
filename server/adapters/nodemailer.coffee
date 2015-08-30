nodemailer = require 'nodemailer'

# create reusable transporter object using SMTP transport
transporter = nodemailer.createTransport {
  service: 'Gmail'
  auth:
    user: 'scrapspaces@gmail.com'
    pass: 'olabs123'
  }

module.exports = 
  send: (options, callback) ->
    callback ?= ()->
    options.from = 'scrapspaces@gmail.com'
    transporter.sendMail options, (err, message) ->
      if err?
        console.log "Failed to send email:"+err
        callback err
      else 
        console.log 'Email sent'
        callback null

# mailOptions =
#   from: 'Fred Foo ✔ <foo@blurdybloop.com>' # sender address
#   to: 'joelsimon6@gmail.com' # list of receivers
#   subject: 'Hello ✔' # Subject line
#   text: 'Hello world ✔' # plaintext body
#   html: '<b><p>Hello world<p></b>' # html body

# # send mail with defined transport object
