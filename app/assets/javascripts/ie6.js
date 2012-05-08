// ie6.js
$(function() {
	if ($.browser.msie && parseInt($.browser.version, 10) === 6) {
		$('.row div[class^="span"]:last-child').addClass('last-child');
        $('[class*="span"]').addClass('margin-left-20');
        $(':button[class="btn"], :reset[class="btn"], :submit[class="btn"], input[type="button"]').addClass('button-reset');
        $(':checkbox').addClass('input-checkbox');
        $('.pagination li:first-child a').addClass('pagination-first-child');
	}
}); 