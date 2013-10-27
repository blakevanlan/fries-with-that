express = require "express"

app = module.exports = express()

app.get "/", (req, res, next) -> 
   res.render "home"

app.get "/data/game.js", (req, res, next) ->
   
   gameData = {
      startingRoom: "r1",
      rooms: [{
         roomId: "r1",
         exits: [],
         objects: [
            {
               phrase: "bookshelf"
               text: "Look its a bookshelf"
            }
         ],
         text: "You've entered a room with a bookshelf."
      }]
   }


   res.send "window.gameData = #{JSON.stringify(gameData)};";

   ###

   Game data template
   {
      startingRoom: "{roomId}"
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