cardDom = (content, contentType) ->
  console.log contentType
  switch contentType
    # when 'image'
    #   "<img src=https://s3-us-west-2.amazonaws.com/scrapimagesteamnap/#{spaceKey}/small/#{content}>"
    when 'image'
      "<img src=#{content}>"
    when 'gif'
      "<canvas></canvas>"
    when 'file'
      url = decodeURIComponent content
      title = url.split('/').pop()
      "<img src=https://cdn3.iconfinder.com/data/icons/brands-applications/512/File-512.png>"+
      "<div class='header card text'>" +
        "<div class='title'>"+
            "<p>#{title}</p>"+
          "</div>"+
       "</div>"

    when 'video'
      "<video controls>"+
        "<source src=#{content}>"+
      "</video>"

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
         </div>
      </a>"
    else "<p>#{content}</p>"
  
createNewElement = (element) ->
  { content, contentType, creatorId, id, x, y, z, scale } = element
  scale = 1.0
  console.log 'NEW ELEMENT CONTENT', content, contentType

  x += totalDelta.x
  y += totalDelta.y
  classes = "#{contentType} draggable color#{colors[element.creatorId]}"
  if contentType is 'text'
    classes += if content.length >= longText then " long" else " short"

  newArticle =
    $("<article class='#{classes}' id='#{id}'>
        <div class='card #{contentType}'>
          <header data-scale=#{1/scale}>
            <author>#{names[creatorId]}</author>
          </header>
        #{cardDom content, contentType }
        </div>
    </article>")
  
  switch contentType
    when 'text'
      newArticle.children('.card').addClass('comment')
    when 'gif'
      createGif newArticle, content
    when 'file'
      makeDownloadable newArticle

  newArticle.css({
    top:y
    left:x
    'z-index':z
    scale: scale
  }).data({
    content: content  
  }).appendTo $('.content')
  
  makeDeletable newArticle
  makeTextChild newArticle
  makeDraggable newArticle, socket
  makeModifiable newArticle
  makeResizeable newArticle, socket
  
  newArticle