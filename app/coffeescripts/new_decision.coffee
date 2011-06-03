$(document).ready ->

  # Cancel OpenID request if the user walks away

  $(window).unload ->
    $.post '/decisions', { commit: 'Cancel' }

  $('#main form input[name=commit]').click ->
    $(window).unbind 'unload'
