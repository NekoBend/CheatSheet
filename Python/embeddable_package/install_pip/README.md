# Python Embeddable Packageでpipをインストールする方法

1. [Pythonのダウンロードページ](https://www.python.org/downloads/windows/)からPython embeddable packageをダウンロードする

2. ダウンロードしたzipファイルを解凍する

   ``` bash
    unzip python-3.xx.xx-embed-amd64.zip -d C:\python-3.xx.xx-embed-amd64
    ```

3. 解凍したフォルダに移動する

   ```bash
   cd C:\python-3.xx.xx-embed-amd64
   ```

4. python3xx._pthを編集する

   ```bash
   notepad python3xx._pth
   ```

   1. `import site`の行はデフォルトでコメントアウトされているので、コメントを外す

    ```python
    # import site
    ```

    を次のように変更します:

    ```python
    import site
    ```

5. `get-pip.py`をダウンロードする

   ```bash
   curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
   ```

    または、[get-pip.py](https://bootstrap.pypa.io/get-pip.py)をブラウザでダウンロードする

6. `get-pip.py`を実行する

    ```bash
    python.exe get-pip.py
    ```

7. `pip`がインストールされたことを確認する

    ```bash
    \Scripts\pip.exe --version
    ```
