<?php

    /* Code is used to update member page.
       
       Members will have option to:
       
       Display file in obob
       make files public/private
       Delete selected file.
    
    */
    
    require_once('auth.php');
    require_once('config.php');


    if (!isset($_POST['update']))
    {

        // assign names
        $varFile   = $_POST['file'];
        $varURL    = $_POST['url'];
        $varAction = $_POST['action'];
        
        // Making files private.
        if ( $varAction == 'private' )
        {
            
            // Session infomation
            $id    = $_SESSION['SESS_MEMBER_ID'];	
            $fname = $_SESSION['SESS_FIRST_NAME'];
            $lname = $_SESSION['SESS_LAST_NAME'];
            
            // Connect to mysql to capture information.
            $connection = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);
            mysql_select_db("obob_members", $connection) or die(mysql_error());
            
            // collect user info.
            $query = "SELECT * FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
            $result = @mysql_query($query);
            
            if ($result ) {
                
                $user = mysql_fetch_array($result);
                $login = $user['login'];
                
                $_uploaddir = "../../data/obo_files/";
                $uploaddir  = "../../data/obo_files/$login";

                $phrase  = "$varFile";
                $file    = "public_"; 
                $cache   = "";
                $new_file = str_replace($file, $cache, $phrase);
                
                rename("$uploaddir/$varFile", "$uploaddir/$new_file");
                unlink("$_uploaddir/$varFile");                
            
                $update = "UPDATE files SET obo_files = '$new_file' WHERE obo_files = '$varFile'";
                $complete = mysql_query($update);
                
                // to try and remove the graph file remove the .obo
                $tag    = ".obo";
                $remove = "";
                $directory_name = str_replace($tag, $remove, $phrase);
                
                system("rm -r ../img/dag_gif/obob/$directory_name");
                header("location: member-index.php");
            }
        }

        // Making file public.
        if ( $varAction == 'public' )
        {
            // Session infomation
            $id    = $_SESSION['SESS_MEMBER_ID'];	
            $fname = $_SESSION['SESS_FIRST_NAME'];
            $lname = $_SESSION['SESS_LAST_NAME'];
            
            // Connect to mysql to delete file.
            $connection = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);
            mysql_select_db("obob_members", $connection) or die(mysql_error());
            
            // delete file from directory.
            $query = "SELECT * FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
            $result = @mysql_query($query);

            if ($result)
            {
                $user = mysql_fetch_array($result);
                $login = $user['login'];
                $email = $user['email'];
                
                $uploaddir  = "../../data/obo_files/$login/";
                $_uploaddir = "../../data/obo_files/";

                copy("$uploaddir/$varFile", "$_uploaddir/public_$varFile");
                rename("$uploaddir/$varFile", "$uploaddir/public_$varFile");
                
                $url = "www.obobrowser.org/browser/obob.cgi?release=public_$varFile";
                $message = "This is the URL for your public file: $varFile\n $url";
                
                // Send email containing url.
                mail("$email", 'OBOB URL', $message);
                
                $update = "UPDATE files SET obo_files = 'public_$varFile' WHERE obo_files = '$varFile'";
                $complete = mysql_query($update);
                
                // to try and remove the graph file remove the .obo
                $phrase  = "$varFile";

                $file    = "public_"; 
                $cache   = "";
                $new_file = str_replace($file, $cache, $phrase);
                
                $tag    = ".obo";
                $remove = "";
                $directory_name = str_replace($tag, $remove, $phrase);
                
                system("rm -r ../img/dag_gif/obob/$directory_name");
            }
            
            header("location: member-index.php");
        }

        // Displaying file with OBOB
        if ( $varAction == 'display' )
        {
                        // Session infomation
            $id    = $_SESSION['SESS_MEMBER_ID'];	
            $fname = $_SESSION['SESS_FIRST_NAME'];
            $lname = $_SESSION['SESS_LAST_NAME'];
            
            // Connect to mysql to delete file.
            $connection = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);
            mysql_select_db("obob_members", $connection) or die(mysql_error());
            
            // delete file from directory.
            $query = "SELECT * FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
            $result = @mysql_query($query);

            if ($result)
            {
                $user = mysql_fetch_array($result);
                $login = $user['login'];
            
                $check = exec("perl perl_scripts/obo_checker.pl ../../data/obo_files/$login/$varFile 2>perl_scripts/obo_files_errors");
                if ( $check == '1') {
                    $_SESSION['obofile'] = $varFile;
                    header("location: /browser");
                }
                else {
                    header("location: file_type_error.php");
                }
            }
        }

        // just in case.
        if ( $varAction == 'Select Action')
        {
            header("location: member-index.php");
        }

        // Action taken when delete selected.
        if ( $varAction == 'delete' )
        {

            // Session infomation
            $id    = $_SESSION['SESS_MEMBER_ID'];	
            $fname = $_SESSION['SESS_FIRST_NAME'];
            $lname = $_SESSION['SESS_LAST_NAME'];
            
            // Connect to mysql to delete file.
            $connection = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD);
            mysql_select_db("obob_members", $connection) or die(mysql_error());
            $delete = mysql_query("DELETE FROM files WHERE files.obob_member_id = '$id' AND files.obo_files = '$varFile'") or die(mysql_error()); 
            
            // delete file from directory.
            $query = "SELECT login FROM members WHERE member_id = '$id' AND firstname = '$fname' AND lastname = '$lname'";
            $result = @mysql_query($query);

            if ($result)
            {
                $user = mysql_fetch_array($result);
                $login = $user['login'];
                $uploaddir  = "../../data/obo_files/$login/";
                $_uploaddir = "../../data/obo_files/";
                $usr_graph_file = "../../htdocs/img/dag_gif/obob/";

                // new_term is the generated cache to be deleleted as well.
                $phrase  = "$varFile";
                $file    = ".obo"; 
                $cache   = ".cache";
                $new_term = str_replace($file, $cache, $phrase);
            
                // to try and remove the graph file remove the .obo
                $remove = "";
                $directory_name = str_replace($file, $remove, $phrase);
            
                // Delete unwanted file and cache in user and public (if added).
                unlink("$uploaddir/$varFile");
                unlink("$uploaddir/$new_term");
                unlink("$_uploaddir/$varFile");
                unlink("$_uploaddir/$new_term");
                system("rm -r ../img/dag_gif/obob/$directory_name");
                system("rm -r ../img/dag_gif/obob/public_$directory_name");
            }
            
            mysql_close($delete, $result);
            header("location: member-index.php");
        }
    }

    // Bit of a fail safe.
    if(!isset($_POST['update']))
    {
        $errorMessage .= "<li>something is not working!</li>";
    }

?>
