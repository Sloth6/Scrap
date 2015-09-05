models = require '../../models'
mail = require '../adapters/nodemailer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )


module.exports =
  reorderElements: (sio, socket, data) ->
    { spaceKey, elementOrder } = data
    elementOrder = JSON.parse elementOrder
    console.log elementOrder
    models.Space.update({elementOrder}, {spaceKey}).complete (err) ->
      console.log err
      # console.log space.name
      # console.log space.elementOrder