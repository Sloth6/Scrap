validate = (name, password, email) ->
  if name + password + email is ''
    alert "Enter something to change"
    return false
  
  if name.match(/^[a-zA-Z]{2,} [a-zA-Z]{2,}$/i) is null
    alert "Enter a full name"
    return false

  if email.match(/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i) is null
    alert "Enter a valid email"
    return false

  return true

$ ->
  menu = $('.menu.settings')
  saveButton = menu.find(':button')
  saveButton.off 'click'
  saveButton.click () ->
    name = menu.find('.name').val()
    password = menu.find('.password').val()
    email = menu.find('.email').val()

    if not validate(name, password, email)
      return

    menu.find('input').not(':button').val('')

    done = () ->
      alert('Updated successfully.')
      $('.menu.settings .userName').text name
      # $("li.hideOnOpenSubmenu").removeClass("hidden")
      # $("ul.menu.changeUserInfo").addClass("hidden")

    fail = () ->
      alert 'Ooops, there was an error.'

    $.post('/updateUser', {userId, name, email}).done(done).fail(fail)


