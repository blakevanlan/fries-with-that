
$(document).ready () ->

   exitList = $('.exitList').first()
   objectList = $('.objectList').first()
   allRooms = JSON.parse($('input[name=allrooms]')[0].value or '[]')

   $('#addExit').on 'click', (e) ->
      e.preventDefault()
      options = ['<option value="empty">Select room</option>']
      
      for room in allRooms
         options.push("<option value=\"#{room._id}\">#{room.title}</option>")
      
      nextId = (exitList.children().last()).find('input[type=text]')[0]?.name?.replace('exitPhrase_', '') or 0
      nextId++

      html = "<div class=\"exit\">
            <a class=\"deleteRow button small\">Delete</a>
            <span class=\"label\">Phase</span>
            <input type=\"text\" name=\"exitPhrase_#{nextId}\" />
            <span class=\"label room\">Room</span>
            <select name=\"exitRoom_#{nextId}\">
               #{options.join('')}
            </select>
         </div>"
            
      exitList.append(html)

   $('#addObject').on 'click', (e) ->
      e.preventDefault()
      nextId = (objectList.children().last()).find('input[type=text]')[0]?.name?.replace('objectPhrase_', '') or 0
      nextId++

      html = "<div class=\"object\">
            <a class=\"deleteRow button small\">Delete</a>
            <span class=\"label\">Phase</span>
            <input type=\"text\" name=\"objectPhrase_#{nextId}\" />
            <br>
            <span class=\"label text\">Text</span>
            <textarea class=\"text\" name=\"objectText_#{nextId}\"></textarea>
         </div>"

      objectList.append(html)

   $('body').on 'click', 'a.deleteRow', (e) ->
      e.preventDefault()
      $(this).parent().remove()