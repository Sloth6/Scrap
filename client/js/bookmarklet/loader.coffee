host = 'https://localhost/' # 'https://tryscrap.com/'
iframe_url = host + 'bookmarkletContent'

iframe = document.createElement 'iframe'
iframe.allowtransparency = true
iframe.id = 'scrap_iframe'
iframe.src = host+'bookmarkletContent?referrer='+window.location
iframe.style.top = '0px'
iframe.style.left = '0px'
iframe.style.position = 'fixed'
iframe.style.width = '100vw'
iframe.style.height = '100vh'
iframe.style.border = '0'
iframe.style.opacity = '0'
iframe.style.overflow = 'hidden'

document.body.appendChild(iframe)
setTimeout ->
  iframe.style.opacity = '1'
, 250

receiveMessage = (event) ->
  if event.data == 'removetheiframe'
    document.body.removeChild iframe

stopScroll = (event) ->
  window.body.style.overflow = 'hidden'  
  
startScroll = (event) ->
  window.body.style.overflow = ''
    
window.addEventListener "message", receiveMessage, false
window.addEventListener "stopScroll", stopScroll, false
window.addEventListener "startScroll", startScroll, false