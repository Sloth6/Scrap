$ ->
    menu = $('ul.menu')
    space = $('section.blur')
    mask = $('<div class=\'mask\'></div>')
    inputIsFocused = false
    subMenuIsOpen = false
    canCloseMenu = false

    toggleMenu = (to) ->
        if to == 'open'
            $(menu).addClass 'open'
            space.addClass 'obscured'
            $('section.container').prepend mask
            $('.mask').click ->
                toggleMenu 'close'
        else # close
            $(menu).removeClass 'open'
            space.removeClass 'obscured'
            mask.remove()
            resetSubmenu()
            canCloseMenu = false

    resetSubmenu = ->
        $('ul.submenu li').addClass 'hidden'
        $('li.hideOnOpenSubmenu').removeClass 'hidden'
        menu.removeClass('wide')
        menu.removeClass('paddingBottom')
        inputIsFocused = false
        subMenuIsOpen = false

    menu.children("li:first-child").mouseenter ->
        if inputIsFocused or subMenuIsOpen
            return
        else
            toggleMenu 'open'
            setTimeout(()->
                canCloseMenu = true
            , 500)

    menu.mouseleave ->
        # if no inputs are focused and no submenus are open
        if inputIsFocused or subMenuIsOpen
            return
        else
            if canCloseMenu
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
        menu.addClass('wide paddingBottom')
        console.log 'subMenuIsOpen'

    $('ul.menu li.backButton').click ->
        resetSubmenu()