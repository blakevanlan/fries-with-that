express = require "express"

app = module.exports = express()

app.get "/", (req, res, next) -> 
   res.render "home"

app.get "/data/game.js", (req, res, next) ->
   gameData = {};
   res.send "window.gameData = #{JSON.stringify(gameData)};";

   ###

   Game data template
   {
      starting_room: "{roomId}"
      rooms: [
         {
            roomId: String
            exits: [
               {
                  roomId: String
                  phrase: String
               }
            ],
            objects: [
               {
                  phrase: String
                  text: String
               }
            ]
            text: String
         }
      ]
   }

   ###