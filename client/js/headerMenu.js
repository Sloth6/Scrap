$(document).ready(function() {
    var menu = $("ul.menu"),
        space = $("section.space"),
        mask = $("<div class='mask'></div>"),
        inputIsFocused = false,
        subMenuIsOpen = false;
    
    menu.mouseenter(function() {
        if (inputIsFocused || subMenuIsOpen) {
            console.log("cantopenMenu")
            return;
        } else {
            console.log("openMenu")
            toggleMenu("open")
        }
    });
    
    menu.mouseleave(function() {
        // if no inputs are focused and no submenus are open
        if (inputIsFocused || subMenuIsOpen) {
            return;
        } else {
            console.log("closeMenu")
            toggleMenu("close")
        }
    });

    menu.find("input").focus(function() {
        inputIsFocused = true;
        toggleMenu("open")
    });
    
    function toggleMenu(to) {
        if (to === "open") {
            $(menu).addClass("open");
            space.addClass("obscured");
            $("section.container").prepend(mask)                    
            $('.mask').click(function(){
                toggleMenu("close")
            })
        } else {
            $(menu).removeClass("open");
            space.removeClass("obscured");
            mask.remove();
            inputIsFocused = false;
            subMenuIsOpen = false;
            resetSubmenu();
        }
    }
    
    function resetSubmenu() {
        $("li.hideOnOpenSubmenu").removeClass("hidden") // reset hidden items
        $("ul.menu.changeUserInfo").addClass("hidden") // collapse submenus
    }
    
    // Settings menu
    $("li.update").click(function() {
        inputIsFocused = true;
        subMenuIsOpen = true;
        $("ul.menu.submenu").removeClass("hidden")
        $("li.hideOnOpenSubmenu").addClass("hidden")
        console.log("subMenuIsOpen")
    });
    
    $("ul.menu.submenu li.closeButton").click(function() {
        resetSubmenu();
    });
});