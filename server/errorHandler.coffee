module.exports = (err, res) ->
  console.log("ERROR: #{err}.") if err?
  res.send(400) if res?