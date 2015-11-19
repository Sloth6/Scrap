max = 35

# binding keyup/down events on the contenteditable div
check_charcount = (elem, e) ->
  console.log e.which
  # if e.which
 
addCollection = () ->
  # $.post '/s/new', {space:{ name }}, (dom) ->
  #   collection = $(dom)

addProjectController =

  init: (elem) ->
    elem.data 'sent', false
    elem.click () ->
      title  = elem.find('.collectionTitle')
      card   = elem.children('.card')
      elem.find('h1,h2,h3,h4').text('')
      card.addClass 'editing'
      card.addClass 'hover'
      title.attr('contenteditable', true).focus()

      # elem.keyup (e) -> check_charcount elem, e
      elem.keydown (e) ->
        if e.which == 13
          e.preventDefault()
          return if elem.data('sent')
          elem.data 'sent', true
          title.attr('contenteditable', false)
          card.removeClass 'editing'
          card.removeClass 'hover'
          socket.emit 'newPack', { name: title.text() }

        else if e.which != 8 && elem.text().length > max
          e.preventDefault()

  reset: (elem) ->
    title  = elem.find('.collectionTitle')
    card   = elem.children('.card')
    title.text elem.data('defaulttext')
    elem.data('sent', false)