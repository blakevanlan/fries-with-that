ko.bindingHandlers.onEnter = 
    init: (element, valueAccessor) ->
        value = valueAccessor()
        $(element).keypress (event) ->
            keyCode = if event.which then event.which else event.keyCode
            if (keyCode == 13)
                value.call(ko.dataFor(this))
                return false
            
            return true