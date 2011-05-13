/* DO NOT MODIFY. This file was compiled Fri, 13 May 2011 04:08:30 GMT from
 * /home/rmm900/dev/ADAUsers/app/coffeescripts/jquery.select-filter.coffee
 */

(function() {
  jQuery.fn.selectFilter = function() {
    return jQuery(this).each(function(index) {
      var container;
      jQuery(this).before('<div class="select-filter-container">Filter: <input type="text" class="select-filter" /><br /></div>');
      container = jQuery(this).prev();
      container.append(jQuery(this).detach());
      jQuery(this).data("options", jQuery(this).find("option"));
      return jQuery(".select-filter").keyup(function() {
        var query, select;
        query = jQuery(this).val();
        select = jQuery(this).next().next();
        select.empty();
        return select.append(select.data("options").filter(function(index) {
          return jQuery(this).html().toLowerCase().indexOf(query.toLowerCase()) > -1;
        }));
      });
    });
  };
}).call(this);
