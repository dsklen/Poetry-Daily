<?php

include_once('simple_html_dom.php');

if(isset($_REQUEST['date'])){
	$id = $_REQUEST['date'];
	$html = file_get_html("http://poems.com/poem.php?date=" . $id);
	
	$poem = $html->find('span#poem', 0)->plaintext;
	$byline = $html->find('span#byline', 0)->plaintext;
	$book_title = $html->find('span#book_title', 0)->plaintext;
	$publisher = $html->find('span#publisher', 0)->plaintext;
	$date = str_replace("Poem for ", "", $html->find('div#date', 0)->plaintext);

	
	$output = array();
	$output['poem'] = utf8_encode($poem);
	$output['byline'] = $byline;
	$output['book_title'] = $book_title;
	$output['publisher'] = $publisher;
	$output['date'] = $date;
	
	echo json_encode($output);

	//echo json_encode($str);
}

?>