max = 35

# binding keyup/down events on the contenteditable div
check_charcount = ($elem, e) ->
  console.log e.which
  # if e.which
 
addCollection = () ->
  # $.post '/s/new', {collection:{ name }}, (dom) ->
  #   collection = $(dom)

addProjectController =
  init: ($elem) ->
    $elem.data 'sent', false
    $elem.click () ->
      title  = $elem.find('.collectionTitle')
      card   = $elem.children('.card')
      $elem.find('h1,h2,h3,h4').text('')
      card.addClass 'editing'
      card.addClass 'hover'
      $elem.addClass 'slideInFromSide'
      $elem.addClass 'typing'
      title.attr('contenteditable', true).focus()
      # $elem.keyup (e) -> check_charcount $elem, e
      $elem.keydown (e) ->
        if e.which == 13
          e.preventDefault()
          return if $elem.data('sent')
          $elem.data 'sent', true
          title.attr('contenteditable', false)
          card.removeClass 'editing'
          card.removeClass 'hover'
          socket.emit 'newPack', { name: title.text() }
        else if e.which != 8 && $elem.text().length > max
          e.preventDefault()
      console.log 'init', $elem
#     $elem.mouseleave () ->
    $('body').click (event) ->
      event.stopPropagation()
      addProjectController.reset $elem

  reset: ($elem) ->
    title  = $elem.find('.collectionTitle')
    card   = $elem.children('.card')
    $elem.removeClass 'slideInFromSide'
    $elem.removeClass 'typing'
    title.text $elem.data('defaulttext')
    $elem.data('sent', false)
