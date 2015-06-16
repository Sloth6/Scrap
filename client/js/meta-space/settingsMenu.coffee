validate = (name, password, email) ->
  if name + password + email is ''
    alert( "Enter something to change")
    return false
  return true

$ ->
  menu = $('ul.menu.submenu')
  saveButton = $("ul.menu.submenu li.closeButton")
  saveButton.off 'click'
  saveButton.click () ->
    name = menu.find('.name').val()
    password = menu.find('.password').val()
    email = menu.find('.email').val()
    menu.find('input').not(':button').val('')

    if not validate(name, password, email)
      return

    fail = () ->
      alert('Updated successfully.')
      $('.menu.settings .userName').text name
      $("li.hideOnOpenSubmenu").removeClass("hidden")
      $("ul.menu.changeUserInfo").addClass("hidden")

    fail = () ->
      alert 'Ooops, there was an error.'

    $.post('/updateUser', {userId, name, email}).done(fail).fail(fail)


