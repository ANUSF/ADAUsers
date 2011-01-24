$ = jQuery

country_change = (item) ->
  form = item.closest 'form#new_user'
  if item.val() == "15" # code for Australia
    form.find('#australia-inputs').css { display: 'block' }
    form.find('#not-australia-inputs').css { display: 'none' }
  else
    form.find('#australia-inputs').css { display: 'none' }
    form.find('#not-australia-inputs').css { display: 'block' }

$(document).ready ->
  $('form#new_user #user_country_input select')
    .each(-> country_change $ this)
    .change(-> setTimeout (=> country_change $ this), 200)
