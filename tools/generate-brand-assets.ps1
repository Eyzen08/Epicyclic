<#
.SYNOPSIS
Regenerates the web app icons and the social preview card from code.

.DESCRIPTION
The icons and the Open Graph card are drawn rather than hand-exported so they
stay reproducible: run this script after changing the brand colours and commit
the generated PNGs in web/.

Outputs:
  web/favicon.png                    48 x 48 favicon
  web/icons/Icon-192.png             192 x 192
  web/icons/Icon-512.png             512 x 512
  web/icons/Icon-maskable-192.png    192 x 192, full-bleed safe zone
  web/icons/Icon-maskable-512.png    512 x 512, full-bleed safe zone
  web/icons/apple-touch-icon.png     180 x 180
  web/social-preview.png             1200 x 630 Open Graph card

.EXAMPLE
powershell -ExecutionPolicy Bypass -File tools\generate-brand-assets.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$web = Join-Path $root 'web'
$icons = Join-Path $web 'icons'
$fonts = Join-Path $root 'assets\fonts'
New-Item -ItemType Directory -Path $icons -Force | Out-Null

$navyDeep = [System.Drawing.ColorTranslator]::FromHtml('#0A1526')
$navyGlow = [System.Drawing.ColorTranslator]::FromHtml('#16335C')
$brandBlue = [System.Drawing.ColorTranslator]::FromHtml('#2F8BF7')
$nodeBlue = [System.Drawing.ColorTranslator]::FromHtml('#9CCBFF')
$white = [System.Drawing.Color]::White

