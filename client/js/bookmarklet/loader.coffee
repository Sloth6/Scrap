host = 'http://tryscrap.com/'
iframe_url = host + 'bookmarkletContent'

iframe = document.createElement 'iframe'
iframe.allowtransparency = true
iframe.id = 'scrap_iframe'
iframe.src = host+'bookmarkletContent?referrer='+window.location
iframe.style.top = '0px'
iframe.style.left = '0px'
iframe.style.position = 'fixed'
iframe.style.width = '100%'
iframe.style.height = '100%'
iframe.style.border = '0'

document.body.appendChild(iframe)

receiveMessage = (event) ->
    if event.data == 'removetheiframe'
        document.body.removeChild iframe

window.addEventListener "message", receiveMessage, false
