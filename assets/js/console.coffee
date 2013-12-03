commands = {
   'examine': /^((examine)|(e))\s/,
   'goto': /^((goto)|(g))\s/,
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
      @isInIntro = true
      
      # Add click handlers for object and room
      inputObservable = @input
      $('body').on 'click', 'span.object', (e) ->
         inputObservable("examine #{$(this).text().toLowerCase()}")
      $('body').on 'click', 'span.room', (e) ->
         inputObservable("goto #{$(this).text().toLowerCase()}")

   loadGameData: () =>
      @print('Loading game...')
      $.getJSON('gameData.json', (gameData) =>
         @gameData = gameData
         @roomsMap = @createRoomsMap(gameData.rooms)
         @showIntro()
      ).fail () =>
         @reprint('Failed to load game...')

   showIntro: () =>
      @clear()
      @isInIntro = true
      tab = '&nbsp;&nbsp;&nbsp;'
      @print("Welcome to I'd like Fries with That!")
      @print("")
      @print('You will use the following commands to play:')
      @print("")
      @print("#{tab}Type \"goto &lt;room&gt;\" to move to a <span class=\"room\">room</span>")
      @print("#{tab}#{tab}Rooms will always be highlighted in <span class=\"room\">this color</span>")
      @print("#{tab}#{tab}and can be clicked on to skip the typing")
      @print("")
      @print("#{tab}Type \"examine &lt;object&gt;\" to examine an <span class=\"object\">object</span>")
      @print("#{tab}#{tab}Objects will always be highlighted in <span class=\"object\">this color</span>")
      @print("#{tab}#{tab}and can be clicked on to skip the typing")
      @print("")
      @print("#{tab}Type \"help\" to see the commands again")
      @print("")
      @print("And finally, asides are shown in <span class=\"comment\">this color</span>, which provide additional context but are not in second person.")
      @print("")
      @print("That's all! Type \"start\" to begin!")

   startGame: () =>
      @clear()
      @isInIntro = false
      @moveToRoom(@gameData.startingRoom)

   createRoomsMap: (rooms) ->
      roomsMap = {}
      roomsMap[room._id] = room for room in rooms
      return roomsMap
      
   clear: () => @lines([])

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
      text = @input().trim().toLowerCase()
      @print("&gt; #{text}")
      @input('')

      if @isInIntro
         if text == 'start' then @startGame()
         else @print('Please type "start" to begin!')
         return

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

         regex = /\r?\n###\r?\n?.*\r?\n###/gi
         comments = entry.match(regex)
         if (comments and comments.length > 0)
            for m in comments
               text = m.replace(/(###)|(\r)/g, "").replace(/\n/g, " ")
               entry = entry.replace(m, "<br><span class=\"comment\">#{text}</span>")

         for object in room.objects
            regex = new RegExp(object.phrase, 'gi')
            matches = entry.match(regex)
            continue unless matches
            entry = entry.replace(m, "<span class=\"object\">#{m}</span>") for m in matches
         
         for exit in room.exits
            regex = new RegExp(exit.phrase, 'gi')
            matches = entry.match(regex)
            continue unless matches
            entry = entry.replace(m, "<span class=\"room\">#{m}</span>") for m in matches

         highlighted.push(entry)

      return highlighted
