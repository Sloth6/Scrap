$(document).ready(function() {
    var menu = $("ul.menu"),
        space = $("section.space"),
        focused = false;
    
    menu.mouseenter(function() {
        $(this).addClass("open");
        space.addClass("obscured");
    });
    
    menu.mouseleave(function() {
        if (focused) {
            return;
        } else {
            $(this).removeClass("open");
            space.removeClass("obscured");
        }
    });
    
    menu.find("input").focus(function() {
        focused = true;
    });
    
    menu.find("input").blur(function() {
        focused = false;
        menu.removeClass("open");
        space.removeClass("obscured");
    });
});