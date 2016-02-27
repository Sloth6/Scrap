window.contentControllers ?= {}
contentControllers['soundcloud'] =
  canZoom: true
  init: ($article) ->
    bindPlayableControls $article, (elem) ->
      # define how to create the iframe for soundcloud
      iframe = $(elem.data('content').html)
      # manually add autoplay to iframe src
      src = decodeURIComponent(iframe.attr('src')) + '&auto_play=true'
      iframe.attr { src }

  # close:

# old sc widget code

# SC.Widget($(@).find('iframe')[0]).toggle()
# iframe.load () ->
#   widget = SC.Widget(@)
#   widget.bind SC.Widget.Events.READY, () ->
#     SC.Widget(iframe[0]).toggle()
