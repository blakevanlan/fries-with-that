express = require 'express'
async = require 'async'
Config = require '../models/config'
Room = require '../models/room'

app = module.exports = express()

app.get "/", (req, res, next) -> 
   res.render "home"

app.get "/gameData.json", (req, res, next) ->
   
   # gameData = {
   #    startingRoom: "r1",
   #    rooms: [{
   #       roomId: "r1",
   #       exits: [
   #          {
   #             phrase: "bedroom",
   #             roomId: "r2"
   #          }
   #       ],
   #       objects: [
   #          {
   #             phrase: "bookshelf"
   #             text: "Look its a bookshelf"
   #          }
   #       ],
   #       text: "You've entered a room with a bookshelf and a bedroom door"
   #    }, {
   #       roomId: "r2",
   #       exits: [],
   #       objects: [],
   #       text: "You've entered an empty room."
   #    }]
   # }

   # return res.send "window.gameData = #{JSON.stringify(gameData)};";

   async.parallel
      rooms: (done) -> Room.find({}).lean().exec(done)
      config: (done) -> Config.getConfig(done)
   , (err, results) ->
      if err or !results?.config or !results?.rooms
         return res.send "window.getData = null;" 

      gameData = {
         startingRoom: results.config.startingRoom
         rooms: results.rooms
      }

      res.json(gameData)