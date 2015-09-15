bindYoutubeControls = (elems) ->
  bindPlayableControls elems, (elem) ->
    # define how to create the iframe for youtubes
    id = elem.data('content').id
    src = "http://www.youtube.com/embed/#{id}?autoplay=1"
    attr = { src, width:560, height:315, frameborder: "0", allowfullscreen: true }
    $('<iframe>').attr attr
