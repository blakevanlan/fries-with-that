$(document).ready () ->
   vm = new window.ConsoleViewModel(window.gameData)
   ko.applyBindings(vm)

   $('#playButton').on 'click', (e) ->
      e.preventDefault()

      element = $('.console')
      top = element.offset().top
      consoleHeight = element.outerHeight() / 2
      windowHeight = $(window).height() / 2

      $('html, body').stop().animate {
         'scrollTop': top + consoleHeight - windowHeight
      }, 500, 'swing', () -> $('input.console-prompt-input').focus()

   $('.console .console-scrollbar').click (e) ->
      e.preventDefault()
      $('input.console-prompt-input').focus()
