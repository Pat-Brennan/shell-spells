$(document).ready(function () {
	$("li:contains('Subaudience?') input").replaceWith(
		'<select name="subaudience" tabindex="1">' +
			'<option value="x">Any</option>' +
			'<option value="a">Preschool</option>' +
			'<option value="b">Primary</option>' +
			'<option value="c">Pre-Adolescent</option>' +
			'<option value="d">Adolescent</option>' +
			'<option value="e">Adult</option>' +
			'<option value="g">General</option>' +
			'<option value="j">Juvenile</option>' +
			"</select>"
	);
});
