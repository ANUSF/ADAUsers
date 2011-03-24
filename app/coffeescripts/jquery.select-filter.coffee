jQuery.fn.selectFilter = ->
  jQuery(this).before('<br />Filter: <input type="text" class="select-filter" /><br />')

  jQuery(this).append('<option class="select-filter-none-found">No result found</option>')
  jQuery(this).children("option.select-filter-none-found").hide()

  jQuery(".select-filter").keyup ->
    query = jQuery(this).val()
    prev_query = jQuery(this).data('prev_query')
    jQuery(this).data('prev_query', query)
    select = jQuery(this).next().next()
    if query == ""
      select.children("option").show()
    else
      if prev_query.length < query.length then selector = "option:visible" else selector = "option"
      select.children(selector).each (index) ->
        child = jQuery(this)
        if child.html().toLowerCase().indexOf(query.toLowerCase()) > -1 then child.show() else child.hide()
