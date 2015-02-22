createGif = (article, url) ->
  gif = $('<img/>')
  card = article.children '.card'
  canvas = article.find 'canvas'

  gif.bind 'load', () ->
    card.prepend gif
    width = gif.width()
    height = gif.height()
    canvas.attr { width, height }
    ctx = canvas[0].getContext "2d"
    ctx.drawImage gif[0], 0, 0, width, height
    gif.remove()

  gif.attr { src: url }
  makeInteractive article, gif

makeInteractive = (article, gif) ->
  card = article.children '.card'
  gif_frame = if card.find('canvas').length
                card.find('canvas')
              else card.find('img')

  article.mouseenter () ->
    card.prepend gif
    gif_frame.remove()
    card.addClass 'animated'
    
  article.mouseout () ->
    card.prepend gif_frame
    gif.remove()
    card.removeClass 'animated'
  
$ ->
  $('article.gif').each () ->
    key = $(this).children('.card').data('key')
    root = "https://s3-us-west-2.amazonaws.com/scrapimagesteamnap/"
    url = "#{root}#{spaceKey}/gif/#{key}.gif"
    gif = $('<img/>').attr { src: url }
    makeInteractive $(this), gif