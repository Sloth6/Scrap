lengthForLong = 400

formatText = (elems) ->
  elems.each () ->
    editable = $(@).find('.editable')
    if editable.text().length < lengthForLong and !$(@).hasClass('short')
      $(@).addClass('short').removeClass('long')
      realign()
    
    else if editable.text().length > lengthForLong and !$(@).hasClass('long')
      $(@).addClass('long').removeClass('short')
      realign()

$ ->
  editable = $('.editable')
  
  # formatText $('.article.text')

  editable.on 'blur', () ->
    #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
    $('<div contenteditable="true"></div>').appendTo('body').focus().remove()

