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
  classes = "#{contentType} draggable color#{colors[element.creatorId]}"

  newArticle =
    $("<article class='#{classes}' id='#{id}'>
      <header data-scale=#{1/scale}>
        <a class='delete'></a>
        <author>#{names[creatorId]}</author>
      </header>
      <div class='card #{contentType}'>
        #{cardDom content, contentType }
        </div>
      </div>
    <div class='resize ui-resizable-handle ui-resizable-se' data-scale=#{1/scale}>
    </article>")
  if contentType is 'text'
    newArticle.children('.card').addClass('comment')
  $('.content').append newArticle
  newArticle.css {
    top:y
    left:x
    'z-index':z
    scale: scale
  }
  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  makeModifiable newArticle
  makeResizeable newArticle, socket
  newArticle