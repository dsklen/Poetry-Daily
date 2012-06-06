<?php

include_once('simple_html_dom.php');

if(isset($_REQUEST['date'])){
	$id = $_REQUEST['date'];
	$html = file_get_html("http://poems.com/feature.php?date=" . $id);
	
	$name = $html->find('div#poet_info strong', 0)->plaintext;
	$image = $html->find('div#poet_info p img.feature_image', 0)->src;
	$description = $html->find('div#poet_info p', 1)->plaintext;

	$output = array();
	$output['name'] = $name;
	$output['image'] = $image;
	$output['description'] = utf8_encode($description);


	echo json_encode($output);

}

?>