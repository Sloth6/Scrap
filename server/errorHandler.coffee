module.exports = (err, res) ->
  console.log err if err?
  res.send(400) if res?