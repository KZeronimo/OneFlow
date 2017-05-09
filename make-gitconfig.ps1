 Param (
    [parameter(Mandatory=$false)]
    [switch] $g
)

function Get-ScriptDirectory {
  $thisName = $MyInvocation.MyCommand.Name
  [IO.Path]::GetDirectoryName((Get-Content function:$thisName).File)
}

try {
    $scriptPath = Get-ScriptDirectory
    Set-Location -Path $scriptPath

    [string] $aliasBody = ''
    $aliasName=''
    $gitConfigPath=''
    $tempAliasFile=''

    $gitConfigPath = if ( $g ) { Join-Path $env:UserProfile ".gitconfig" } else { Join-Path ${scriptPath} ".gitconfig" }
    if ( $g )  { Write-Host "==> Writing to global gitconfig!" -ForegroundColor Red }

    # Backup gitconfig
    Copy-Item $gitConfigPath "$gitConfigPath.bak"
    Write-Host "==> gitconfig backed up" -ForegroundColor Green

    # Make gitconfig
    Write-Host "==> Making gitconfig" -ForegroundColor Green

    # Write gitconfig simple aliases
    Write-Host "==> Adding simple aliases" -ForegroundColor Green
    & "${scriptPath}/config/alias.ps1" "$gitConfigPath"
    # Write gitconfig configuration
    Write-Host "==> Adding config options" -ForegroundColor Green
    & "${scriptPath}/config/config.ps1" "$gitConfigPath"

    Write-Host "==> Adding anonymous function aliases" -ForegroundColor Green

    $files = Get-ChildItem -Path "$scriptPath\anonymous_functions" -Recurse -Include *.sh, *.ps1
    for ($i=0; $i -lt $files.Count; $i++) {
        if( $files[$i].BaseName -eq "make-gitconfig" ) { continue }
        if( ($files[$i].BaseName | Select-String "~") ) { Write-Host $files[$i].BaseName "is WIP - skipping!" -ForegroundColor Yellow; continue }

        if( (Get-Content $files[$i]).Length -ne 0 ) {
            $aliasName = $files[$i].BaseName.Replace('git-','')
            $tempAliasFile = "$($files[$i].FullName).alias"

            # Strip all blank lines - all whitespace - lines beginning with #
            (Get-Content $files[$i].FullName) -match '\S' | % { $_.Trim() } | Where { $_ -notmatch '^#' } | Set-Content -Path $tempAliasFile
            # Join all lines into a single line - PS specific - escape double quotes since this is a command line parameter to an external exe and we need to preserve internal quotes
            $aliasBody = "!f() { $((Get-Content $tempAliasFile) -join ' ' | % { $_ -replace '"', '\`"' } ) }; f"

            Write-Host "==> $aliasName built" -ForegroundColor Green
            $git = "git"
            & $git config "--file=$gitConfigPath" "alias.$aliasName" "$aliasBody"
            Write-Host "`t==> $aliasName written" -ForegroundColor Green
        }
        else {
            Write-Host $files[$i].BaseName " is empty - skipping!" -ForegroundColor Yellow; continue
        }
    }
}
catch {
    Write-Host "An error occured!" -ForegroundColor Red
    Write-Host "Exception Message: $($_.Exception.Message)” -ForegroundColor Red
}
finally {
    Write-Host "`n==> Cleaning up" -ForegroundColor Green
    Remove-Item -Path "$gitConfigPath.bak" -Force
    Remove-Item -Path "$scriptPath\anonymous_functions" -Recurse -Force -Include *.alias
}
