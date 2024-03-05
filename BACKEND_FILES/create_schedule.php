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

if (isset($data['TrackName'], $data['ContentResumo'], $data['SchedDay'], $data['StartTime'], $data['EndTime'], $data['Room'], $data['ArticleID'])) {
    $trackName = $data['TrackName'];
    $contentResumo = $data['ContentResumo'];
    $schedDay = $data['SchedDay'];
    $startTime = $data['StartTime'];
    $endTime = $data['EndTime'];
    $room = $data['Room'];
    $articleID = $data['ArticleID'];

    $sql = "INSERT INTO Schedules (TrackName, ContentResumo, SchedDay, StartTime, EndTime, Room, ArticleID) VALUES ('$trackName', '$contentResumo', '$schedDay', '$startTime', '$endTime', '$room', $articleID)";

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
