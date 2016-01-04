initLettering = () ->
  $('.lettering').lettering();
  $('.lettering').children().addClass 'stamp'
  $('.lettering').children().each () ->
    left = $(@).index() / 1.5
    top = (Math.random() - .5)
    $(@).css {
      position: 'relative',
      top: "#{top}em"
#       left: "#{left}em"
    }
  
initCards = () ->
  $('.pack.card.filler').each () ->
    $(@).css({
      'width': "#{72 + (12 * Math.round(Math.random() * 10))}px"
      'height': "#{72 + (12 * Math.round(Math.random() * 10))}px"
    })
  
initPackery = () ->
  $('.container').packery({
    itemSelector: '.pack',
    gutter: 24,
#     isOriginTop: false
#     isOriginLeft: false
  });
  $('.container').packery( 'stamp', $('.stamp') );
  $('.container').packery();

$ ->
  initLettering()
  initCards()
  initPackery()