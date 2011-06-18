<?

var_dump($_POST);
var_dump($_GET);

include('functions.php');
print is_valid_runner('RUBIN');

if (function_exists('mysqli')) {
    echo "Yes. mysqli is working<br />\n";
} else {
    echo "No. mysqli isn't working :(<br />\n";
}

if (function_exists('mysqli_connect')) {
    echo "Oh, wait. mysqli is actually working<br />\n";
} else {
    echo "No. mysqli really isn't working :(<br />\n";
}

phpinfo();
?>
