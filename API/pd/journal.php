<?php

include_once('simple_html_dom.php');

if(isset($_REQUEST['date'])){
	$id = $_REQUEST['date'];
	$html = file_get_html("http://poems.com/feature.php?date=" . $id);
	
	$name = $html->find('div#book_info strong em', 0)->plaintext;
	$image = $html->find('div#book_info p img.feature_image', 0)->src;
	$description = $html->find('div#book_info p', 1)->plaintext;
	$url = $html->find('span#book_title a', 0)->href;

	$output = array();
	$output['name'] = $name;
	$output['image'] = $image;
	$output['description'] = utf8_encode($description);
	$output['url'] = $url;


	echo json_encode($output);

}

?>