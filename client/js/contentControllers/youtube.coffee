initYoutube = (elems) ->
  bindPlayableControls elems, (elem) ->
#   Define how to create the iframe for youtube videos
    id = elem.data('content').id
    src = "http://www.youtube.com/embed/#{id}?autoplay=1"
#   Dimensions must mach those in article.jade
    attr = { src, width:480, height:270, frameborder: "0", allowfullscreen: true }
    $('<iframe>').attr attr
