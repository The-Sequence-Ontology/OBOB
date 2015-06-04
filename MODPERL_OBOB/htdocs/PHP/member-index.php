<?php
	require_once('auth.php');
	require_once('config.php');

?>

<!DOCTYPE html>
<html>
<head>

<title>
Members Area
</title>

<!-- CSS -->
<link rel="stylesheet" href="../css/obob_register_form.css" type="text/css" />
<link rel="stylesheet" href="../css/structure.css" type="text/css" />
<link rel="stylesheet" href="../css/form.css" type="text/css" />

<body id="public">
<div id="container" class="ltr">
<header id="header" class="info">
<h1 align="center"><font-family:"Lucida Grande", Tahoma, Arial, Verdana, sans-serif">OBOB Member Area</font-family></h1>
</header>

<h1 align="center">Welcome <?php echo $_SESSION['SESS_FIRST_NAME'];?>!</h1>

<table><tr align="center"><td background="../img/obob_image.png"><font face="Arial" size="4"><ul>Welcome to the member's area of OBOB, from here you can upload files from your personal computer,
or URL.<p><ul>Files can be set to public or private at upload.  Options include displaying ontology in OBOB, privacy modification, and file deletion.
<p><ul>Public files will include links sent to users via email. However only original users can remove ontologies.<p><ul></font></td></tr></table>

<p><h4>Upload file:</h4><p>

<form action="upload_file.php" method="post" enctype="multipart/form-data">
	<ul>
	
	<li id="foli0" class="notranslate leftHalf    ">
	<label class="desc" id="title0" for="Field0">
	Upload Local Ontology File:
	</label>
	<span>
	<p>
		<input type="file" name="file" id="file" /> <br />
		<input type="checkbox" name="permission" value="public" />Public (default private)<br />
		<input type="submit" name="submit" value="Submit" />
	</span>
	</li>
	
	
	<li id="foli0" class="notranslate rightHalf    ">
	<label class="desc" id="title0" for="Field0">
	Upload Ontology From URL:
	</label>
	<span>
		<input type="text" name="url" size="35" /> <br />
		<input type="checkbox" name="permission" value="public" />Public (default private)<br />
		<input type="submit" value="Submit" name="submit" />
	</span>
	</li>
	</ul>
<p>
</form>

<form action="update_member_page.php" method="post" enctype="multipart/form-data" name="update">
<?php
	//Connect to mysql server
	$link = mysql_connect(DB_HOST, DB_USER, DB_PASSWORD) or die(mysql_error());

	//Select database
	$db = mysql_select_db(DB_DATABASE);

	// collect session information to querry db for file information.
	$id    = $_SESSION['SESS_MEMBER_ID'];	
	$fname = $_SESSION['SESS_FIRST_NAME'];
	$lname = $_SESSION['SESS_LAST_NAME'];

	$result = mysql_query("SELECT DISTINCT files.obo_files FROM files, members WHERE files.obob_member_id = '$id'") or die(mysql_error()); 
	
	function mysql_fetch_all($result) {
		while($row=mysql_fetch_array($result)) {
			$return[] = $row;
		}
		return $return;
	}
	
	// fuction to pull each file from mysql.	
	function create_table($dataArr) {
		for($j = 0; $j < count($dataArr); $j++) {
			return $dataArr[$j];
		}
	}
	
	// makes the table

print <<<END
	<h4>Stored OBO Files</h4>
	<form>
	<select name="file">
END;
	// writing to html with data
	$all = mysql_fetch_all($result);
	for($i = 0; $i < count($all); $i++) {
		$file = create_table($all[$i]);
		echo "<option>$file</option>";
						 
	}


print <<<END
</select>
<select name="action">
	<option value="Select Action">Select Action
	<option value="display">Display in OBOB
	<option value="private">Make Private
	<option value="public">Make Public
	<option value="delete">Delete
</select>
<input type="submit" value="Submit" />
<p>
	
END;
	
	mysql_close($result);	

?>
</form>
</div>

<p align="center"><a href="logout.php"><font size="3">Logout</a></p>

</body>
</html>

