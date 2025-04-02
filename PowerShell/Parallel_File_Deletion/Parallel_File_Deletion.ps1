<#
.SYNOPSIS
    Deletes files recursively in parallel from a specified directory.

.DESCRIPTION
    This script deletes all files within a given directory recursively.
    It supports parallel execution using jobs in PowerShell versions 6 and below,
    and the ForEach-Object -Parallel feature in PowerShell 7 and above.

.PARAMETER Dir
    The target directory where files will be deleted.

.EXAMPLE
    .\Parallel_File_Deletion.ps1 -Dir "C:\Temp"
#>

# 日本語訳
<#
.SYNOPSIS
    指定されたディレクトリからファイルを再帰的に並列削除します。
.DESCRIPTION
    このスクリプトは、指定されたディレクトリ内のすべてのファイルを再帰的に削除します。
    PowerShell 6 以下ではジョブを使用して並列実行をサポートし、
    PowerShell 7 以上では ForEach-Object -Parallel 機能を使用します。
.PARAMETER Dir
    ファイルを削除する対象のディレクトリ。
.EXAMPLE
    .\Parallel_File_Deletion.ps1 -Dir "C:\Temp"
#>

param(
        [Parameter(Mandatory)]
        [string]$Dir
)

# 入力ディレクトリの存在確認
if (-not (Test-Path $Dir)) {
    Write-Error "指定されたディレクトリが見つかりません: $Dir"
    exit 1
}

$PSVersion = $PSVersionTable.PSVersion.Major

# PowerShellのバージョンによって処理を分岐
if ($PSVersion -le 6) {
    # PowerShell 6 以下の処理
    $files = Get-ChildItem -Path $Dir -Recurse -File
    $jobs = @()

    foreach ($file in $files) {
        $jobs += Start-Job -ScriptBlock {
            param($filePath)
            Remove-Item -Path $filePath -Force -ErrorAction SilentlyContinue
        } -ArgumentList $file.FullName
    }

    # ジョブの完了を待機し、ジョブをクリーンアップ
    $jobs | Wait-Job
    $jobs | Remove-Job

} else {
    # PowerShell 7 以上の処理
    Get-ChildItem -Path $Dir -Recurse -File | ForEach-Object -Parallel {
        Remove-Item -Path $_.FullName -Force -ErrorAction SilentlyContinue
    } -ThrottleLimit 10
}

Write-Host "All files deleted successfully." -ForegroundColor Green
exit 0
