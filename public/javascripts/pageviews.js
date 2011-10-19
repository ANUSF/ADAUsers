$(document).ready(function() 
{
    $("button.page-view").click(function() 
    {
        $("div#page-view").empty().html('<img src="/images/page-load.gif"/>')

        $("div#page-view").load(this.id);
    });
});
