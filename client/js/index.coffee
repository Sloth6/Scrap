# Array.prototype.random = () ->
#     return @[Math.floor(Math.random() * @length)]
#     
# Array.prototype.remove = (elem) ->
#     idx = @indexOf elem
#     return @ if idx is -1
#     @splice(idx, 1)
#     @
# 
# 
# $ ->
#     'use strict'  
#     
#     driftElements = $("section.index .drift")
#     contentContainer = $("section.example")
#     windowHeight = $(window).height()
#     windowWidth  = $(window).width()
#     driftIntervalContained = 30
#     driftIntervalEndless = driftIntervalContained / 2
#     
#     getEndlessMultiple = () ->
#         endlessMultiple = if (Math.random() > .5) then (Math.random() * 4) else (Math.random() * -4)
#         return endlessMultiple
#         
#     placeRandomly = (element) ->
#         endlessMultiple = getEndlessMultiple()
#         if element.hasClass("top")
#             x =  Math.random()       * (windowWidth - element.outerWidth())
#             y =  Math.random()/2     * (windowHeight - element.outerHeight())
#         else if element.hasClass("bottom")
#             x =  Math.random()       * (windowWidth - element.outerWidth())
#             y = (Math.random()/2+.5) * (windowHeight - element.outerHeight())
#         else if element.hasClass("endless")
#             x =  Math.random() * (windowWidth  * endlessMultiple - element.outerWidth())
#             y =  Math.random() * (windowHeight * endlessMultiple - element.outerHeight())
#             console.log endlessMultiple
#         else
#             x =  Math.random() * (windowWidth - element.outerWidth())
#             y =  Math.random() * (windowHeight - element.outerHeight())
#         element.css { x, y }
#         
#     drift = (element) ->
#         transitionSpeed = if element.hasClass("endless") then driftIntervalEndless else driftIntervalContained
#         element.css {
#             "-webkit-transition" : transitionSpeed + "s"
#             "-moz-transition" : transitionSpeed + "s"
#             "transition" : transitionSpeed + "s"
#         }
#         lastSide = element.data('lastSide')
#         side = ['left', 'right', 'top', 'bottom'].remove(lastSide).random()
#         element.data('lastSide', side)
#         distance = Math.random()
#         endlessMultiple = getEndlessMultiple()
#         
#         
#         if element.hasClass("top")
#             if side is 'left'
#                 x = 0
#                 y = (distance / 2) * (windowHeight - element.outerHeight())
#             else if side is 'right'
#                 x = windowWidth - element.outerWidth()
#                 y = (distance / 2) * (windowHeight - element.outerHeight())
#             else if side is 'top' or 'bottom' # always goes to top
#                 y = 0
#                 x = (windowWidth - element.outerWidth()) * distance
#                 
#         else if element.hasClass("bottom")
#             if side is 'left'
#                 x = 0
#                 y = ((distance / 2) + .5) * (windowHeight - element.outerHeight())
#             else if side is 'right'
#                 x = windowWidth - element.outerWidth()
#                 y = ((distance / 2) + .5) * (windowHeight - element.outerHeight())
#             else if side is 'top' or 'bottom' # always goes to bottom
#                 y = windowHeight - element.outerHeight()
#                 x = (windowWidth - element.outerWidth()) * distance
#         else if element.hasClass("endless")
#             if side is 'left'
#                 x = 0
#                 y = ((distance / 2) + .5) * (windowHeight * endlessMultiple - element.outerHeight())
#             else if side is 'right'
#                 x = windowWidth - element.outerWidth()
#                 y = ((distance / 2) + .5) * (windowHeight * endlessMultiple - element.outerHeight())
#             else if side is 'top'
#                 y = 0
#                 x = (windowWidth * endlessMultiple - element.outerWidth()) * distance
#             else if side is 'bottom'
#                 y = windowHeight * endlessMultiple - element.outerHeight()
#                 x = (windowWidth * endlessMultiple - element.outerWidth()) * distance
#             
#         #  Math.random() * windowHeight / 2
# #         y = Math.random() * windowWidth  / 2
#         element.css { x, y }
#     
#     itemCount = 50
#     for i in [0..itemCount]
#         itemElement = $("<img class='drift endless'>").attr("src", "https://unsplash.it/" + (200 * (Math.random() + .5)) + "/" + (200 * (Math.random() + .5)))
#         contentContainer.append itemElement
# 
#     $("section.index .drift").each () ->
#         driftInterval = if $(@).hasClass("endless") then driftIntervalEndless * (Math.random() * 2) else driftIntervalContained
#         placeRandomly $(@)
#         setTimeout (() =>
#             drift $(@)
#         ), 500
#         setInterval (() =>
#             drift($(@))
#         ), driftInterval * 1000
