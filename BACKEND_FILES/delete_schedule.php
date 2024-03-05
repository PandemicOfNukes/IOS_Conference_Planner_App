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

if (isset($data['ScheduleID'])) {
    $id = $data['ScheduleID'];

    $sql = "DELETE FROM Schedules WHERE ScheduleID = $id";

    if ($conn->query($sql) === TRUE) {
        $response = array("status" => "success", "message" => "Schedule deleted successfully.");
        echo json_encode($response);
    } else {
        $response = array("status" => "error", "message" => $conn->error);
        echo json_encode($response);
    }
} else {
    $response = array("status" => "error", "message" => "Invalid request. Required field (ScheduleID) is missing.");
    echo json_encode($response);
}

$conn->close();
?>
