# ADB Logcat Monitor via Termux

## 準備物

- PC x1 … ログ表示用
- スマホ x2
  - **スマホ1**: Termuxを使ってADB接続しログを取得
  - **スマホ2**: ADB接続対象 (後にWatchに置き換える予定)
- USBケーブル x1
- 同一Wi-Fiネットワーク

---

## セットアップ手順

### スマホ1 (ADBクライアント側) (一度のみ実行)

1. **Termuxのインストール**
   [F-Droid](https://f-droid.org/ja/packages/com.termux/) から最新版を入手

2. **初期セットアップ**
   下記を1行で実行:

   ```bash
   pkg update -y && pkg upgrade -y && pkg install -y android-tools
   ```

3. **ストレージ権限の有効化**

   ```bash
   termux-setup-storage
   ```

4. **ログ保存用フォルダ作成**

   ```bash
   mkdir -p ~/storage/downloads/termux
   ```

---

### スマホ2 (ADBターゲット側)

5. **PCからUSB接続しWi-Fi ADBモードへ切替**

   ```bash
   adb tcpip 5555
   ```

6. **スマホ2のIPアドレスを確認**

   ```bash
   adb shell ip addr show wlan0
   ```

   または、設定 > デバイス情報 > IPアドレス

---

### 再びスマホ1

7. **Termuxからスマホ2へADB接続**

   ```bash
   adb connect xxx.xxx.xxx.xxx:5555
   ```

8. **logcatをファイルに出力 (フィルタ指定も可)**

   ```bash
   adb logcat > ~/storage/downloads/termux/watch_dog.txt

   # teeコマンドを使うと、画面にも表示される
   # adb logcat | tee ~/storage/downloads/termux/watch_dog.txt
   ```

   途中で途切れる場合もあるので、以下のようにしておくと良い:

   ```bash
   while true; do

      adb connect xxx.xxx.xxx.xxx:5555

      adb logcat > ~/storage/downloads/termux/watch_dog.txt

      # teeコマンドを使うと、画面にも表示される
      # adb logcat | tee  -a ~/storage/downloads/termux/watch_dog.txt
      sleep 1
   done
   ```

---

### ログ表示 (PC)

9. **スマホ1をPCとUSB接続し、PowerShellスクリプトを実行**

   例: `tail-adb.ps1`

   ```powershell
   $remoteFile = "/sdcard/Download/termux/watch_dog.txt"
   $localFile = "$PSScriptRoot\watch_log.txt"
   $lastSize = 0

   while ($true) {
       adb pull $remoteFile $localFile *> $null
       if (Test-Path $localFile) {
           $currentSize = (Get-Item $localFile).Length
           if ($currentSize -gt $lastSize) {
               $diff = $currentSize - $lastSize
               $fs = [System.IO.File]::OpenRead($localFile)
               $fs.Seek($lastSize, [System.IO.SeekOrigin]::Begin) | Out-Null
               $buffer = New-Object byte[] $diff
               $fs.Read($buffer, 0, $diff) | Out-Null
               $fs.Close()
               $text = [System.Text.Encoding]::UTF8.GetString($buffer)
               Write-Host $text
               $lastSize = $currentSize
           }
       }
       Start-Sleep -Seconds 1
   }
   ```

---
