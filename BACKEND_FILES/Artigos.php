<?php
header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "1234";
$dbname = "ProjetoP3";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$sql = "SELECT * FROM Articles";
$result = $conn->query($sql);

$articles = array();
while ($row = $result->fetch_assoc()) {
    $articles[] = $row;
}

$response = array(
    "status" => "success",
    "articles" => $articles
);

echo json_encode($response);

$conn->close();
?>
