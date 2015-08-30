$ ->
  editable = $('.editable')
  editable.on 'blur', () ->
    #http://stackoverflow.com/questions/12353247/force-contenteditable-div-to-stop-accepting-input-after-it-loses-focus-under-web
    $('<div contenteditable="true"></div>').appendTo('body').focus().remove()