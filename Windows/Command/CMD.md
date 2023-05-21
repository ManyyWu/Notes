# CMD
## 屏蔽鼠标操作
    @reg add HKEY_CURRENT_USER\Console /v QuickEdit /t REG_DWORD /d 00000000 /f >nul 2>nul

## expect
  [expect](https://github.com/ManyyWu/expect)

## 根据进程名杀进程
  TASKKILL //F //T //IM $name
