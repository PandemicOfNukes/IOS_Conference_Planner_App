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
    $articleID = $data['ArticleID'];

    $deleteSchedulesSql = "DELETE FROM Schedules WHERE ArticleID = $articleID";
    if ($conn->query($deleteSchedulesSql) !== TRUE) {
        $response = array("status" => "error", "message" => "Error deleting associated schedules: " . $conn->error);
        echo json_encode($response);
        exit();
    }

    $deleteQuestionsSql = "DELETE FROM Perguntas WHERE ArticleID = $articleID";
    if ($conn->query($deleteQuestionsSql) !== TRUE) {
        $response = array("status" => "error", "message" => "Error deleting associated questions: " . $conn->error);
        echo json_encode($response);
        exit();
    }

    $deleteArticleSql = "DELETE FROM Articles WHERE ArticleID = $articleID";
    if ($conn->query($deleteArticleSql) === TRUE) {
        $response = array("status" => "success", "message" => "Article and associated data deleted successfully");
        echo json_encode($response);
    } else {
        $response = array("status" => "error", "message" => "Error deleting article: " . $conn->error);
        echo json_encode($response);
    }
} else {
    $response = array("status" => "error", "message" => "Invalid request. Required fields are missing.");
    echo json_encode($response);
}

$conn->close();
?>
