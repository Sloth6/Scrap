$(document).ready(function() {
    var menu = $("ul.menu"),
        space = $("section.space"),
        mask = $("<div class='mask'></div>"),
        focused = false;
    
    menu.mouseenter(function() {
        toggleMenu("open")
    });
    
    menu.mouseleave(function() {
        if (!(focused)) {
            toggleMenu("close")
        }
    });

    menu.find("input").focus(function() {
        focused = true;
        toggleMenu("open")
    });
    
    function toggleMenu(to) {
        if (to === "open") {
            $(menu).addClass("open");
            space.addClass("obscured");
            $("section.container").prepend(mask)                    
            $('.mask').click(function(){
                toggleMenu("close")
                console.log("HI")
            })
        } else {
            $(menu).removeClass("open");
            space.removeClass("obscured");
            mask.remove()
        }
    }
    
});