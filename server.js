require('coffee-script/register');

var express = require('express')
    , app = express()
    , server = require('http').createServer(app)
    , io = require('socket.io')(server)
    , sharedsession = require("express-socket.io-session")
    , port = (process.env.PORT || 9001)
    , db = require('./models')
    , coffeeMiddleware = require('coffee-middleware')
    , SequelizeStore = require('connect-session-sequelize')(express.session.Store)
    , compass = require('compass');

var pg = require('pg')
  , express_session = require('express-session')
  , pgSession = require('connect-pg-simple')(express_session);

var session = express_session({
  store: new pgSession({
    pg : pg, // Use global pg-module
    conString : 'postgres://localhost/scrapdb',
  }),
  saveUninitialized: false,
  secret: "club_sexdungeon",
  resave: true,
  cookie: { maxAge: 30 * 24 * 60 * 60 * 1000 } // 30 days
})

app.configure(function(){
    app.set('views', __dirname + '/views');
    app.set("view engine", "jade");
    app.set('view options', { layout: false });
    app.use(express.static(__dirname + '/client'));
    app.use(express.bodyParser());
    app.use(express.cookieParser());
    app.use(session)
    app.use(coffeeMiddleware({
        src: __dirname + '/client',
        compress: true,
        encodeSrc: false,
        force: true,
        debug: false,
        bare: true
    }));
});

io.use(sharedsession(session));

db.sequelize.sync({ force: false }).complete(function(err) {
    if (err) {
        throw err;
    } else {
        require('./server/socketListeners')(io);
        require('./server/routes')(app);
        console.log('Listening on port:' + port );
    }
});

server.listen(port);