param(
  [string]$ArgFile,
  [string[]]$InputPaths
)

# ---------- Config (relative: one level up from this script) ----------
$scriptDir = Split-Path -Parent $PSCommandPath
$rootDir   = Resolve-Path (Join-Path $scriptDir "..")

$outDir  = Join-Path $rootDir "Er_Still2Vid"
$ffmpeg  = Join-Path $rootDir "ffmpeg.exe"
$ffprobe = Join-Path $rootDir "ffprobe.exe"

$imgExt  = @('.jpg','.jpeg','.png','.bmp','.webp','.tif','.tiff')
$vidExt  = @('.mp4','.mov','.mkv','.avi','.wmv','.m4v','.webm')

if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory | Out-Null }

# Prefer local relative tools; otherwise fall back to PATH
if (-not (Test-Path $ffmpeg)) {
  $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($cmd) { $ffmpeg = $cmd.Source } else { Write-Host "ERROR: ffmpeg.exe not found at $ffmpeg"; exit 1 }
}
if (-not (Test-Path $ffprobe)) {
  $cmd = Get-Command ffprobe -ErrorAction SilentlyContinue
  if ($cmd) { $ffprobe = $cmd.Source } else { $ffprobe = $null }
}

# ---------- อ่านพาธทั้งหมด (จากไฟล์/อาร์กิวเมนต์) ----------
$all = @()
if ($ArgFile -and (Test-Path $ArgFile)) {
  try { $all += Get-Content -LiteralPath $ArgFile -ErrorAction Stop } catch {}
}
if ($InputPaths) { $all += $InputPaths }

if (-not $all -or $all.Count -eq 0) {
  Write-Host "USAGE: drag images + a reference video onto the .bat file."
  exit 2
}

# ---------- รวมไฟล์จากโฟลเดอร์ และคัดกรอง ----------
function Collect-Files([string[]]$paths, [string[]]$exts) {
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($p in ($paths | Where-Object { $_ })) {
    try {
      $q = $p.Trim('"')
      if (-not (Test-Path $q)) { continue }
      $rp = (Resolve-Path $q).Path
      if ((Get-Item $rp).PSIsContainer) {
        Get-ChildItem -LiteralPath $rp -Recurse -File | ForEach-Object {
          if ($exts -contains ([IO.Path]::GetExtension($_.FullName).ToLower())) { $out.Add($_.FullName) }
        }
      } else {
        if ($exts -contains ([IO.Path]::GetExtension($rp).ToLower())) { $out.Add($rp) }
      }
    } catch {}
  }
  return $out
}

$images = Collect-Files -paths $all -exts $imgExt
$videos = Collect-Files -paths $all -exts $vidExt

if (-not $videos -or $videos.Count -eq 0) { Write-Host "ERROR: No reference video provided."; exit 3 }
if (-not $images -or $images.Count -eq 0) { Write-Host "ERROR: No images found."; exit 4 }

# ใช้วิดีโอไฟล์แรกเป็น reference
$refVideo = $videos | Select-Object -First 1

Write-Host "Reference video:"
Write-Host "  $refVideo"
Write-Host ""

