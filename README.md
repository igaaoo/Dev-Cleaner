# 🧹 Dev-Cleaner — Node/JS Project Folder Cleaner

Dev-Cleaner is a lightweight PowerShell-based tool designed to free up disk space by cleaning up common build and dependency folders in JavaScript/Node projects — such as node_modules, dist, .next, and more.

No setup required. Just run the script or use the bundled .exe.

## 🚀 Overview
Modern JavaScript projects generate large folder structures during development and builds. This tool helps you:

Reclaim disk space

Keep your projects tidy

Avoid clutter in old or unused folders

## ✨ Features
🔍 Recursive folder search for:

node_modules

.next

dist

build

coverage

🧠 Smart filtering to avoid redundant deletions

⏳ Checks for recent modifications and asks for confirmation

🌐 Multilingual: supports English and Portuguese automatically

💻 EXE version included for easy use

📊 Cleanup report:

Folders deleted

Space freed

Paths affected

## 🧪 Usage
Option 1: Using PowerShell script
Open PowerShell

Go to the folder where the script is saved

Run the script by typing its name (e.g., .\dev-cleaner.ps1)

Option 2: Using the EXE file
Double-click dev-cleaner.exe

It will scan and guide you through the cleanup

✅ No installation required!

## 📦 Requirements (for script version)
Windows PowerShell 5.1 or newer

Permissions to delete folders in the scanned directories

## 📄 Example Output
Project cleanup started.
Target folders:
   -> node_modules
   -> dist
   -> build
   -> .next
   -> coverage

Searching for folders to delete...

[DEL] C:\Projects\old-app\node_modules — 153.2 MB  
[DEL] C:\Projects\archive\dist — 22.4 MB  

Cleanup Summary
Total time: 00:00:15
Folders deleted: 2
Freed space: 175.6 MB

## 🛠️ Customization
Language settings (auto-detected)

## 🤝 Contributing
Feel free to open issues, suggest improvements, or submit pull requests. Contributions are welcome!

👤 Author
Igor Neves
🔗 https://github.com/igaaoo

📃 License
This project is licensed under the MIT License.
