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

$sql = "SELECT Schedules.*, Articles.Title AS ArticleTitle, Articles.Author AS ArticleAuthor, Articles.Content AS ArticleContent
        FROM Schedules
        INNER JOIN Articles ON Schedules.ArticleID = Articles.ArticleID";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $schedules = array();
    while ($row = $result->fetch_assoc()) {
        $schedule = array(
            "ScheduleID" => $row["ScheduleID"],
            "TrackName" => $row["TrackName"],
            "ContentResumo" => $row["ContentResumo"],
            "SchedDay" => $row["SchedDay"],
            "StartTime" => $row["StartTime"],
            "EndTime" => $row["EndTime"],
            "Room" => $row["Room"],
            "ArticleID" => $row["ArticleID"],
            "ArticleTitle" => $row["ArticleTitle"],
            "ArticleAuthor" => $row["ArticleAuthor"],
            "ArticleContent" => $row["ArticleContent"]
        );
        $schedules[] = $schedule;
    }

    echo json_encode(array("status" => "success", "schedules" => $schedules));
} else {
    $response = array("status" => "error", "message" => "No schedules found");
    echo json_encode($response);
}

$conn->close();
?>
