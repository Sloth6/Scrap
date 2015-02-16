'use strict'
cardDom = (content, contentType) ->
  switch contentType
    when 'image'
      "<img src=https://s3-us-west-2.amazonaws.com/scrapimagesteamnap/#{spaceKey}/small/#{content}>"
    when 'temp_image'
      "<img src=#{content}>"
    when 'website'
      data = JSON.parse content
      url = decodeURIComponent data.url
      "<a href=\"#{url}\" target=\"_blank\">" +
        (if data.image? then "<div class='card image'><img src=\"#{data.image}\"></div>" else '')+
        "<div class='header card text'>
            <div class='title'>
              <p>#{data.title}</p>
            </div>
            <div class='url'>
              <p>#{data.domain}</p>
            </div>
            <div class='description'>
              <p>#{data.description}</p>
            </div>
         </div>
      </a>"
    else "<p>#{content}</p>"
  

createNewElement = (element) ->
  { content, contentType, creatorId, id, x, y, z, scale } = element
  console.log 'NEW ELEMENT CONTENT', content, contentType

  x += totalDelta.x
  y += totalDelta.y
  # {cardDom content, contentType}
  classes = "#{contentType} draggable color#{colors[element.creatorId]}"
  newArticle =
    $("<article class='#{classes}' id='#{id}'>
      <header>
        <a class='delete'></a>
        <author>#{names[creatorId]}</author>
      </header>
      <div class='card #{contentType}'>
        #{cardDom content, contentType }
        </div>
      </div>
    <div class='ui-resizable-handle ui-resizable-se'>
    </article>")
  if contentType is 'text'
    newArticle.children('.card').addClass('comment')
  # console.log newArticle
  $('.content').append newArticle
  newArticle.css {
    top:y
    left:x
    'z-index':z
    "-webkit-transform-origin": "top left"
    "transform-origin": "top left"
    scale: scale
  }
  

  newArticle.children('header').css {
    scale: 1/element.scale
  }
  console.log newArticle.children('header').css()
  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  scaleControls newArticle

  newArticle.on 'click', ->
    $(window).trigger 'mouseup'
    $('.ui-resizable-handle', "\##{id}").on 'mousedown', resize socket

  updateGlobals element