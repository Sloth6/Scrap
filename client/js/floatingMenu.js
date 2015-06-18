function floatingMenuController(menu) {
//  Open closed menu items
    menu.find("li.closed").click(function() {
        $(this)
            .removeClass("closed")
            .removeClass("hidden")
            .addClass("open")
        menu.find("li").not($(this))
            .addClass("closed")
            .addClass("hidden")
            .removeClass("open")
    });
}