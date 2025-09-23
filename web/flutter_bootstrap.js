// This script is included in index.html and helps configure Flutter Web
window.flutterWebRenderer = "html";

// Load the main entrypoint
_flutter = document.createElement('script');
_flutter.src = "main.dart.js";
document.body.appendChild(_flutter);
