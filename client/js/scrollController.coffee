window.onScroll = () ->
  scrollTop = $(window).scrollTop()
  scrollBottom = $(document).height() - $(window).height() - scrollTop

  # detect direction change
  if window.oldScrollTop isnt scrollTop
    if window.oldScrollTop < scrollTop
      if window.scrollDirection isnt 'down'
        onChangeScrollDirection 'down'
    else
      if scrollDirection isnt 'up'
        onChangeScrollDirection 'up'
    window.oldScrollTop = scrollTop

  if scrollTop <= 10
    extendNav() unless $('nav').children().hasClass('velocity-animating')
  else
    unless window.scrollDirection is 'up'
      retractNav() unless $('nav').children().hasClass('velocity-animating')

  if scrollBottom < 200
    return if scrapState.waitingForContent
    scrapState.waitingForContent = true
    o = $('article').not('.addArticleForm').length
    n = 20
    console.log {o, n}
    $.get('collectionContent', {o, n}).
      fail(() -> 'failed to get content').
      done (data) ->
        for foo in $(data)
          $( constants.dom.articleContainer ).append $(foo)
          articleController.init $(foo)
          $( constants.dom.articleContainer ).packery('appended', $(foo))
        scrapState.waitingForContent = false



window.onChangeScrollDirection = (direction) ->
  window.scrollDirection = direction
  if $(window).scrollTop() > 10
    if direction is 'up'
      extendNav()
    else
      retractNav()

$ ->
  window.oldScrollTop     = 0
  window.scrollDirection  = 'down'

  $(window).scroll -> onScroll()
  onScroll()
