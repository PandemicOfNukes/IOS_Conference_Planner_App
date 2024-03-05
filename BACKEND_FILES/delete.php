<?php
$back = "http://localhost/Index.html";
if (isset($_POST['submit'])) {
    $articleID = $_POST['articleID'];

    $servername = "localhost";
    $username = "root";
    $password = "1234";
    $dbname = "ProjetoP3";

    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        echo "<a href='$back'>Voltar Atrás</a><br>";
        die("Conexão falhou: " . $conn->connect_error);
    }

    $checkIDQuery = "SELECT * FROM Articles WHERE ArticleID = $articleID";
    $result = $conn->query($checkIDQuery);

    if ($result->num_rows == 0) {
        echo "Erro: ArticleID não existe.";
        echo "<br>";
        echo "<a href='$back'>Voltar Atrás</a>";
    } else {
        $row = $result->fetch_assoc();
        $pdfFileName = $row['PDF'];

        $targetFolder = 'PDF/';
        $filePath = $targetFolder . $pdfFileName;

        if (file_exists($filePath)) {
            unlink($filePath);
        } else {
            echo "Erro: PDF não encontrado";
            echo "<br>";
            echo "<a href='$back'>Voltar Atrás</a>";
        }

        // Update the database to remove the PDF filename
        $updateQuery = "UPDATE Articles SET PDF='' WHERE ArticleID=$articleID";

        if ($conn->query($updateQuery) === TRUE) {
            echo "PDF deletado com sucesso";
            echo "<br>";
            echo "<a href='$back'>Voltar Atrás</a>";
        } else {
            echo "Erro a eliminar PDF: " . $conn->error;
            echo "<br>";
            echo "<a href='$back'>Voltar Atrás</a>";
        }
    }

    $conn->close();
}
?>
