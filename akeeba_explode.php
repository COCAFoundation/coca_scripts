<?php

$unpack = false;

function Delete($path)
{
    if (is_dir($path) === true)
    {
        $files = array_diff(scandir($path), array('.', '..'));
        foreach ($files as $file)
        {
            Delete(realpath($path) . '/' . $file);
        }
        return rmdir($path);
    }
    else if (is_file($path) === true){return unlink($path);}
    return false;
}

echo "<h3>Deleting Existing Files</h3>";
$dir = new DirectoryIterator(dirname(__FILE__));
foreach ($dir as $fileinfo) {
  
  //Added to check for .jpa files
  $file_parts = pathinfo($fileinfo);

	if ($file_parts['extension'] != "jpa" && $fileinfo->getFilename() != "explode.php"){
	    if (is_file($fileinfo)) {
	        echo 'Deleted File: '.$fileinfo->getFilename()."</br>";
	        unlink($fileinfo);
	    }else if (is_dir($fileinfo)){
	    	if ($fileinfo->getFilename() != "."  && $fileinfo->getFilename() != ".."){
	    		echo 'Deleted Directory: '.$fileinfo->getFilename()."</br>";
	    		Delete($fileinfo);
	    	}
	    }
	}
}

echo "<hr/>";

echo "<h3>Attempting to Extract public_html.zip</h3>";
$zip = new ZipArchive;
if ($zip->open('public_html.zip') === TRUE) {
    $zip->extractTo(getcwd());
    $zip->close();
    echo '<h3>public_html.zip extraction successful</h3><br/>';
    $unpack = true;
} else {
    echo '<h3>public_html.zip extraction FAILED</h3></br>';
}


if($unpack){
echo "<hr/>";

echo "<h3>Removing exploder and .zip</h3>";

unlink('explode.php');
unlink('public_html.zip');
}


echo "<h3>Completed!</h3>";

?>
