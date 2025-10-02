# Broker Logo Download Script - PowerShell Version
# This script will automatically download broker logos

Write-Host "=== Broker Logo Download Script ===" -ForegroundColor Green
Write-Host "Automatically downloading broker logos..." -ForegroundColor Yellow
Write-Host ""

# Create directory structure
New-Item -ItemType Directory -Force -Path "assets\images\brokers" | Out-Null

# Function to download logo
function Download-Logo {
    param(
        [string]$url,
        [string]$filename,
        [string]$brokerName
    )
    
    Write-Host "Downloading $brokerName logo..." -ForegroundColor Cyan
    
    try {
        $outputPath = "assets\images\brokers\$filename"
        
        # Use Invoke-WebRequest to download the file
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -TimeoutSec 30
        
        if (Test-Path $outputPath) {
            $fileSize = (Get-Item $outputPath).Length
            if ($fileSize -gt 500) {
                Write-Host "[SUCCESS] $brokerName logo downloaded successfully ($fileSize bytes)" -ForegroundColor Green
                return $true
            } else {
                Write-Host "[WARNING] $brokerName logo file too small, may be invalid ($fileSize bytes)" -ForegroundColor Yellow
                return $false
            }
        } else {
            Write-Host "[ERROR] Failed to download $brokerName logo" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "[ERROR] Error downloading $brokerName logo: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Download logos with updated URLs
Write-Host "Starting downloads..." -ForegroundColor Green
Write-Host ""

# Updated URLs that should work better
$logos = @(
    @{url="https://zerodha.com/static/images/logo.svg"; filename="zerodha.svg"; name="ZERODHA"},
    @{url="https://www.angelone.in/assets/img/angel-broking-logo.svg"; filename="angel.svg"; name="ANGEL ONE"},
    @{url="https://upstox.com/app/themes/upstox/dist/img/logo.svg"; filename="upstox.svg"; name="UPSTOX"},
    @{url="https://www.icicidirect.com/Content/images/icicidirect-logo.png"; filename="icici.png"; name="ICICI DIRECT"},
    @{url="https://www.hdfcsec.com/images/logo.png"; filename="hdfc.png"; name="HDFC SECURITIES"},
    @{url="https://www.kotaksecurities.com/images/logo.png"; filename="kotak.png"; name="KOTAK SECURITIES"},
    @{url="https://www.sbisec.co.in/images/logo.png"; filename="sbi.png"; name="SBI SECURITIES"},
    @{url="https://www.sharekhan.com/images/logo.png"; filename="sharekhan.png"; name="SHAREKHAN"},
    @{url="https://www.motilaloswal.com/images/logo.png"; filename="motilal.png"; name="MOTILAL OSWAL"},
    @{url="https://www.edelweiss.in/images/logo.png"; filename="edelweiss.png"; name="EDELWEISS"},
    @{url="https://fyers.in/images/logo.png"; filename="fyers.png"; name="FYERS"},
    @{url="https://aliceblueonline.com/images/logo.png"; filename="alice.png"; name="ALICE BLUE"}
)

$successCount = 0
$totalCount = $logos.Count

foreach ($logo in $logos) {
    if (Download-Logo -url $logo.url -filename $logo.filename -brokerName $logo.name) {
        $successCount++
    }
    Start-Sleep -Milliseconds 500  # Brief pause between downloads
}

Write-Host ""
Write-Host "=== Download Summary ===" -ForegroundColor Green
Write-Host "Successfully downloaded: $successCount out of $totalCount logos" -ForegroundColor $(if ($successCount -eq $totalCount) { 'Green' } else { 'Yellow' })
Write-Host ""

# List all downloaded files
Write-Host "Checking downloaded files..." -ForegroundColor Cyan
$brokerFiles = Get-ChildItem -Path "assets\images\brokers" -File

foreach ($file in $brokerFiles) {
    if ($file.Length -gt 500) {
        Write-Host "[OK] $($file.Name) - $('{0:N0}' -f $file.Length) bytes" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] $($file.Name) - File too small ($('{0:N0}' -f $file.Length) bytes)" -ForegroundColor Yellow
    }
}

# Clean up any invalid files
Write-Host ""
Write-Host "Cleaning up invalid files..." -ForegroundColor Cyan

$filesToCheck = @("zerodha", "angel", "upstox", "icici", "hdfc", "kotak", "sbi", "sharekhan", "motilal", "edelweiss", "fyers", "alice")
foreach ($broker in $filesToCheck) {
    $pngFile = "assets\images\brokers\$broker.png"
    $svgFile = "assets\images\brokers\$broker.svg"
    $txtFile = "assets\images\brokers\$broker.txt"
    
    # Remove text files if they exist (these are placeholders)
    if (Test-Path $txtFile) {
        Remove-Item $txtFile -Force
        Write-Host "Removed placeholder file: $broker.txt" -ForegroundColor Yellow
    }
    
    # Check if we have valid image files
    $hasValidFile = $false
    if (Test-Path $pngFile) {
        $fileSize = (Get-Item $pngFile).Length
        if ($fileSize -gt 500) {
            $hasValidFile = $true
        }
    }
    if (Test-Path $svgFile) {
        $fileSize = (Get-Item $svgFile).Length
        if ($fileSize -gt 500) {
            $hasValidFile = $true
        }
    }
    
    # Create placeholder if no valid file exists
    if (-not $hasValidFile) {
        $placeholderContent = @"
<svg width="120" height="60" xmlns="http://www.w3.org/2000/svg">
  <rect width="120" height="60" fill="#f8f9fa" stroke="#dee2e6" stroke-width="1"/>
  <text x="60" y="35" text-anchor="middle" font-family="Arial, sans-serif" font-size="12" fill="#6c757d">$($broker.ToUpper())</text>
</svg>
"@
        $placeholderPath = "assets\images\brokers\$broker.svg"
        Set-Content -Path $placeholderPath -Value $placeholderContent -Encoding UTF8
        Write-Host "Created placeholder for: $broker.svg" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Script execution completed!" -ForegroundColor Green
Write-Host "Directory: assets\images\brokers\" -ForegroundColor Cyan
Write-Host ""
Write-Host "=== Next Steps ===" -ForegroundColor Green
Write-Host "1. Check the downloaded logos in assets\images\brokers\" -ForegroundColor White
Write-Host "2. Replace any placeholder or low-quality images manually" -ForegroundColor White
Write-Host "3. Consider converting SVG files to PNG if needed" -ForegroundColor White
Write-Host "4. Run: flutter clean && flutter pub get" -ForegroundColor White
Write-Host ""