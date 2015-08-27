$ ->
    $('.cover ul.menu').each () ->
        $menu = $(@)
        $cover = $menu.parent().parent('.cover')
        $cover.mouseenter () ->
            $menu.addClass 'open'
        $cover.mouseleave () ->
            $menu.removeClass 'open'