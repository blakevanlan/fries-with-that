ko.bindingHandlers.onEnter = 
    init: (element, valueAccessor) ->
        value = valueAccessor()
        $(element).keypress (event) ->
            keyCode = if event.which then event.which else event.keyCode
            if (keyCode == 13)
                value.call(ko.dataFor(this))
                return false
            
            return true

ko.bindingHandlers.stickyScroll = 
    update: (element, valueAccessor) ->
      data = ko.utils.unwrapObservable valueAccessor()
      console.log("UPDATE")
      element.scrollTop = element.scrollHeight