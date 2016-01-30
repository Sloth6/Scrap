bcrypt = require 'bcrypt-nodejs'

module.exports = (sequelize, DataTypes) ->
  User = sequelize.define 'User', {
    email:
      type: DataTypes.TEXT
      allowNull: false
      unique: true
      validate:
        isEmail: true
    password: 
      type: DataTypes.STRING
      allowNull: true
      set: (password) ->
        salt = bcrypt.genSaltSync 10
        encrypted = bcrypt.hashSync password, salt
        @setDataValue "password", encrypted
    name: 
      type: DataTypes.TEXT
      allowNull: false
  }, {
    classMethods:
      associate: (models) ->
        User.hasMany(models.Collection)
        User.hasMany(models.Article)

      # Create a new user and their root label
      createAndInitialize: (options, callback) ->
        User.create(options).done (err, user) ->
          return callback(err) if err?
          callback null, user

    instanceMethods:
      verifyPassword: (password, done) ->
        bcrypt.compare password, this.password, (err, res) ->
          done(err, res)
  }
