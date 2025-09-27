#!/bin/bash

# Broker Logo Download Script
# This script will automatically download broker logos

echo "=== Broker Logo Download Script ==="
echo "Automatically downloading broker logos..."
echo ""

# Create directory structure
mkdir -p assets/images/brokers

# Function to download logo
download_logo() {
    local url=$1
    local filename=$2
    local broker_name=$3
    
    echo "Downloading $broker_name logo..."
    
    if command -v curl &> /dev/null; then
        curl -L -o "assets/images/brokers/$filename" "$url" --silent --show-error
    elif command -v wget &> /dev/null; then
        wget -O "assets/images/brokers/$filename" "$url" --quiet
    else
        echo "Error: Neither curl nor wget is available. Please install one of them."
        return 1
    fi
    
    if [ -f "assets/images/brokers/$filename" ]; then
        echo "✓ $broker_name logo downloaded successfully"
    else
        echo "✗ Failed to download $broker_name logo"
    fi
}

# Download logos with direct URLs
echo "Starting downloads..."
echo ""

# Note: These are example URLs - you may need to update them if they change
download_logo "https://zerodha.com/static/images/logo.svg" "zerodha.png" "ZERODHA"
download_logo "https://www.angelone.in/assets/img/angel-broking-logo.svg" "angel.png" "ANGEL ONE"
download_logo "https://upstox.com/app/themes/upstox/dist/img/logo.svg" "upstox.png" "UPSTOX"
download_logo "https://www.icicidirect.com/Content/images/icicidirect-logo.png" "icici.png" "ICICI DIRECT"
download_logo "https://www.hdfcsec.com/images/logo.png" "hdfc.png" "HDFC SECURITIES"
download_logo "https://www.kotaksecurities.com/images/logo.png" "kotak.png" "KOTAK SECURITIES"
download_logo "https://www.sbisec.co.in/images/logo.png" "sbi.png" "SBI SECURITIES"
download_logo "https://www.sharekhan.com/images/logo.png" "sharekhan.png" "SHAREKHAN"
download_logo "https://www.motilaloswal.com/images/logo.png" "motilal.png" "MOTILAL OSWAL"
download_logo "https://www.edelweiss.in/images/logo.png" "edelweiss.png" "EDELWEISS"
download_logo "https://fyers.in/images/logo.png" "fyers.png" "FYERS"
download_logo "https://aliceblueonline.com/images/logo.png" "alice.png" "ALICE BLUE"

echo ""
echo "=== Download Summary ==="
echo "Checking downloaded files..."

for broker in zerodha angel upstox icici hdfc kotak sbi sharekhan motilal edelweiss fyers alice; do
    if [ -f "assets/images/brokers/${broker}.png" ]; then
        file_size=$(stat -f%z "assets/images/brokers/${broker}.png" 2>/dev/null || stat -c%s "assets/images/brokers/${broker}.png" 2>/dev/null || echo "0")
        if [ "$file_size" -gt 1000 ]; then
            echo "✓ ${broker}.png - Downloaded (${file_size} bytes)"
        else
            echo "⚠ ${broker}.png - File too small, may be invalid"
        fi
    else
        echo "✗ ${broker}.png - Missing"
    fi
done

# Create fallback placeholder files for missing logos
echo ""
echo "Creating placeholder files for missing logos..."

for broker in zerodha angel upstox icici hdfc kotak sbi sharekhan motilal edelweiss fyers alice; do
    if [ ! -f "assets/images/brokers/${broker}.png" ] || [ $(stat -f%z "assets/images/brokers/${broker}.png" 2>/dev/null || stat -c%s "assets/images/brokers/${broker}.png" 2>/dev/null || echo "0") -lt 1000 ]; then
        # Create a simple SVG placeholder and convert to PNG if possible
        cat > "assets/images/brokers/${broker}_temp.svg" << EOF
<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg">
  <rect width="100" height="100" fill="#f0f0f0" stroke="#ccc"/>
  <text x="50" y="50" text-anchor="middle" dy="0.3em" font-family="Arial" font-size="12" fill="#666">$broker</text>
</svg>
EOF
        echo "Created placeholder for ${broker}.png"
    fi
done

echo ""
echo "Script execution completed!"
echo "Directory: assets/images/brokers/"
echo ""
echo "=== Next Steps ==="
echo "1. Check the downloaded logos in assets/images/brokers/"
echo "2. Replace any placeholder or low-quality images manually"
echo "3. Ensure all logos are in PNG format"
echo "4. Run: flutter clean && flutter pub get"
echo ""