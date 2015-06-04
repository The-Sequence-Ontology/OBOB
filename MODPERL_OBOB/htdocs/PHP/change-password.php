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
        
        $login              = $_POST['login']; 
        $newpassword        = $_POST['newpassword']; 
        $confirmnewpassword = $_POST['confirmnewpassword']; 

        //Create query
	$qry="SELECT * FROM members WHERE login='$login' AND passwd='".md5($_POST['password'])."'";
	$result=mysql_query($qry);

        $result = mysql_query("SELECT passwd FROM members WHERE login='$login'"); 

        if( !$result ){  
            echo "The login you entered does not exist";  
        } else {
        
            if( $newpassword = $confirmnewpassword ){
                $changedpasswd = md5($newpassword);
                $sql = mysql_query("UPDATE members SET passwd='$changedpasswd' where login='$login'");
            }
        }   
        header("location: login-form.php");
?>

