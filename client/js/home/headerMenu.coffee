$ ->
    $('ul.menu').each () ->
        menu    = $(@)
        $blur   = if (menu.hasClass('users')) then $('.blur.blurThisCollection') else $('.blur.blurAllCollections')
        mask    = $('<div class=\'mask\'></div>')
        inputIsFocused  = false
        subMenuIsOpen   = false
        canCloseMenu    = false
    
        toggleMenu = (to) ->
            if to == 'open'
                menu.addClass 'open'
                $blur.addClass 'obscured'
#                 $blur.prepend mask
                $('html').click ->
                    zIndex = 99999# if (menu.hasClass('users')) then 40 else 40
                    $(@).css 'z-index', zIndex
                    toggleMenu 'close'
            else # close
                menu.removeClass 'open'
                $blur.removeClass 'obscured'
                mask.remove()
                resetSubmenu()
                canCloseMenu = false
                
        menu.click ->
            event.stopPropagation();
    
        resetSubmenu = ->
            menu.find($('ul.submenu li')).addClass 'hidden'
            menu.find($('li.hideOnOpenSubmenu')).removeClass 'hidden'
            menu.removeClass('wide')
            menu.removeClass('paddingBottom')
            inputIsFocused = false
            subMenuIsOpen = false
        
        menu.children("li:first-child").click ->
            if inputIsFocused or subMenuIsOpen
                return
            else
                toggleMenu 'open'
                setTimeout(()->
                    canCloseMenu = true
                , 500)
    
        menu.mouseleave ->
            return
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
        menu.find($('li.update')).click ->
            inputIsFocused = true
            subMenuIsOpen = true
            $('ul.submenu li.hidden').removeClass 'hidden'
            $('li.hideOnOpenSubmenu').addClass 'hidden'
            menu.addClass('wide paddingBottom')
            console.log 'subMenuIsOpen'
    
        menu.find($('ul.menu li.backButton')).click ->
            resetSubmenu()