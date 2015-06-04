<?php

/**
* Password Reset - Used for allowing a user to reset password

// NOT WORKING AT THIS TIME.

*/
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
       
       // This section makes the change.
       if (isset($_POST['email'])) {
       
	   if ($_POST['email']=='') {
	       error('Please Fill in Email.');
	   }
       
	   if(get_magic_quotes_gpc()) {
	       $email = htmlspecialchars(stripslashes($_POST['email']));
	   } 
	   else {
	       $email = htmlspecialchars($_POST['email']);
	   }
       
	   //Make sure it's a valid email address, last thing we want is some sort of exploit!
	   if (!check_email_address($_POST['email'])) {
	       error('Email Not Valid - Must be in format similar to name@domain.com');
	   }
   
	   // Lets see if the email exists
	   $sql = "SELECT * FROM members WHERE email = '$email'";
	   $result = mysql_query($sql) or die('Could not find member: ' . mysql_error());
	   
	   if ( ! mysql_result($result,0,0)>0) {
	       error('Email Not Found!');
	   }

	   //Generate a RANDOM MD5 Hash for a password
	   $random_password=md5(uniqid(rand()));
       
	   //Take the first 8 digits and use them as the password we intend to email the user
	   $emailpassword=substr($random_password, 0, 8);
       
	   //Encrypt $emailpassword in MD5 format for the database
	   $newpassword = md5($emailpassword);
       
	   // Make a safe query
	   $query = sprintf("UPDATE `members` SET `passwd` = '%s'
			    WHERE `email` = '$email'", mysql_real_escape_string($newpassword));
				       
	   mysql_query($query) or die('Could not update members: ' . mysql_error());

       	   //Email out the infromation
	   $from    = "OBOB";	   
	   $subject = "Your Temporary Password"; 
	   $message = "Your temporary password is as follows:
	   
	   ---------------------------- 

	   Password: $emailpassword
	   
	   ---------------------------- 

	   Please change your password here.
	   www.obobrowser.org/PHP/update-password.php
	   

	   Please make note this information has been encrypted into our database 
	   This email was automatically generated."; 
				  
	   if( ! mail($email, $subject, $message,  "FROM: $from <$site_email>")){ 
	       die ("Sending Email Failed, Please Contact Site Admin! ($site_email)"); 
	   } 
       }
       

       //This functions checks and makes sure the email address that is being added to database is valid in format. 
       function check_email_address($email) {
	   
	   // First, we check that there's one @ symbol, and that the lengths are right
	   // Email invalid because wrong number of characters in one section, or wrong number of @ symbols.
	   if (!ereg("^[^@]{1,64}@[^@]{1,255}$", $email)) {
	       return false;
	   }
       
	   // Split it into sections to make life easier
	   $email_array = explode("@", $email);
	   $local_array = explode(".", $email_array[0]);
	   for ($i = 0; $i < sizeof($local_array); $i++) {
	       if (!ereg("^(([A-Za-z0-9!#$%&'*+/=?^_`{|}~-][A-Za-z0-9!#$%&'*+/=?^_`{|}~\.-]{0,63})|(\"[^(\\|\")]{0,62}\"))$", $local_array[$i])) {
		   return false;
	       }
	   }
       
	   if (!ereg("^\[?[0-9\.]+\]?$", $email_array[1])) { // Check if domain is IP. If not, it should be valid domain name
	       $domain_array = explode(".", $email_array[1]);
	       if (sizeof($domain_array) < 2) {
		   return false; // Not enough parts to domain
	       }
	 
	       for ($i = 0; $i < sizeof($domain_array); $i++) {
		   if (!ereg("^(([A-Za-z0-9][A-Za-z0-9-]{0,61}[A-Za-z0-9])|([A-Za-z0-9]+))$", $domain_array[$i])) {
		       return false;
		   }
	       }
	   }	
       
	   return true;
       }
       header("location: update-password.php");
       
?>
