createLoadingElement = (position, name) ->
  # console.log 'loading name', name
  html = "<article class=loading>
            <div class='card'>
              <header data-scale=#{1}>
                <author>#{creator}</author>
              </header>
            <div class='loadingIndicator'></div>
            </div>
          </article>"
  $(html).
  css({
    top: position.y
    left: position.x
    'z-index': 10
    scale: 1
    width: 200
    height: 200
    'background-image': 'url("http://thinkfuture.com/wp-content/uploads/2013/10/loading_spinner.gif")'
    'border-style': 'solid'
    'border-width': 2
  }).
  addClass(name).
  appendTo($('.content'))
  # data({ content }).
  