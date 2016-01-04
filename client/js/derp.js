// http://packery.metafizzy.co/packery.pkgd.js and 
// http://draggabilly.desandro.com/draggabilly.pkgd.js added as external resource

// ----- text helper ----- //

var docElem = document.documentElement;
var textSetter = docElem.textContent !== undefined ? 'textContent' : 'innerText';

function setText( elem, value ) {
  elem[ textSetter ] = value;
}

docReady( function() {
  var container = document.querySelector('#container');
  var pckry = new Packery( container, {
    //columnWidth: 80,
    //rowHeight: 80
  });
  var itemElems = pckry.getItemElements();
  // for each item element
  for ( var i=0, len = itemElems.length; i < len; i++ ) {
    var elem = itemElems[i];
    // make element draggable with Draggabilly
    var draggie = new Draggabilly( elem );
    // bind Draggabilly events to Packery

    pckry.bindDraggabillyEvents( draggie );
  }


  // show item order after layout
  function orderItems() {
    var itemElems = pckry.getItemElements();
    for ( var i=0, len = itemElems.length; i < len; i++ ) {
      var elem = itemElems[i];
      setText( elem, i + 1 );
    }
    // $(container).packery()
  }

  pckry.on( 'layoutComplete', orderItems );
  pckry.on( 'dragItemPositioned', orderItems );
  orderItems()

});
