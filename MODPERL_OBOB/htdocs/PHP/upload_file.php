<?php

/* This code will accept users personal files
   and accept URL's.  These files will be
   added to user's directory and to the
   database
*/

// caputre information to match.
require_once('auth.php');
require_once('config.php');

//Connect to mysql server
$link = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);

if(!$link)
{
	die('Failed to connect to server: ' . mysql_error());
}

//Select database
$db = mysql_select_db(DB_DATABASE);

// Session infomation
$id    = $_SESSION['SESS_MEMBER_ID'];	
$fname = $_SESSION['SESS_FIRST_NAME'];
$lname = $_SESSION['SESS_LAST_NAME'];

// uploaded file information.
$name 	= $_FILES["file"]["name"];
$temp   = $_FILES["file"]["tmp_name"];
$type	= $_FILES["file"]["type"];

if ( $name ){

	// check and see if the file ends in .obo
	$obo_match = '/obo$/';
	$is_obo = preg_match($obo_match, $name);

	if ( ! $is_obo  ) { 
		header("location: upload-file-error.php"); 
		die;
	}
	
	// open file and read the first
	// 5k characters.
	$fh = fopen($temp, 'r');
	$data = fread($fh, 9000);
	fclose($fh);

	// checks for term and obo required tags http://www.geneontology.org/GO.format.obo-1_2.shtml#S.2
	$term_match = '/[Term]/i';
	$id_name    = '/name:/';
	$term_relat = '/[Typedef]/i';
	
	$is_term = preg_match($term_match, $data);
	$is_name = preg_match($id_name, $data);
	$is_rel  = preg_match($term_relat, $pdata);
	
	// Handles user uploaded files.
	if ( $is_name && $is_term || $is_rel ) 
	{			
		$query = "SELECT * FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
		$result = @mysql_query($query);
		
		if ($result)
		{
			// Get username from database
			$user  = mysql_fetch_array($result);
			$login = $user['login'];
			$email = $user['email'];
	
			$uploaddir = "../../data/obo_files/$login/";
			move_uploaded_file("$temp", "$uploaddir/$name");
			
			// if user set to private.
			if ( $_POST["permission"] )
			{
				$_uploaddir = "../../data/obo_files/";
				copy("$uploaddir/$name", "$_uploaddir/public_$name");
				copy("$uploaddir/$name", "$uploaddir/public_$name");

				$url = "www.obobrowser.org/browser/obob.cgi?release=public_$name";
				$message = "This is the URL for your public file: $name\n $url";
	
				// Send email containing url.
				mail("$email", 'OBOB URL', $message);
			}
	
			//Add file information to database.
			if ( $_POST["permission"]) {
				$add = mysql_query("INSERT INTO files (obob_member_id, obo_files) VALUES ('$id', 'public_$name')");
			}
			else {
				$add = mysql_query("INSERT INTO files (obob_member_id, obo_files) VALUES ('$id', '$name')");
			}
			
			if( ! $add)
			{
				die('Invalid query: ' . mysql_error());
			}
			
		}
		
		mysql_close($result);
		mysql_close($add);
		header("location: member-index.php");
		exit;
	}
	else{
		header("location: upload-file-error.php");
		exit;
	}
}


// Handles URL files.
if ( $_POST )
{

	$web = array();
	foreach ($_POST as $key => $value)
	{
		$web[] = "$value";
	}

	// open the url to read.
	$lines = file("$web[0]");
	$ph    = fopen($web[0], 'rb');
	$pdata = fread($ph, 5000);
	fclose($fh);	

	// checks for term and obo required tags http://www.geneontology.org/GO.format.obo-1_2.shtml#S.2
	// as a method of file check.
	$term_match = '/[Term]/i';
	$term_relat = '/[Typedef]/i';
	$id_name    = '/name:/';
		
	$post_term = preg_match($term_match, $pdata);
	$post_name = preg_match($id_name, $pdata);
	$post_rel  = preg_match($term_relat, $pdata);
	
	if ( $post_name && $post_term || $post_rel )
	{
		$query = "SELECT * FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
		$result = @mysql_query($query);
	
		if ($result)
		{
			// Get username from database
			$user  = mysql_fetch_array($result);
			$login = $user['login'];
			$email = $user['email'];
			
			// reads file and places content into user folder.
			$uploaddir = "../../data/obo_files/$login/";
			$filename = basename("$web[0]");
			$src   	  = fopen("$web[0]", "rb");
			$dest1    = fopen("$uploaddir/$filename", 'w') or die("can't open file");
			stream_copy_to_stream($src, $dest1);

			if ( $_POST["permission"] )
			{
				$_uploaddir = "../../data/obo_files/";
				copy("$uploaddir/$filename", "$_uploaddir/public_$filename");
				copy("$uploaddir/$filename", "$uploaddir/public_$filename");					
				
				$url = "www.obobrowser.org/browser/obob.cgi?release=public_$filename";
				$message = "This is the URL for your public file: $filename\n $url";
	
				// Send email containing url.
				mail("$email", 'OBOB URL', $message);
			}
			
			fclose($src);
			fclose($dest1);
	
			//Add file information to database.
			if ( $_POST["permission"]) {
				$add = mysql_query("INSERT INTO files (obob_member_id, obo_files) VALUES ('$id', 'public_$filename')");
			
			}
			else{
				$add = mysql_query("INSERT INTO files (obob_member_id, obo_files) VALUES ('$id', '$filename')");
			}
			
			if (! $add)
			{
				die('Invalid query: ' . mysql_error());
			}
			
			mysql_close($result);		
			mysql_close($add);
			header("location: member-index.php");
			exit;
		}
	}
	else {
		header("location: upload-file-error.php");
		exit;
	}
}

?>
