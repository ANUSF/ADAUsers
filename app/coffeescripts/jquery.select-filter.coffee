jQuery.fn.selectFilter = ->
  jQuery(this).each (index) ->
    # Add the filter in a new div, and move the select input into that div
    jQuery(this).before('<div class="select-filter-container">Filter: <input type="text" class="select-filter" /><br /></div>')
    container = jQuery(this).prev()
    container.append(jQuery(this).detach())

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