# ---------- ตรวจจับ FPS และจำนวนเฟรมรวม ----------
function Get-VideoMeta {
  param([string]$videoPath)

  # 1) ใช้ ffprobe ถ้ามี: avg_frame_rate, nb_frames (หรือ nb_read_frames), duration
  if ($ffprobe) {
    $fpsStr = & $ffprobe -v error -select_streams v:0 -show_entries stream=avg_frame_rate -of default=nokey=1:noprint_wrappers=1 "$videoPath" 2>$null
    if (-not $fpsStr) {
      $fpsStr = & $ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=nokey=1:noprint_wrappers=1 "$videoPath" 2>$null
    }

    $nbfStr = & $ffprobe -v error -select_streams v:0 -show_entries stream=nb_frames -of default=nokey=1:noprint_wrappers=1 "$videoPath" 2>$null
    if (-not $nbfStr -or $nbfStr -eq "N/A") {
      # ลองนับจริงด้วย -count_frames -> nb_read_frames
      $nbfStr = & $ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$videoPath" 2>$null
    }
    $durStr = & $ffprobe -v error -show_entries format=duration -of default=nokey=1:noprint_wrappers=1 "$videoPath" 2>$null

    $fps = $null; $frames = $null; $dur = $null
    if ($fpsStr) {
      if ($fpsStr -match '^\s*(\d+)\s*/\s*(\d+)\s*$') { $fps = [double]$matches[1] / [double]$matches[2] }
      else { [double]::TryParse($fpsStr, [ref]$fps) | Out-Null }
    }
    if ($nbfStr -and $nbfStr -ne "N/A") { [int]::TryParse($nbfStr, [ref]$frames) | Out-Null }
    if (-not $frames -and $durStr -and $fps -gt 0) {
      [double]::TryParse(($durStr -replace ",","."), [ref]$dur) | Out-Null
      if ($dur -gt 0) { $frames = [int]([math]::Round($fps * $dur)) }
    }
    if ($fps -gt 0 -and $frames -gt 0) { return @{ fps=$fps; frames=$frames } }
  }

  # 2) fallback: parse ffmpeg -i
  $info = & $ffmpeg -hide_banner -i "$videoPath" 2>&1
  $joined = ($info -join "`n")
  $fps = $null; $frames = $null

  $m2 = [regex]::Match($joined, '(\d+(\.\d+)?)\s*(fps|tbr)')
  if ($m2.Success) { [double]::TryParse($m2.Groups[1].Value, [ref]$fps) | Out-Null }

  $duration = $null
  $m = [regex]::Match($joined, 'Duration:\s*(\d{2}):(\d{2}):(\d{2})(?:\.(\d+))?')
  if ($m.Success) {
    $h=[int]$m.Groups[1].Value; $mi=[int]$m.Groups[2].Value; $s=[int]$m.Groups[3].Value
    $frac=0; if ($m.Groups[4].Success) { [double]::TryParse("0."+$m.Groups[4].Value,[ref]$frac) | Out-Null }
    $duration = $h*3600 + $mi*60 + $s + $frac
  }
  if ($fps -gt 0 -and $duration -gt 0) { $frames = [int]([math]::Round($fps * $duration)) }

  if ($fps -gt 0 -and $frames -gt 0) { return @{ fps=$fps; frames=$frames } }
  return $null
}

$meta = Get-VideoMeta -videoPath $refVideo
if (-not $meta) { Write-Host "ERROR: Failed to detect FPS/frames from reference video."; exit 5 }

$fps    = [double]("{0:0.###}" -f $meta.fps)
$frames = [int]$meta.frames
if ($frames -lt 1) { $frames = 1 }

Write-Host ("Detected -> FPS: {0}   Frames: {1}" -f $fps, $frames)
Write-Host ""

# ---------- เข้ารหัสภาพทั้งหมด ----------
$ok = $true
foreach ($f in $images) {
  $name = [IO.Path]::GetFileNameWithoutExtension($f)
  $out  = Join-Path $outDir ("{0}_{1}fps_{2}f.mp4" -f $name, ("{0:0.###}" -f $fps), $frames)
  Write-Host "Encoding: $out"

  $args = @(
    "-y","-loop","1","-i",$f,
    "-r",("{0:0.###}" -f $fps),
    "-frames:v",$frames,
    "-vf","format=yuv420p,scale=trunc(iw/2)*2:trunc(ih/2)*2",
    "-c:v","libx264","-preset","ultrafast","-crf","20",
    "-pix_fmt","yuv420p","-movflags","+faststart","-an",$out
  )

  & $ffmpeg @args
  if ($LASTEXITCODE -ne 0) {
    Write-Host "  -> ERROR (ffmpeg) on: $f"
    $ok = $false
  } else {
    Write-Host "  -> Done"
  }
}

if ($ok) {
  Write-Host ""
  Write-Host "All done."
  exit 0
} else {
  Write-Host ""
  Write-Host "Completed with some errors."
  exit 6
}
