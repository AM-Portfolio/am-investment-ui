# Create Basic Broker PNG Files
# Simple script to create placeholder PNG files for all brokers

Write-Host "=== Creating Basic Broker PNG Files ===" -ForegroundColor Green
Write-Host ""

# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "assets\images\brokers" | Out-Null

# List of brokers that need PNG files
$brokers = @("zerodha", "angel", "upstox", "icici", "hdfc", "kotak", "sbi", "sharekhan", "motilal", "edelweiss", "fyers", "alice")

Write-Host "Creating PNG files for brokers..." -ForegroundColor Cyan

foreach ($broker in $brokers) {
    $pngPath = "assets\images\brokers\$broker.png"
    
    # Check if a valid PNG already exists
    if (Test-Path $pngPath) {
        $fileSize = (Get-Item $pngPath).Length
        if ($fileSize -gt 1000) {
            Write-Host "[EXISTS] $broker.png ($fileSize bytes)" -ForegroundColor Green
            continue
        }
    }
    
    Write-Host "Creating placeholder for: $broker" -ForegroundColor Yellow
    
    try {
        # Try to use .NET Graphics to create a simple PNG
        Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue
        Add-Type -AssemblyName System.Drawing.Common -ErrorAction SilentlyContinue
        
        # Create a 100x50 bitmap
        $bitmap = New-Object System.Drawing.Bitmap(100, 50)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Set background
        $graphics.Clear([System.Drawing.Color]::FromArgb(248, 249, 250))
        
        # Draw border
        $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::LightGray, 1)
        $graphics.DrawRectangle($borderPen, 0, 0, 99, 49)
        
        # Draw text
        $font = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Bold)
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Gray)
        
        # Center text
        $text = $broker.ToUpper()
        $textSize = $graphics.MeasureString($text, $font)
        $x = (100 - $textSize.Width) / 2
        $y = (50 - $textSize.Height) / 2
        
        $graphics.DrawString($text, $font, $brush, $x, $y)
        
        # Save as PNG
        $bitmap.Save($pngPath, [System.Drawing.Imaging.ImageFormat]::Png)
        
        # Clean up
        $graphics.Dispose()
        $bitmap.Dispose()
        $borderPen.Dispose()
        $font.Dispose()
        $brush.Dispose()
        
        $newSize = (Get-Item $pngPath).Length
        Write-Host "[CREATED] $broker.png ($newSize bytes)" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Could not create PNG with .NET Graphics: $($_.Exception.Message)" -ForegroundColor Red
        
        # Fallback: Create a minimal SVG that can be used
        $svgContent = @"
<svg width="100" height="50" xmlns="http://www.w3.org/2000/svg">
  <rect width="100" height="50" fill="#f8f9fa" stroke="#dee2e6"/>
  <text x="50" y="30" text-anchor="middle" font-family="Arial" font-size="10" fill="#6c757d">$($broker.ToUpper())</text>
</svg>
"@
        Set-Content -Path "assets\images\brokers\$broker.svg" -Value $svgContent -Encoding UTF8
        Write-Host "[CREATED] $broker.svg as fallback" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Green

# List files
$files = Get-ChildItem -Path "assets\images\brokers" -File | Where-Object { $_.Name -match '\.(png|svg)$' } | Sort-Object Name

foreach ($file in $files) {
    $size = if ($file.Length -gt 1024) { "$([math]::Round($file.Length/1024, 1)) KB" } else { "$($file.Length) bytes" }
    Write-Host "$($file.Name) - $size" -ForegroundColor $(if ($file.Extension -eq '.png') { 'Green' } else { 'Cyan' })
}

Write-Host ""
Write-Host "Files created in: assets\images\brokers\" -ForegroundColor Cyan
Write-Host "Next: Run 'flutter clean && flutter pub get' to refresh assets" -ForegroundColor Yellow