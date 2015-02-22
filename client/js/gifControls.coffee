makeInteractive = (article, url) ->
  gif = $('<img/>')
  card = article.children('.card')
  canvas = article.find('canvas')

  gif.bind 'load', () ->
    card.prepend gif
    width = gif.width()
    height = gif.height()
    console.log height
    canvas.attr { width, height }
    ctx = canvas[0].getContext "2d"
    ctx.drawImage gif[0], 0, 0, width, height
    gif.remove()
    
  article.mouseover () ->
    card.prepend gif
    canvas.remove()
    

  article.mouseout () ->
    card.prepend canvas
    gif.remove()
  
  gif.attr { src: url }