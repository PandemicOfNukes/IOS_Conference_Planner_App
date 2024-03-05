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

$data = json_decode(file_get_contents('php://input'), true);

if (isset($data['ArticleID'])) {
    $id = $data['ArticleID'];
    $title = $data['Title'];
    $author = $data['Author'];
    $content = $data['Content'];

    $sql = "UPDATE Articles SET Title='$title', Author='$author', Content='$content' WHERE ArticleID=$id";

    if ($conn->query($sql) === TRUE) {
        $response = array("status" => "success");
        echo json_encode($response);
    } else {
        $response = array("status" => "error", "message" => $conn->error);
        echo json_encode($response);
    }
} else {
    $response = array("status" => "error", "message" => "Invalid request. Required fields are missing.");
    echo json_encode($response);
}

$conn->close();
?>