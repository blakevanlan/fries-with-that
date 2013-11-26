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
      return res.redirect('/edit') if req.isAuthenticated() 
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
      roomId = req.params.roomId
      async.parallel
         room: (done) ->
            Room.findById(roomId).lean().exec(done)
         all: (done) ->
            Room.find({_id: {$ne:roomId}}).select('title').lean().sort("title").exec(done)
      , (err, results) ->
         return res.redirect('/edit') if err or !results.room
         res.render 'editRoom',
            room: results.room
            allRooms: results.all or []

   app.post '/edit/rooms/:roomId', ensureAuthenticated, (req, res, next) ->
      body = req.body
      Room.findById req.params.roomId, (err, room) ->
         room.title = body.title
         room.text = processRoomText(body.text)
         console.log("text", room.text)

         delete body.title
         delete body.text

         parseBody(body, room)
         room.save (err) ->
            return next(err) if err
            res.redirect('/edit')

   app.get '/edit/newRoom', ensureAuthenticated, (req, res, next) ->
      Room.find({})
      .select('title')
      .lean()
      .sort("title")
      .exec (err, rooms) ->
         return next(err) if err
         res.render 'editRoom',
            room: {}
            allRooms: rooms or []

   app.post '/edit/newRoom', ensureAuthenticated, (req, res, next) ->
      body = req.body

      room = new Room()
      room.title = body.title
      room.text = processRoomText(body.text)
      
      delete body.title
      delete body.text

      parseBody(body, room)
      room.save (err) ->
         return next(err) if err
         res.redirect('/edit')

   app.get '/edit/delete/:roomId', ensureAuthenticated, (req, res, next) ->
      Room.findById(req.params.roomId).lean().exec (err, room) ->
         return next(err) if err
         return res.redirect('/edit') unless room
         res.render 'delete', room: room

   app.post '/edit/delete/:roomId', ensureAuthenticated, (req, res, next) ->
      Room.findByIdAndRemove req.params.roomId, (err) ->
         return next(err) if err
         res.redirect('/edit')

   return app


processRoomText = (text) -> return text.split(/\r?\n~\r?\n/g)
parseBody = (body, room) ->
   exits = []
   objects = []
      
   # Process rooms and objects
   for key, value of body
      if key.indexOf('objectPhrase_') == 0
         index = key.replace('objectPhrase_', '')
         objects[index] = {} unless objects[index]
         objects[index].phrase = value?.toLowerCase()
      
      else if key.indexOf('objectText_') == 0
         index = key.replace('objectText_', '')
         objects[index] = {} unless objects[index]
         objects[index].text = processRoomText(value)
      
      else if key.indexOf('exitPhrase_') == 0
         index = key.replace('exitPhrase_', '')
         exits[index] = {} unless exits[index]
         exits[index].phrase = value?.toLowerCase()
      
      else if key.indexOf('exitRoom_') == 0
         index = key.replace('exitRoom_', '')
         exits[index] = {} unless exits[index]
         exits[index].roomId = if value == 'empty' then null else value

   room.objects = []
   room.exits = []

   (room.objects.push(object) if object) for object in objects
   (room.exits.push(exit) if exit) for exit in exits
