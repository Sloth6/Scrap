Array.prototype.random = () ->
    return @[Math.floor(Math.random() * @length)]
    
Array.prototype.remove = (elem) ->
    idx = @indexOf elem
    return @ if idx is -1
    @splice(idx, 1)
    @

$ ->
    driftElements = $("section.index .drift")
    
    placeRandomly = (element) ->
        if element.hasClass("top")
            x =  Math.random()       * ($(window).width() - element.outerWidth())
            y =  Math.random()/2     * ($(window).height() - element.outerHeight())
        else if element.hasClass("bottom")
            x =  Math.random()       * ($(window).width() - element.outerWidth())
            y = (Math.random()/2+.5) * ($(window).height() - element.outerHeight())
            
        element.css { x, y }
        
    drift = (element) ->
        element.css {
            "-webkit-transition" : "30s linear",
            "-moz-transition" : "30s linear",
            "transition" : "30s linear"
        }
        last_side = element.data('last_side')
        side = ['left', 'right', 'top', 'bottom'].remove(last_side).random()
        element.data('last_side', side)
        dist = Math.random()
        
        if element.hasClass("top")
            if side is 'left'
                x = 0
                y = (dist / 2) * ($(window).height() - element.outerHeight())
            else if side is 'right'
                x = $(window).width() - element.outerWidth()
                y = (dist / 2) * ($(window).height() - element.outerHeight())
            else if side is 'top' or 'bottom' # always goes to top
                y = 0
                x = ($(window).width() - element.outerWidth()) * dist
                
        else if element.hasClass("bottom")
            if side is 'left'
                x = 0
                y = ((dist / 2) + .5) * ($(window).height() - element.outerHeight())
            else if side is 'right'
                x = $(window).width() - element.outerWidth()
                y = ((dist / 2) + .5) * ($(window).height() - element.outerHeight())
            else if side is 'top' or 'bottom' # always goes to bottom
                y = $(window).height() - element.outerHeight()
                x = ($(window).width() - element.outerWidth()) * dist
            
            
        #  Math.random() * $(window).height() / 2
#         y = Math.random() * $(window).width()  / 2
        element.css { x, y }
            
    driftElements.each () ->
        placeRandomly $(@)
        setTimeout (() =>
            drift $(@)
        )
        setInterval (() =>
            drift($(@))
        ), 30000
        

    