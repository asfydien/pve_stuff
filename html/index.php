<?php
$directory = '.';
$files = array_diff(scandir($directory), array('..', '.'));

// Daftar file yang ingin disembunyikan
$hiddenFiles = ['index.php', '.htaccess', '.env'];

function formatSize($size) {
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    $i = 0;
    while ($size >= 1024 && $i < count($units) - 1) {
        $size /= 1024;
        $i++;
    }
    return round($size, 2) . ' ' . $units[$i];
}

function getFileIcon($file) {
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    $icons = [
        'jpg' => '📷', 'jpeg' => '📷', 'png' => '🖼️', 'gif' => '🖼️',
        'pdf' => '📄', 'doc' => '📝', 'docx' => '📝', 'txt' => '📜',
        'zip' => '📦', 'rar' => '📦', 'mp3' => '🎵', 'mp4' => '🎬',
        'html' => '🌍', 'css' => '🎨', 'js' => '📜', 'php' => '🐘'
    ];
    return is_dir($file) ? '📁' : ($icons[$ext] ?? '📄');
}

$folders = [];
$otherFiles = [];
foreach ($files as $file) {
    if (in_array($file, $hiddenFiles)) {
        continue;
    }
    if (is_dir($file)) {
        $folders[] = $file;
    } else {
        $otherFiles[] = $file;
    }
}

sort($folders);
sort($otherFiles);
$sortedFiles = array_merge($folders, $otherFiles);

$browser = $_SERVER['HTTP_USER_AGENT'];
$phpVersion = phpversion();
$serverSoftware = $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown';
$parentDir = dirname($_SERVER['REQUEST_URI']);
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>File Index</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; padding: 10px; background-color: #f4f4f4; }
        .container { max-width: 900px; margin: auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; border-bottom: 1px solid #ddd; text-align: left; }
        th { background-color: #f8f8f8; }
        td:nth-child(2) { width: 50%; }
        a { text-decoration: none; color: #333; }
        .footer { margin-top: 20px; padding: 10px; background: #ddd; text-align: center; font-size: 14px; border-radius: 5px; }
        .footer a { color: blue; }
        .footer span.blue { color: blue; font-weight: bold; }
        .popup { display: none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 20px; border-radius: 10px; box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); max-width: 80%; max-height: 80%; overflow: auto; }
        .popup-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; position: sticky; top: 0; background: rgba(255, 255, 255, 0.9); padding: 10px; border-bottom: 1px solid #ddd; }
        .popup-close { cursor: pointer; color: red; font-weight: bold; width: 30px; height: 30px; border: 2px solid red; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .popup-controls { display: flex; align-items: center; }
        .popup-controls button { margin-right: 5px; }
        .icon-button { background: none; border: none; cursor: pointer; padding: 5px; }
    </style>
    <script>
        function showPopup(content) {
            document.getElementById("popup-content").innerText = content;
            document.getElementById("popup").style.display = "block";
        }
        function closePopup() {
            document.getElementById("popup").style.display = "none";
        }
        function loadTextFile(file) {
            fetch(file).then(response => response.text()).then(data => showPopup(data));
        }
        function increaseFontSize() {
            var content = document.getElementById("popup-content");
            var style = window.getComputedStyle(content, null).getPropertyValue('font-size');
            var currentSize = parseFloat(style);
            content.style.fontSize = (currentSize + 2) + 'px';
        }
        function decreaseFontSize() {
            var content = document.getElementById("popup-content");
            var style = window.getComputedStyle(content, null).getPropertyValue('font-size');
            var currentSize = parseFloat(style);
            content.style.fontSize = (currentSize - 2) + 'px';
        }
    </script>
</head>
<body>
    <div class="container">
        <h2>Daftar File</h2>
        <table>
            <tr>
                <th>Ikon</th>
                <th>Nama File</th>
                <th>Ukuran</th>
                <th>Tanggal Dibuat</th>
                <th>Aksi</th>
            </tr>
            <tr>
                <td>↩️</td>
                <td><a href="<?= htmlspecialchars($parentDir) ?>/">Parent Directory</a></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <?php foreach ($sortedFiles as $file): ?>
                <tr>
                    <td><?= getFileIcon($file) ?></td>
                    <td><a href="<?= is_dir($file) ? $file . '/' : $file ?>"> <?= $file ?> </a></td>
                    <td><?= is_dir($file) ? '' : formatSize(filesize($file)) ?></td>
                    <td><?= date("Y-m-d H:i:s", filectime($file)) ?></td>
                    <td>
                        <?php if (!is_dir($file)): ?>
                            <a href="<?= $file ?>" download class="icon-button">⬇️</a>
                        <?php endif; ?>
                        <?php if (pathinfo($file, PATHINFO_EXTENSION) === 'txt'): ?>
                            <button class="icon-button" onclick="loadTextFile('<?= $file ?>')">🔍</button>
                        <?php endif; ?>
                    </td>
                </tr>
            <?php endforeach; ?>
        </table>
        <div class="footer">
            Browser: <?= htmlspecialchars($browser) ?> | Server: <?= htmlspecialchars($serverSoftware) ?> | PHP <?= $phpVersion ?><br>
            <span class="blue">Goah</span> was <span style="font-family: monospace;">&lt;/&gt;</span> with ❤️ by <a href="https://github.com/asfydien" target="_blank"><span class="blue">Asfydien</span></a>
        </div>
    </div>
    <div id="popup" class="popup">
        <div class="popup-header">
            <div class="popup-controls">
                <button onclick="increaseFontSize()">A+</button>
                <button onclick="decreaseFontSize()">A-</button>
            </div>
            <span class="popup-close" onclick="closePopup()">×</span>
        </div>
        <pre id="popup-content"></pre>
    </div>
</body>
</html>
