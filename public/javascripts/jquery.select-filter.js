/* DO NOT MODIFY. This file was compiled Thu, 24 Mar 2011 04:32:14 GMT from
 * /home/rmm900/dev/ADAUsers/app/coffeescripts/jquery.select-filter.coffee
 */

(function() {
  jQuery.fn.selectFilter = function() {
    jQuery(this).before('<br />Filter: <input type="text" class="select-filter" /><br />');
    jQuery(this).append('<option class="select-filter-none-found">No result found</option>');
    jQuery(this).children("option.select-filter-none-found").hide();
    return jQuery(".select-filter").keyup(function() {
      var prev_query, query, select, selector;
      query = jQuery(this).val();
      prev_query = jQuery(this).data('prev_query');
      jQuery(this).data('prev_query', query);
      select = jQuery(this).next().next();
      if (query === "") {
        return select.children("option").show();
      } else {
        if (prev_query.length < query.length) {
          selector = "option:visible";
        } else {
          selector = "option";
        }
        return select.children(selector).each(function(index) {
          var child;
          child = jQuery(this);
          if (child.html().toLowerCase().indexOf(query.toLowerCase()) > -1) {
            return child.show();
          } else {
            return child.hide();
          }
        });
      }
    });
  };
}).call(this);
