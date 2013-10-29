passport = require 'passport'

app = module.exports = express()

app.post '/login', passport.authenticate('local', { successRedirect: '/',
                                                    failureRedirect: '/login' })

app.get '/login', 
   passport.authenticate('basic', { session: false }),
   (req, res) ->
      res.json(req.user);


app.get '/edit',
   passport.authenticate('basic', { session: false }),
   (req, res, next) ->
      res.send("EDIT")

app.get '/editRoom/:roomId',
   passport.authenticate('basic', { session: false }),
   (req, res, next) ->
      res.send("EDITROOM")

app.get '/newRoom',
   passport.authenticate('basic', { session: false }),
   (req, res, next) -> 
      res.send("NEWROOM")