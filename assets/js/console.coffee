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
      @roomsMap = @createRoomsMap(gameData.rooms)
      @currentRoom = @moveToRoom(gameData.startingRoom)

   createRoomsMap: (rooms) ->
      roomsMap = {}
      roomsMap[room.roomId] = room for room in rooms
      return roomsMap
      
   print: (str) =>
      @lines.push(str)

   moveToRoom: (roomId) =>
      if !(nextRoom = @roomsMap[roomId])
         @print('That room seems to have vanished...')
      else
         @currentRoom = nextRoom
         @print(@highlightRoomText(nextRoom))

   parseInput: () =>
      text = @input().trim()
      @print("&gt; #{text}")
      @input("")
      
      for command, regex of commands
         if regex.test(text)
            commandFns[command].call(this, text.replace(regex, "").trim())
            return

      @print('Invalid command. Type "help" for commands')

   commandFns:
      examine: (text) ->
         for object in @currentRoom.objects
            if object.phrase == text
               @print(object.text)
               return

         @print("Can't examine: #{text}")

      goto: (text) ->
         for room in @currentRoom.exits
            if room.phrase == text
               @moveToRoom(room)
               return

         @print("Can't go to room: #{text}")

      help: () ->
         @print('Available commands:')
         @print('  goto <room>       moves to the room, rooms are marked in blue')
         @print('                       ex: "goto bedroom" or "g bedroom" (shortcut is g)')
         @print('  examine <object>  examines an object, objects are marked in orange')
         @print('                       ex: "examine shelf" or "e shelf" (shortcut is e)')

   highlightRoomText: (room) =>
      text = room.text
      for object in room.objects
         regex = new Regex(object.phrase, 'gi')
         text = text.replace(regex, "<span class=\"object\">#{object.phrase}</span>")
      
      for room in room.rooms
         regex = new Regex(room.phrase, 'gi')
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