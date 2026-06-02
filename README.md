# 7zzGUI

A lightweight GUI frontend for 7-Zip command-line tool.

This project provides a simple graphical interface to compress and extract files using 7zz / 7-Zip.

This project is built by deepseek-v4-pro.

---

## ✨ Features

- Compress files and folders
- Extract archives (zip, 7z, rar, etc.)
- Simple GUI interface
- Fast and lightweight
- Cross-platform (depends on backend availability)

---

## 🧩 Backend

This project uses the 7-Zip command-line tool (7zz) as its compression engine.

7-Zip is an open-source file archiver developed by Igor Pavlov.

- Official website: https://www.7-zip.org/
- License: LGPL / GPL components (depending on build configuration)

This project does NOT modify 7-Zip source code. It only wraps the CLI for GUI usage.

---

## ⚖️ License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)**.

You may:

- Use this software for any purpose
- Modify and distribute it
- Distribute modified versions

However:

- If you distribute modified versions, you must also release the source code under GPLv3
- You must include the original copyright and license

See the full license text in the `LICENSE` file.

---

## 📦 Third-party software

This project depends on:

### 7-Zip
- Author: Igor Pavlov  
- Website: https://www.7-zip.org/  
- License: LGPL / GPL (depending on components)

If you redistribute this project with bundled binaries, you must also comply with 7-Zip’s license terms.

---

## 🚀 Making
Make sure `7zz` is installed and available when making.

```bash
7zz --help
