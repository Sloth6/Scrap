    # some things we need in here
host = 'http://localhost:9001/'
iframe_url = host + 'bookmarkletContent'
head = document.getElementsByTagName('head')[0]


# load a javascript file
# loadJs = (src) ->
#     js = document.createElement('script')
#     js.type = 'text/javascript'
#     js.src = src
#     js.async = true
#     head.appendChild(js)

# if jquery does not exist, load it
# and callback when jquery is loaded
# loadJquery = (cb) ->
#     # always load jquery because they might have
#     # a prototyped version on page
#     loadJs(host + 'js/jquery/jquery.js')
#     # start checking every 100ms to see
#     # if the jQuery object exists yet
#     id = setInterval (() ->
#         if window.jQuery
#             window.$ = window.jQuery
#             clearInterval id
#             return cb()
#     ), 100


iframe = document.createElement('iframe')
iframe.allowtransparency = true
iframe.id = 'scrap_iframe'
iframe.src = 'http://localhost:9001/bookmarkletContent?referrer='+window.location
iframe.style.top = '0px'
iframe.style.left = '0px'
iframe.style.position = 'absolute'
iframe.style.width = '100%'
iframe.style.height = '100%'
iframe.style.border = '0'

document.body.appendChild(iframe)

receiveMessage = (event) ->
    if (event.data == 'removetheiframe')
        document.body.removeChild(iframe)

window.addEventListener("message", receiveMessage, false)


# parent.removeChild(child);

# load jquery
# loadJquery () ->
#     console.log 'jquery loaded'
#     console.log $('li.collection')
#     $(element).attr('allowtransparency', true)
#     $('li.collection').click () ->
#         console.log @