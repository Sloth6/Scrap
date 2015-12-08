module.exports = () ->
  hue         = Math.random() * 360
  luminosity  = Math.random() * 10 + 70
  "hsl(#{hue},100%,#{luminosity}%)"
