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
        User.hasMany(models.Space, { onDelete: 'CASCADE' })
    instanceMethods:
      verifyPassword: (password, done) ->
        bcrypt.compare password, this.password, (err, res) ->
          done(err, res)
  }
