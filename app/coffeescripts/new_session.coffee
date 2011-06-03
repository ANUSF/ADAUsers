$(document).ready ->

  # Cancel OpenID request if the user walks away

  $(window).unload ->
    $.post '/session', { commit: 'Cancel' }

  $('#main form input[name=commit]').click ->
    $(window).unbind 'unload'
