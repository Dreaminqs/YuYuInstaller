Set-Location "$PSScriptRoot"

# Chrome/Edge zip
Remove-Item -Force YuYuInstaller_Extension_Chrome_Edge.zip -ErrorAction SilentlyContinue
Compress-Archive -Path @("manifest.json","background.js","popup.html","popup.js","content.js","icons") -DestinationPath YuYuInstaller_Extension_Chrome_Edge.zip -Force

# Firefox zip (manifest.firefox.json -> manifest.json olarak temp klasorde)
$tmp = "$env:TEMP\yuyu_ff_ext"
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $tmp | Out-Null
Copy-Item "manifest.firefox.json" "$tmp\manifest.json"
Copy-Item "background.js","popup.html","popup.js","content.js" $tmp
Copy-Item "icons" $tmp -Recurse
Remove-Item -Force YuYuInstaller_Extension_Firefox.zip -ErrorAction SilentlyContinue
Compress-Archive -Path "$tmp\*" -DestinationPath YuYuInstaller_Extension_Firefox.zip -Force
Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

Write-Host ("Chrome/Edge: " + (Get-Item YuYuInstaller_Extension_Chrome_Edge.zip).Length + " bytes")
Write-Host ("Firefox: " + (Get-Item YuYuInstaller_Extension_Firefox.zip).Length + " bytes")
Write-Host "DONE"
