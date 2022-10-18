"pwsh" -executionpolicy remotesigned -command "%~dp0\snap.ps1 save"
timeout 10
exit