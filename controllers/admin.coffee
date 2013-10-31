express = require 'express'
async = require 'async'
Config = require '../models/config'
Room = require '../models/room'

ensureAuthenticated = (req, res, next) ->
  return next() if req.isAuthenticated()
  res.redirect('/login')


module.exports = (passport) ->
      
   app = express()

   app.post('/login', passport.authenticate('local', {
      successRedirect: '/edit', failureRedirect: '/login' 
   }))

   app.get '/login', (req, res) -> 
      res.render 'login'

   app.get '/edit', ensureAuthenticated, (req, res, next) ->
      async.parallel
         rooms: (done) -> Room.find(done)
         config: (done) -> Config.getConfig(done)
      , (err, results) ->
         return next(err) if err
         res.render 'edit',
            rooms: results.rooms
            startingRoom: results.config?.startingRoom
      
   app.post '/edit', ensureAuthenticated, (req, res, next) ->
      Config.setStartingRoom req.body.startingRoom, (err) ->
         return next(err) if err
         res.redirect('/edit')

   app.get '/edit/rooms/:roomId', ensureAuthenticated, (req, res, next) ->
      res.send("EDITROOM")

   app.get '/edit/newRoom', ensureAuthenticated, (req, res, next) ->
      Room.find({})
      .select('title')
      .lean()
      .sort("title")
      .exec (err, rooms) ->
         return next(err) if err
         res.render 'editRoom',
            room: {}
            allRoomsString: JSON.stringify(rooms or [])

   app.post '/edit/newRoom', ensureAuthenticated, (req, res, next) ->
      body = req.body

      room = new Room()
      room.title = body.title
      room.text = processRoomText(body.text)
      
      delete body.title
      delete body.text

      exits = []
      objects = []

      # Process rooms and objects
      for key, value of body
         if key.indexOf('objectPhrase_') == 0
            index = key.replace('objectPhrase_')
            objects[index] = {} unless objects[index]
            objects[index].phrase = value
         
         else if key.indexOf('objectText_') == 0
            index = key.replace('objectPhrase_')
            objects[index] = {} unless objects[index]
            objects[index].text = processRoomText(value)
         
         else if key.indexOf('exitPhrase_') == 0
            index = key.replace('exitPhrase_')
            exits[index] = {} unless exits[index]
            exits[index].phrase = value
         
         else if key.indexOf('exitRoom_') == 0
            index = key.replace('exitRoom_')
            exits[index] = {} unless exits[index]
            exits[index].roomId = value

      (room.objects.push(object) if object) for object in objects
      (room.exits.push(exit) if exit) for exit in exits

      room.save (err) ->
         return next(err) if err
         res.redirect('/edit')

   return app


processRoomText = (text) -> return text.split('~')


