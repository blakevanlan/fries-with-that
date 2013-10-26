$(document).ready () ->
   vm = new window.ConsoleViewModel(window.gameData)
   ko.applyBindings(vm)