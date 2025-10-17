param([string[]]$InputFiles)

# Relaunch with Windows PowerShell 5.1 + STA (WinForms stable)
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA' -or $PSVersionTable.PSEdition -ne 'Desktop') {
    $ps = "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
    $argList = @('-NoProfile','-ExecutionPolicy','Bypass','-Sta','-File',"`"$PSCommandPath`"") + $InputFiles
    Start-Process -FilePath $ps -ArgumentList $argList | Out-Null
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---------------- Path base (relative) ----------------
$scriptDir = Split-Path -Parent $PSCommandPath
$rootDir   = Resolve-Path (Join-Path $scriptDir "..")

# ---------------- Config ----------------
$outDir = Join-Path $rootDir "Er_Still2Vid"
if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }
$imgExt = @('.jpg','.jpeg','.png','.bmp','.webp','.tif','.tiff')

# ---------------- ffmpeg path (relative) ----------------
$ffmpegPath = Join-Path $rootDir "ffmpeg.exe"
if (-not (Test-Path $ffmpegPath)) {
    try {
        $null = Get-Command ffmpeg -ErrorAction Stop
        $ffmpegPath = "ffmpeg"   # fallback to PATH
    } catch {
        [System.Windows.Forms.MessageBox]::Show("ffmpeg not found.`nPlease place it at:`n$($ffmpegPath)","Missing ffmpeg","OK","Error") | Out-Null
        exit
    }
}

# ---------------- Inputs ----------------
if (-not $InputFiles -or $InputFiles.Count -eq 0) {
    $ofd = New-Object Windows.Forms.OpenFileDialog
    $ofd.Filter = "Images|*.jpg;*.jpeg;*.png;*.bmp;*.webp;*.tif;*.tiff"
    $ofd.Multiselect = $true
    if ($ofd.ShowDialog() -ne [Windows.Forms.DialogResult]::OK) { exit }
    $InputFiles = $ofd.FileNames
}
$InputFiles = $InputFiles | Where-Object { $_ -and (Test-Path $_) -and ($imgExt -contains ([IO.Path]::GetExtension($_).ToLower())) }
if (-not $InputFiles -or $InputFiles.Count -eq 0) {
    [Windows.Forms.MessageBox]::Show("No valid image files.","Error","OK","Error") | Out-Null
    exit
}

# ---------------- GUI ----------------
$form = New-Object Windows.Forms.Form
$form.Text = "Still → MP4"
$form.StartPosition = "CenterScreen"
$form.Size = New-Object Drawing.Size(480,300)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false

$lblList = New-Object Windows.Forms.Label
$lblList.Text = "Files:"
$lblList.Location = "10,10"
$lblList.AutoSize = $true
$form.Controls.Add($lblList)

$txtList = New-Object Windows.Forms.TextBox
$txtList.Location = "10,30"
$txtList.Size = New-Object Drawing.Size(440,80)
$txtList.Multiline = $true
$txtList.ScrollBars = 'Vertical'
$txtList.ReadOnly = $true
$txtList.Text = ($InputFiles -join "`r`n")
$form.Controls.Add($txtList)

$lblFrames = New-Object Windows.Forms.Label
$lblFrames.Text = "Duration (frames):"
$lblFrames.Location = "10,130"
$lblFrames.AutoSize = $true
$form.Controls.Add($lblFrames)

$numFrames = New-Object Windows.Forms.NumericUpDown
$numFrames.Location = "160,125"
$numFrames.Minimum = 1
$numFrames.Maximum = 100000
$numFrames.Value = 150
$form.Controls.Add($numFrames)

$lblFps = New-Object Windows.Forms.Label
$lblFps.Text = "Framerate (fps):"
$lblFps.Location = "10,165"
$lblFps.AutoSize = $true
$form.Controls.Add($lblFps)

$numFps = New-Object Windows.Forms.NumericUpDown
$numFps.Location = "160,160"
$numFps.Minimum = 1
$numFps.Maximum = 240
$numFps.Value = 30
$form.Controls.Add($numFps)

$btnRun = New-Object Windows.Forms.Button
$btnRun.Text = "Create MP4"
$btnRun.Location = "10,210"
$btnRun.Size = New-Object Drawing.Size(120,35)
$form.Controls.Add($btnRun)

$txtLog = New-Object Windows.Forms.TextBox
$txtLog.Location = "10,255"
$txtLog.Size = New-Object Drawing.Size(440,30)
$txtLog.ReadOnly = $true
$form.Controls.Add($txtLog)

function Log([string]$m){$txtLog.Text=$m;$txtLog.Refresh()}

# ---------------- Run ----------------
$btnRun.Add_Click({
    $frames = [int]$numFrames.Value
    $fps = [int]$numFps.Value
    $allOk = $true

    foreach ($f in $InputFiles) {
        if (-not (Test-Path $f)) { continue }
        $name = [IO.Path]::GetFileNameWithoutExtension($f)
        $out = Join-Path $outDir ("{0}_{1}fps_{2}f.mp4" -f $name, $fps, $frames)
        Log "Encoding: $out"

        $args = @(
            "-y","-loop","1","-i",$f,
            "-r",$fps,
            "-frames:v",$frames,
            "-vf","format=yuv420p,scale=trunc(iw/2)*2:trunc(ih/2)*2",
            "-c:v","libx264","-preset","ultrafast","-crf","20",
            "-pix_fmt","yuv420p","-movflags","+faststart","-an",$out
        )
        & $ffmpegPath @args
        if ($LASTEXITCODE -eq 0) {
            Log "✅ Done: $out"
        } else {
            Log "❌ ffmpeg error on: $f"
            $allOk = $false
        }
    }

    if ($allOk) {
        Log "✅ All done"
        Start-Sleep -Milliseconds 500
        $form.Close()   # auto-close window
    } else {
        Log "⚠️ Some files failed (window stays open)"
    }
})

[void]$form.ShowDialog()
