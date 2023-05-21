 # Windows Terminal
 ## 快捷方式
     wt.exe -M -p "Windows PowerShell" --title "Hello world!" powershell.exe "1.ps1" `; sp powershell.exe "1.ps1"

## 集成git-bash
  ```Json
  {
      "commandline": "%ProgramFiles%/Git/bin/bash.exe -li",
      "font": 
      {
          "face": "JetBrainsMono Nerd Font Mono",
          "size": 10
      },
      "guid": "{d15b228a-05d7-50d1-8472-f60aaba86efc}",
      "hidden": false,
      "icon": "%ProgramFiles%/Git/mingw64/share/git/git-for-windows.ico",
      "name": "Git Bash",
      "startingDirectory": "%USERPROFILE%"
  }
  ```
## 光标显示方块
  ```Json
  "profiles": 
  {
      "defaults": 
      {
          "cursorShape": "filledBox",
      },
  }
  ```
  
## 单词分隔符
  ```Json
  "wordDelimiters": "\\()\"',:;<~!@#$%^&*|+=[]{}~\u2502"
  ```
