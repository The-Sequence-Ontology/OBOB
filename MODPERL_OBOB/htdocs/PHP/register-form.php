<?php
	session_start();

	if (isset($_SESSION['ERRMSG_ARR']) && $_SESSION['ERRMSG_ARR']) 
	{ 
		echo '<p><ul class="err">'; 
		foreach ($_SESSION['ERRMSG_ARR'] as $msg)    {echo '<li>' . $msg . '</li>';} 
		echo '</ul>'; 
	} 

?>

<!DOCTYPE html>
<html>
<head>

<title>
OBOB Registration
</title>

<!-- CSS -->
<link rel="stylesheet" href="../css/obob_register_form.css" type="text/css" />
<link rel="stylesheet" href="../css/structure.css" type="text/css" />
<link rel="stylesheet" href="../css/form.css" type="text/css" />

<body id="public">
<div id="container" class="ltr">

<h1 id="logo">
</h1>

<form id="loginForm" name="loginForm" class="wufoo topLabel page" method="post" action="register-exec.php">


<header id="header" class="info">
<h1 align="center"><font-family:"Lucida Grande", Tahoma, Arial, Verdana, sans-serif">OBOB Registration</font-family></h1>
<h2 align="center"><font-family:"Lucida Grande", Tahoma, Arial, Verdana, sans-serif">All fields required</font-family></h2>
</header>


<ul>

<li id="foli0" class="notranslate      ">
<label class="desc" id="title0" for="Field0">
Name
</label>
<span>
<input tabindex="1" id="fname" name="fname" type="text" class="field text fn" value="" size="8" tabindex="1" />
<label for="Field0">First</label>
</span>
<span>
<input tabindex="2" id="lname" name="lname" type="text" class="field text ln" value="" size="14" tabindex="2" />
<label for="Field1">Last</label>
</span>
</li>

<li id="foli0" class="notranslate      ">
<label class="desc" id="title0" for="Field0">
Userame
</label>
<span>
<input tabindex="3" id="login" name="login" type="text" class="field text fn" value="" size="8" tabindex="1" />
</span>
</li>

<li id="foli0" class="notranslate leftHalf      ">
<label class="desc" id="title0" for="Field0">
Password
</label>
<span>
<input tabindex="4" id="password" name="password" type="password" class="field text fn" value="" size="8" tabindex="1" />
</span>
</li>

<li id="foli0" class="notranslate rightHalf      ">
<label class="desc" id="title0" for="Field0">
Confirm Password
</label>
<span>
<input tabindex="5" id="cpassword" name="cpassword" type="password" class="field text fn" value="" size="8" tabindex="1" />
</span>
</li>

<li id="foli0" class="notranslate leftHalf      ">
<label class="desc" id="title0" for="Field0">
Institution
</label>
<span>
<input tabindex="6" id="location" name="location" type="text" class="field text medium" value="" size="15" tabindex="1" />
</span>
</li>

<li id="foli9" class="notranslate rightHalf     ">
<label class="desc" id="title9" for="Field9">
Email
</label>
<div>
<input tabindex="7" id="email" name="email" type="email" spellcheck="false" class="field text medium" value="" maxlength="255" tabindex="12" required /> 
</div>
</li>

<input id="saveForm" name="saveForm" class="btTxt submit" type="submit" value="Submit"/></div>


</form>
<a align="center"><a href="../index.html"><font size="4">Home Page</a>

</div>


</body>
</html>
