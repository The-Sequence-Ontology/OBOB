<?php
	//Start session
	session_start();
	
	//Include database connection details
	require_once('config.php');

	//Connect to mysql server
	$link = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);

	if(!$link) {
		die('Failed to connect to server: ' . mysql_error());
	}

	//Select database
	$db = mysql_select_db(DB_DATABASE);

	if(!$db) {
		die("Unable to select database");
	}
	
	//Function to sanitize values received from the form. Prevents SQL injection
	function clean($str) {
		$str = @trim($str);
		if(get_magic_quotes_gpc()) {
			$str = stripslashes($str);
		}
		return mysql_real_escape_string($str);
	}

	//Sanitize the POST values
	$fname 	   = clean($_POST['fname']);
	$lname     = clean($_POST['lname']);
	$login     = clean($_POST['login']);
	$email 	   = clean($_POST['email']);
	$location  = clean($_POST['location']);
	$password  = clean($_POST['password']);
	$cpassword = clean($_POST['cpassword']);
	
	if (! $fname && $lname && $login && $email && $location && $password && $cpassword ) {
		die( header("location: login-failed.php"));		
	}

	//Check for duplicate login ID
	$qrylogin = "SELECT * FROM members WHERE login ='$login'";
	$result   = mysql_query( $qrylogin ) or die( mysql_error() );
	$hits     = mysql_num_rows($result);
	
	if( $hits > 0 )
	{
		header("location: register-failed.php");
		mysql_free_result($result);
		exit;
	}
	else
	{	
	
		// new user get a directory to store files.
		mkdir("../../data/obo_files/$login", 0755);	
		
		//Create INSERT query
		$qry = "INSERT INTO members(firstname, lastname, login, email, institution, passwd) VALUES('$fname','$lname','$login','$email','$location','".md5($_POST['password'])."')";
		$result = @mysql_query($qry);
	
		//Check whether the query was successful or not
		if($result)
		{
			header("location: register-success.php");
			exit();
		}
		else
		{
			die("Query failed");
		}
	}
?>









