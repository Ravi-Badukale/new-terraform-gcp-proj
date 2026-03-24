Install-WindowsFeature -name Web-Server -IncludeManagementTools

Set-Content -Path "C:\inetpub\wwwroot\index.html" `
  -Value "<h1>Hello from IIS on GCP</h1>"