validate = ({ name, password, email }) ->
  if !(name or password or email)
    alert "Enter something to change"
    return false
  
  if name and name.match(/^[a-zA-Z]{2,} [a-zA-Z]{2,}$/i) is null
    alert "Enter a full name"
    return false

  if email and email.match(/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i) is null
    alert "Enter a valid email"
    return false

  return true

$ ->
  $('.menu.settings form').submit (event) ->
    event.preventDefault()
    name = $(@).find('.name').val()
    password = $(@).find('.password').val()
    email = $(@).find('.email').val()

    forms = {}
    forms.name = name if name?
    forms.password = password if password?
    forms.email = email if email?

    # return
    if not validate(forms)
      return

    $(@).find('input').not(':button').val('')

    done = () ->
      $('html').trigger('click')
      $('.menu.settings .userName').text name
      # alert('Updated successfully.')
      # $("li.hideOnOpenSubmenu").removeClass("hidden")
      # $("ul.menu.changeUserInfo").addClass("hidden")

    fail = () ->
      alert 'Ooops, there was an error.'
      $('html').trigger('click')

    $.post('/updateUser', {userId, name, email}).done(done).fail(fail)


