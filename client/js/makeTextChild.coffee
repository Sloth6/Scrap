makeTextChild = (elem) ->
  screenScale = $('.content').css 'scale'
  pos = 
    left: parseFloat(elem.css('left')) * screenScale
    top: parseFloat(elem.css('top')) * screenScale
  console.log elem[0], pos