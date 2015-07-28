models = require '../../models'
mail = require '../adapters/nodemailer'

toTitleCase = (str) -> 
  str.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase() )


module.exports =
  reorderElements: (sio, socket, data, spaceKey) ->
    { spaceKey, elementOrder } = data
    console.log spaceKey, elementOrder
    models.Space.find({ where: {spaceKey} }).then (space) ->
      if space
        console.log space.name
        console.log space.elementOrder
        # space.updateAttributes {
        #   name: 'foobar2'
        # }

module.exports.reorderElements()