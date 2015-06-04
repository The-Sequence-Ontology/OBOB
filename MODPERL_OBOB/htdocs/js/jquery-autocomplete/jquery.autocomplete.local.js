function formatResult(row) {
    display = row[0];
    display = display.replace(/(<.+?>)/gi, '');
    display = display.replace(/(\[.+?\])/gi, '');
    display = display.replace(/^\s+|\s+$/g, '');
    return display;
}

$(document).ready(function(){
    $('#obo_query').autocomplete('[% cgi_path %]obob.cgi', { extraParams:  { rm:      'autocomplete',
                                                                       release: function() { return $("#release").val(); }},
                                                       formatResult: formatResult  });
});