function New-RoundRectPath {
  param([float]$X, [float]$Y, [float]$W, [float]$H, [float]$R)
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $R * 2
  $path.AddArc($X, $Y, $d, $d, 180, 90)
  $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
  $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
  $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function Add-Mark {
  param(
    [System.Drawing.Graphics]$Graphics,
    [float]$Cx,
    [float]$Cy,
    [float]$Unit,
    [System.Drawing.Color]$ArcColor,
    [System.Drawing.Color]$NodeColor,
    [System.Drawing.Color]$CoreColor
  )
  $orbit = $Unit * 0.31
  $stroke = [Math]::Max(1.5, $Unit * 0.085)

  $pen = New-Object System.Drawing.Pen($ArcColor, $stroke)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $rect = New-Object System.Drawing.RectangleF(($Cx - $orbit), ($Cy - $orbit), ($orbit * 2), ($orbit * 2))
  # Flutter starts at 0.55 rad and sweeps 4.9 rad clockwise; GDI+ uses degrees.
  $Graphics.DrawArc($pen, $rect, 31.5, 280.7)
  $pen.Dispose()

  $coreBrush = New-Object System.Drawing.SolidBrush($CoreColor)
  $coreR = $Unit * 0.19
  $Graphics.FillEllipse($coreBrush, ($Cx - $coreR), ($Cy - $coreR), ($coreR * 2), ($coreR * 2))
  $coreBrush.Dispose()

  $nodeBrush = New-Object System.Drawing.SolidBrush($NodeColor)
  $nodeR = $Unit * 0.085
  # Sit the node on the arc's end cap (31.5 + 280.7 degrees) so the terminal
  # reads as one dot instead of a cap poking out beside it.
  $endAngle = (31.5 + 280.7) * [Math]::PI / 180
  $nodeX = $Cx + ($orbit * [Math]::Cos($endAngle))
  $nodeY = $Cy + ($orbit * [Math]::Sin($endAngle))
  $Graphics.FillEllipse($nodeBrush, ($nodeX - $nodeR), ($nodeY - $nodeR), ($nodeR * 2), ($nodeR * 2))
  $nodeBrush.Dispose()
}

function New-BrandIcon {
  param([int]$Size, [string]$Path, [switch]$Maskable)

  $bmp = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  try {
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $bounds = New-Object System.Drawing.RectangleF(0, 0, $Size, $Size)
    if ($Maskable) {
      $shape = New-Object System.Drawing.Drawing2D.GraphicsPath
      $shape.AddRectangle($bounds)
    } else {
      $shape = New-RoundRectPath -X 0 -Y 0 -W $Size -H $Size -R ($Size * 0.22)
    }

    $g.SetClip($shape)
    $g.Clear($navyDeep)

    # Soft radial lift behind the mark, so the tile is not a flat block.
    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowPath.AddEllipse(($Size * -0.15), ($Size * -0.15), ($Size * 1.3), ($Size * 1.3))
    $glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glow.CenterColor = $navyGlow
    $glow.SurroundColors = @($navyDeep)
    $g.FillPath($glow, $glowPath)
    $glow.Dispose()
    $glowPath.Dispose()
    $g.ResetClip()

    $scale = if ($Maskable) { 0.8 } else { 0.92 }
    Add-Mark -Graphics $g -Cx ($Size / 2) -Cy ($Size / 2) -Unit ($Size * $scale) `
      -ArcColor $brandBlue -NodeColor $nodeBlue -CoreColor $white

    $shape.Dispose()
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  finally {
    $g.Dispose()
    $bmp.Dispose()
  }
  Write-Host "  $([System.IO.Path]::GetFileName($Path)) ($Size px)" -ForegroundColor DarkGray
}

Write-Host 'Drawing icons...' -ForegroundColor Cyan
New-BrandIcon -Size 48 -Path (Join-Path $web 'favicon.png')
New-BrandIcon -Size 192 -Path (Join-Path $icons 'Icon-192.png')
New-BrandIcon -Size 512 -Path (Join-Path $icons 'Icon-512.png')
New-BrandIcon -Size 192 -Path (Join-Path $icons 'Icon-maskable-192.png') -Maskable
New-BrandIcon -Size 512 -Path (Join-Path $icons 'Icon-maskable-512.png') -Maskable
New-BrandIcon -Size 180 -Path (Join-Path $icons 'apple-touch-icon.png')

# ---------------------------------------------------------------------------
# Open Graph card: 1200 x 630, brand typography on navy with the mark on the
# right. Text is measured so the headline block never collides with the mark.
# ---------------------------------------------------------------------------
Write-Host 'Drawing the social preview card...' -ForegroundColor Cyan

$w = 1200
$h = 630
$card = New-Object System.Drawing.Bitmap($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($card)
try {
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(0, 0, $w, $h)),
    [System.Drawing.ColorTranslator]::FromHtml('#071224'),
    [System.Drawing.ColorTranslator]::FromHtml('#0E2A50'),
    20
  )
  $g.FillRectangle($bg, 0, 0, $w, $h)
  $bg.Dispose()

  # Soft blue wash on the right instead of a radial halo: a radial gradient at
  # this size shows a visible edge where it meets the base gradient.
  $wash = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.Rectangle(520, 0, 680, $h)),
    [System.Drawing.Color]::FromArgb(0, 47, 139, 247),
    [System.Drawing.Color]::FromArgb(46, 47, 139, 247),
    0
  )
  $g.FillRectangle($wash, 520, 0, 680, $h)
  $wash.Dispose()

  # Faint secondary orbit for depth behind the main mark.
  $ghost = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(28, 47, 139, 247), 3)
  $g.DrawEllipse($ghost, 690, 20, 700, 590)
  $ghost.Dispose()

  Add-Mark -Graphics $g -Cx 940 -Cy 315 -Unit 430 `
    -ArcColor $brandBlue -NodeColor $nodeBlue -CoreColor $white

  $fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
  $fontCollection.AddFontFile((Join-Path $fonts 'Poppins-Bold.ttf'))
  $fontCollection.AddFontFile((Join-Path $fonts 'Poppins-SemiBold.ttf'))
  $fontCollection.AddFontFile((Join-Path $fonts 'Poppins-Medium.ttf'))
  $fontCollection.AddFontFile((Join-Path $fonts 'Poppins-Regular.ttf'))
  $families = $fontCollection.Families
  $family = ($families | Where-Object { $_.Name -eq 'Poppins' } | Select-Object -First 1)
  if (-not $family) { $family = $families[0] }

  $bold = New-Object System.Drawing.Font($family, 78, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $wordmark = New-Object System.Drawing.Font($family, 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $eyebrowFont = New-Object System.Drawing.Font($family, 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $subFont = New-Object System.Drawing.Font($family, 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
  $urlFont = New-Object System.Drawing.Font($family, 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

  Add-Mark -Graphics $g -Cx 106 -Cy 106 -Unit 62 `
    -ArcColor $brandBlue -NodeColor $nodeBlue -CoreColor $white

  $whiteBrush = New-Object System.Drawing.SolidBrush($white)
  $mutedBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#A8C6EE'))
  $eyebrowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#6FA8FF'))
  $urlBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#5E7FA8'))

  $g.DrawString('Epicyclic', $wordmark, $whiteBrush, 152, 78)
  $g.DrawString('GAMING  &  DESK  GEAR', $eyebrowFont, $eyebrowBrush, 82, 186)
  $g.DrawString('Find Your Next', $bold, $whiteBrush, 74, 222)
  $g.DrawString('Upgrade.', $bold, $whiteBrush, 74, 320)
  $g.DrawString('29 verified products, priced in pesos.', $subFont, $mutedBrush, 82, 446)
  $g.DrawString('epicyclic-store.vercel.app', $urlFont, $urlBrush, 82, 546)

  $rule = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 156, 203, 255), 1)
  $g.DrawLine($rule, 82, 524, 402, 524)
  $rule.Dispose()

  foreach ($f in @($bold, $wordmark, $eyebrowFont, $subFont, $urlFont)) { $f.Dispose() }
  foreach ($b in @($whiteBrush, $mutedBrush, $eyebrowBrush, $urlBrush)) { $b.Dispose() }

  $card.Save((Join-Path $web 'social-preview.png'), [System.Drawing.Imaging.ImageFormat]::Png)
}
finally {
  $g.Dispose()
  $card.Dispose()
}

Write-Host 'Done. web/favicon.png, web/icons/*, web/social-preview.png regenerated.' -ForegroundColor Green
