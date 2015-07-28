$ ->
    menu = $('ul.menu')
    space = $('section.blur')
    mask = $('<div class=\'mask\'></div>')
    inputIsFocused = false
    subMenuIsOpen = false

    toggleMenu = (to) ->
        if to == 'open'
            $(menu).addClass 'open'
            space.addClass 'obscured'
            $('section.container').prepend mask
            $('.mask').click ->
                toggleMenu 'close'
        else
            $(menu).removeClass 'open'
            space.removeClass 'obscured'
            mask.remove()
            resetSubmenu()

    resetSubmenu = ->
        $('ul.submenu li').addClass 'hidden'
        $('li.hideOnOpenSubmenu').removeClass 'hidden'
        menu.removeClass('wide')
        inputIsFocused = false
        subMenuIsOpen = false

    menu.mouseenter ->
        if inputIsFocused or subMenuIsOpen
            console.log 'cantopenMenu'

        else
            console.log 'openMenu'
            toggleMenu 'open'

    menu.mouseleave ->
        # if no inputs are focused and no submenus are open
        if inputIsFocused or subMenuIsOpen
            return
        else
            console.log 'closeMenu'
            toggleMenu 'close'

    menu.find('input').focus ->
        inputIsFocused = true
        toggleMenu 'open'

    # Settings menu
    $('li.update').click ->
        inputIsFocused = true
        subMenuIsOpen = true
        $('ul.submenu li.hidden').removeClass 'hidden'
        $('li.hideOnOpenSubmenu').addClass 'hidden'
        menu.addClass('wide')
        console.log 'subMenuIsOpen'

    $('ul.menu li.backButton').click ->
        resetSubmenu()