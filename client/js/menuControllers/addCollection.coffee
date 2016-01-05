max = 35
 
window.initAddCollection = ($elem) ->
  $done   = $elem.find '.done'
  $cancel = $elem.find '.cancel'
  $title = $elem.find '.collectionTitle'
  $card  = $elem.children '.card'

  $elem.data 'sent', false

  reset = (event) ->
    event.preventDefault()
    event.stopPropagation()
    $elem.removeClass 'slideInFromSide'
    $elem.removeClass 'typing'
    $elem.data('sent', false)
    $title.text $elem.data('defaulttext')
    $('body').add($cancel).off 'click', reset
    $title.focusout()
    $done.off 'click', submit

  submit = (event) ->
    event.preventDefault()
    $elem.data 'sent', true
    $title.attr 'contenteditable', false
    $card.removeClass 'editing'
    $card.removeClass 'hover'
    socket.emit 'newPack', { name: $title.text() }
    reset(event)

  startEditing = () ->
    event.stopPropagation()
    $elem.find('h1,h2,h3,h4').text('')
    $card.addClass 'editing'
    $card.addClass 'hover'
    $elem.addClass 'slideInFromSide'
    $elem.addClass 'typing'
    $title.attr('contenteditable', true).focus()

    $elem.on 'keydown', (e) ->
      if e.which == 13
        if $elem.data('sent')
          e.preventDefault()
        else
          submit e
      else if e.which != 8 && $elem.text().length > max
        e.preventDefault()

    $('body').add($cancel).on 'click', reset
    $done.on 'click', submit

  $elem.click startEditing
