$ -> 
  initArticle $("article")
  initContainer $( constants.dom.articleContainer )
  
obscureArticles = ($articles) ->
  $contents   = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
  options     =
    duration: constants.style.duration.openArticle
    easing:   constants.velocity.easing.smooth
  $contents.velocity
    properties:
      opacity: 0
    options: options
  $articles.addClass 'obscured'
    
unobscureArticles = ($articles) ->
  $contents = $articles.find('.card').children().add($(constants.dom.articleContainer).find('article ul, article .articleControls'))
  options     =
    duration: constants.style.duration.openArticle
    easing:   constants.velocity.easing.smooth
  $contents.velocity
    properties:
      opacity: 1
    options: options
  $articles.removeClass 'obscured'

window.initArticle = ($articles) ->
  $articles.each ->
    $firstLabel = $(@).find('ul.articleCollections li.collection').first().find('a')
    $(@).css
      marginTop:  12 + Math.random() * constants.style.gutter
      marginLeft: 12 + Math.random() * constants.style.gutter
    if $firstLabel.length and $(@).hasClass('text') or $(@).hasClass('website') 
      $backgroundColor = $('<div></div>').prependTo($(@).find('.card')).css
        backgroundColor: $firstLabel.css('background-color')
        position: 'absolute'
        top: 0
        left: 0
        right: 0
        bottom: 0
        opacity: .25
    # init contenttype
    switch $(@).data 'contenttype'
      when 'text'       then initText $(@)
      when 'video'      then initVideo $(@)
      when 'file'       then initFile $(@)
      when 'soundcloud' then initSoundCloud $(@)
      when 'youtube'    then initYoutube $(@)
    
  
  $articles.droppable
    greedy: true
    hoverClass: "hovered"
    over: (event, object) ->
      events.onCollectionOverArticle $(@), event, object.draggable
    out: (event, object) ->
      events.onCollectionOutArticle $(@), event, object.draggable
    drop: ( event, ui ) ->
      $collection = ui.draggable.clone()
      $collection.css 'top':0, 'left':0
      $.Velocity.hook($collection.find('.contents'), 'translateY', "0px")
      init.collection $collection
      $collection.show()
      articleModel.addCollection $(@), $collection
      event.stopPropagation()
      true
  
  $articles.click ->
    unless $(@).hasClass 'open'
      events.onArticleOpen event, $(@)
      $article = $(@)
      $('body').click (event) ->
        events.onArticleClose(event, $article) unless $article.is(':hover')
  $articles.mouseenter -> events.onArticleMouseenter event, $(@)
  $articles.mousemove  -> events.onArticleMousemove  event, $(@)
  $articles.mouseleave -> events.onArticleMouseleave event, $(@)
  $articles.each ->
#       events.onArticleResize  $(@)
    events.onArticleLoad    $(@)
    
  $articles.find('img').load () -> 
    events.onArticleResize $(@)
    
  parallaxHover $articles
    
window.initContainer = ($container) ->
  $container.packery
    itemSelector: 'article'
    isOriginTop: true
    transitionDuration: '0.5s'
    gutter: 0 #constants.style.gutter

  $container.packery 'bindResize'

  $container.droppable
    greedy: true
    drop: (event, ui) ->
      $collection = ui.draggable
      articleModel.removeCollection $collection.parent().parent(), $collection
  $container.css
    width: "#{100/constants.style.globalScale}%"
  $container.velocity
    properties:
      translateZ: 0
      scale: constants.style.globalScale
    options:
      duration: 1
