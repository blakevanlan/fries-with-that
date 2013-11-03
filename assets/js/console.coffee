commands = {
   'examine': /^(examine)|(e)\s/,
   'goto': /^(goto)|(g)\s/,
   'help': /^help\s*$/,
   'more': /^more\s*/
}

# Add trim funciton if it doens't already exist
if (!String.prototype.trim)
  String.prototype.trim = () ->
    return this.replace(/^\s+|\s+$/g, '')
  

class window.ConsoleViewModel
   constructor: () ->
      @gameData = null
      @roomsMap = null
      @moreToPrint = false
      @input = ko.observable()
      @lines = ko.observableArray()
      @loadGameData()

   loadGameData: () =>
      @print('Loading game...')
      $.getJSON('gameData.json', (gameData) =>
         @gameData = gameData
         @reprint('Game data loaded!')
         @roomsMap = @createRoomsMap(gameData.rooms)
         @moveToRoom(gameData.startingRoom)
      ).fail () =>
         @reprint('Failed to load game...')

   createRoomsMap: (rooms) ->
      roomsMap = {}
      roomsMap[room._id] = room for room in rooms
      return roomsMap
      
   removeLines: (count = 1) =>
      @lines.pop() for i in [1..count]
         
   print: (text) =>
      text = '&nbsp;' unless text
      if typeof(text) == 'string'
         @lines.push(text)
      else if text.length == 1
         @lines.push(text[0])
      else
         @moreToPrint = (text[i] for i in [1...text.length])
         @lines.push(text[0])
         @print('&nbsp;')
         @print('Type "more" to continue reading.')
         
   reprint: (text) =>
      @removeLines(1)
      @print(text)

   printMore: () =>
      return false unless @moreToPrint?.length > 0
      @removeLines(2)
      @print(@moreToPrint)
      return true

   moveToRoom: (roomId) =>
      if !(nextRoom = @roomsMap[roomId])
         @print('That room seems to have vanished...')
      else
         @moreToPrint = false
         @currentRoom = nextRoom
         @print(@highlightText(nextRoom.text, nextRoom))

   parseInput: () =>
      text = @input().trim()
      @print("&gt; #{text}")
      @input('')

      for command, regex of commands
         if regex.test(text)
            @commandFns[command].call(this, text.replace(regex, '').trim())
            return

      @print('Invalid command. Type "help" for commands.')

   commandFns:
      examine: (text) ->
         for object in @currentRoom.objects
            if object.phrase == text
               @moreToPrint = false
               @print(@highlightText(object.text, @currentRoom))
               return

         @print("Can't examine: #{text}")

      goto: (text) ->
         for room in @currentRoom.exits
            if room.phrase == text
               @moveToRoom(room.roomId)
               return

         @print("Can't go to room: #{text}")

      more: () ->
         return if @printMore()
         @print('Nothing more to read.')

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
      if typeof(text) == 'string'
         text = [text]

      highlighted = []

      for entry in text
         for object in room.objects
            regex = new RegExp(object.phrase, 'gi')
            entry = entry.replace(regex, "<span class=\"object\">#{object.phrase}</span>")
         
         for exit in room.exits
            regex = new RegExp(exit.phrase, 'gi')
            entry = entry.replace(regex, "<span class=\"room\">#{exit.phrase}</span>")

         highlighted.push(entry)

      return highlighted
