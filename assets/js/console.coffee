commands = {
   "examine": /^(examine)|(e)\s/,
   "goto": /^(goto)|(g)\s/,
   "help": /^help\s*$/
}

# Add trim funciton if it doens't already exist
if (!String.prototype.trim)
  String.prototype.trim = () ->
    return this.replace(/^\s+|\s+$/g, '')
  

class window.ConsoleViewModel
   constructor: (gameData) ->
      @gameData = gameData
      @input = ko.observable()
      @lines = ko.observableArray()

      if (!gameData?.rooms)
         @print("Failed to load game...")
      else
         @roomsMap = @createRoomsMap(gameData.rooms)
         @moveToRoom(gameData.startingRoom)

   createRoomsMap: (rooms) ->
      roomsMap = {}
      roomsMap[room.roomId] = room for room in rooms
      return roomsMap
      
   print: (str) =>
      str = "&nbsp;" unless str
      @lines.push(str)

   moveToRoom: (roomId) =>
      if !(nextRoom = @roomsMap[roomId])
         @print('That room seems to have vanished...')
      else
         @currentRoom = nextRoom
         @print(@highlightText(nextRoom.text, nextRoom))

   parseInput: () =>
      text = @input().trim()
      @print("&gt; #{text}")
      @input("")
      
      for command, regex of commands
         if regex.test(text)
            @commandFns[command].call(this, text.replace(regex, "").trim())
            return

      @print('Invalid command. Type "help" for commands.')

   commandFns:
      examine: (text) ->
         for object in @currentRoom.objects
            if object.phrase == text
               @print(@highlightText(object.text, @currentRoom))
               return

         @print("Can't examine: #{text}")

      goto: (text) ->
         for room in @currentRoom.exits
            if room.phrase == text
               @moveToRoom(room)
               return

         @print("Can't go to room: #{text}")

      help: () ->
         tab = "&nbsp;&nbsp;&nbsp;&nbsp;"
         @print("Commands:")
         @print("")
         @print("goto <room>&nbsp;&nbsp;&nbsp;#{tab}moves to a <span class=\"room\">room</span>")
         @print("#{tab}#{tab}#{tab}#{tab}ex: \"goto bedroom\"")
         @print("#{tab}#{tab}#{tab}#{tab}&nbsp;&nbsp;&nbsp; \"g bedroom\" (shortcut is g)")
         @print("")
         @print("examine <object>#{tab}examines an <span class=\"object\">object</span>")
         @print("#{tab}#{tab}#{tab}#{tab}ex: \"examine shelf\"")
         @print("#{tab}#{tab}#{tab}#{tab}#{tab}\"e shelf\" (shortcut is e)")

   highlightText: (text, room) =>
      for object in room.objects
         regex = new RegExp(object.phrase, 'gi')
         text = text.replace(regex, "<span class=\"object\">#{object.phrase}</span>")
      
      for room in room.exits
         regex = new RegExp(room.phrase, 'gi')
         text = text.replace(regex, "<span class=\"room\">#{room.phrase}</span>")

      return text


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