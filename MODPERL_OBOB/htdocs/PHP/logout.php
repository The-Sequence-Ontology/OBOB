
<?php
	//Start session

	session_start();
	session_unset();
	session_destroy();

	//Unset the variables stored in session
//	unset($_SESSION['SESS_MEMBER_ID']);
//	unset($_SESSION['SESS_FIRST_NAME']);
//	unset($_SESSION['SESS_LAST_NAME']);
	
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Logged Out</title>
<link href="login_style.css" rel="stylesheet" type="text/css" />

</head>

<body>
<h1 align="center">You have been logged out</h1>
<p align="center">&nbsp;</p>
<h2><p align="center">Click here to <a href="login-form.php">Login</a></p><h2>
<h2><p align="center"><a href="../index.html">Welcome Page</a></p><h2>
</body>

</html>
