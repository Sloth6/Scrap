lengthForLong = 500

formatText = (elems) ->
  elems.each () ->
    # console.log $(@).text().length, $(@).text().length < lengthForLong
    editable = $(@).find('.editable')
    # console.log editable.text().length
    if editable.text().length < lengthForLong and !$(@).hasClass('short')
      # console.log $(@).width()
      $(@).addClass('short').removeClass('long')
      # console.log $(@).find('.card').width(), '\n'
      realign()
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      # console.log $(@).width()
      $(@).addClass('long').removeClass('short')
      # console.log $(@).find('.card').width(), '\n'
      realign()

$ ->
  editable = $('.editable')
  
  # formatText $('.article.text')

  editable.on 'blur', () ->
    #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
    $('<div contenteditable="true"></div>').appendTo('body').focus().remove()

