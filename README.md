# Zero Type

> 一個 Vibe Coding 出來的繁體中文語音輸入工具。

市面上大多數語音辨識軟體對繁體中文（特別是台灣人慣用的晶晶體中英混用語境）支援度有限，且背後處理邏輯不透明。ZeroType 透過直接串接外部 LLM API，打造一套開放、透明、可自訂的語音辨識輸入系統。

**你只需要自備 API Key，其餘一切開源。**

---

## ✨ 功能特色

### 🎙️ 全局快捷鍵錄音
- 自訂全局快捷鍵（macOS 預設 `⌥ Option + Space`、Windows 預設 `Alt + Space`），在任何應用程式中觸發錄音
- 錄音中顯示浮動音波 Overlay，提供即時視覺回饋
- 按下 `Esc` 或點擊取消按鈕可中止錄音

### 🧠 AI 驅動的語音辨識
- 支援 **OpenAI**（`gpt-4o-transcribe`）、**Google Gemini**（`gemini-*`）、以及 **LiteLLM Proxy** 三大後端
- LiteLLM 模式會自動從 proxy 的 `/v1/models` 抓取可用模型清單，動態選用 Whisper / Gemini / Claude / GPT-4o-audio 等模型
- 辨識完成後，結果自動貼至游標所在位置（macOS 模擬 `⌘V`、Windows 模擬 `Ctrl+V`）
- 支援自訂 API Endpoint（可使用 OpenAI-compatible 的第三方服務）

### ✨ 文字優化（可選）
- 轉錄完成後，可選擇再丟給聊天模型（GPT / Claude / Gemini）做格式化、錯字修正、條列整理
- 優化的 provider / model / prompt 完全獨立，可以「便宜模型轉錄、聰明模型優化」
- 設定頁有獨立 toggle 控制是否啟用，預設關閉

### 🇹🇼 針對繁體中文深度優化的提示詞
內建的轉錄提示詞針對台灣使用情境做了以下優化：

| 功能 | 說明 |
|------|------|
| **晶晶體支援** | 中英文混用語句自然處理，英文單字保留原文不翻譯、不中文化 |
| **智慧過濾廢詞** | 自動剔除「嗯」、「啊」、「呃」、「喔」、「那個」、「然後」、「基本上」等停頓填充詞 |
| **口誤修正偵測** | 偵測到「不對」、「應該是」、「我說錯了」、「才對」等字眼，自動捨棄前段錯誤並保留修正內容 |
| **智慧標點** | 根據語意自動補上逗號、句號，不需手動停頓 |
| **自動條列輸出** | 偵測到序數（第一、第二）或連接詞（首先、然後、最後）時，自動轉為 `1. 2. 3.` 或 `- ` 格式並換行 |
| **格式口語還原** | 說出「大寫」、「小寫」、「空格」、「底線」、「驚嘆號」等，自動還原為對應字元 |
| **空白錄音保護** | 錄音檔為空時直接返回空字串，嚴禁自行幻想內容 |

### 📖 自訂字典
- 可設定個人化的專有名詞字典（人名、品牌、術語）
- 辨識時優先採用字典用字，確保拼寫正確

### ⚙️ 設定頁面
- 深色 / 淺色模式切換
- 開機自動啟動
- 快捷鍵自訂（支援任意組合鍵）
- 麥克風權限與輔助使用權限狀態即時顯示

---

## 🔧 使用前準備

### 系統需求
- **macOS 11.0+**，或 **Windows 10 / 11 (x64)**
- Flutter 3.x（如需自行 build）

### 必要系統授權
1. **麥克風** — 錄音所需（Windows 第一次按 Alt+Space 時會跳系統權限請求）
2. **輔助使用（Accessibility）** — macOS 模擬鍵盤輸入（`⌘V` 貼上）所需。**Windows 不需要此權限**，使用 SendInput API 直接送 Ctrl+V

### API Key
前往以下任一服務申請 API Key（或使用你自己的 LiteLLM proxy）：
- [OpenAI](https://platform.openai.com/api-keys)（支援 Transcribe / Whisper / GPT-4o-audio）
- [Google AI Studio](https://aistudio.google.com/app/apikey)（支援 Gemini 多模態）
- 自架 [LiteLLM Proxy](https://github.com/BerriAI/litellm)（一個 endpoint 串接所有 LLM）

---

## 🚀 快速開始

### 方法一：直接下載（推薦）

#### macOS

1. 前往 [Releases](https://github.com/alarmz/ZeroType/releases) 頁面下載最新的 `.dmg`
2. 開啟 `.dmg` 並將 **ZeroType.app** 拖入 Applications 資料夾
3. 首次執行時，依照提示授予以下權限：
   - **麥克風** — 語音輸入所需
   - **輔助使用（Accessibility）** — 模擬鍵盤貼上所需
4. 在 App 內的「模型設定」填入你的 API Key，即可開始使用

#### Windows

1. 從 [Releases](https://github.com/alarmz/ZeroType/releases/latest) 下載 `ZeroTypeSetup-x.y.z.exe`
2. 雙擊執行安裝程式：
   - **第一頁**會中英對照解釋兩種安裝模式（管理員 vs 一般使用者）
   - 按下一步時 Windows 跳 UAC：
     - 按「**是**」（管理員模式）→ 裝到 Program Files、自動允許麥克風存取、可勾選開機自動啟動
     - 按「**否**」（一般使用者）→ 裝到 `%LOCALAPPDATA%\Programs\ZeroType`、不會自動寫入系統設定（你需要手動到 Windows Settings → Privacy → Microphone 允許）
3. 安裝完成後 ZeroType 會自動啟動
4. 在「模型」頁填入 API Key 與選擇模型，按 `Alt+Space` 即可開始

### 方法二：從原始碼 Build（進階）

```bash
git clone https://github.com/alarmz/ZeroType.git
cd ZeroType
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# macOS
flutter run -d macos

# Windows
flutter run -d windows
# 或產生 release exe：
flutter build windows --release
# 產出位置：build/windows/x64/runner/Release/zero_type.exe
```

> **Windows build 需求**：Flutter 3.41+、Visual Studio Build Tools 2022（含 C++ Desktop workload）、Windows 11 SDK、開啟 Developer Mode（symlink 支援）。

---

## 🔌 LiteLLM Proxy 設定

LiteLLM 提供一個 OpenAI-compatible 的代理端點，能統一接 Whisper / Gemini / Claude / OpenAI / Groq 等多家後端。ZeroType 對 LiteLLM 做了原生支援：

1. **「模型」頁** → Provider 選 **LiteLLM**
2. 填入你的 **Proxy Base URL**（例如 `https://litellm.example.com` 或 `http://192.168.x.x:4000`，**不要含 `/v1`**）
3. 填入 LiteLLM **virtual key** 並按儲存
4. 按「選擇模型」右側的 🔄 按鈕 → 程式自動從 `/v1/models` 抓取你 proxy 上所有可用模型
5. 從下拉選單選一個

### 模型支援度

ZeroType 會根據選擇的模型自動走不同 endpoint：

| 模型類型 | Endpoint | 範例 |
|---|---|---|
| 名稱含 `whisper` | `/v1/audio/transcriptions` | `whisper-1`、`groq-whisper-large` |
| 多模態（吃 audio）| `/v1/chat/completions` + `input_audio` | `gemini-2.5-flash-lite`、`claude-haiku-4-5`、`gpt-4o-audio-preview` |
| 純文字模型 | ❌ 不支援 | `gpt-4`、`gpt-5.5`、`claude-haiku-4-5-text` 等

---

## 🌍 語言支援 & 貢獻 (Localization & Contribution)

- **地區限制**：目前此 App 主要針對 **台灣使用情境** 設計，輸出內容以 **繁體中文** 與 **英文** 為主。未來是否有增加其他語言支援？若「有緣」的話之後再行考慮。
- **回報問題與協助**：如果你在使用上發現任何問題，或是單純想提供改進建議，歡迎直接發 **Issue** 或發 **Pull Request** 給我。只要我有看到訊息，第一時間就會來幫大家處理與解決。

---

## 📜 版本更新紀錄 (Release Notes)

### [v1.1.0] - 當前版本（Windows 首發）

**Windows 全平台支援** 🪟
- Windows 10 / 11 原生 desktop app，使用 SendInput 模擬 Ctrl+V 貼上
- 預設熱鍵 `Alt + Space`，UI 自動顯示 Win/Ctrl/Alt/Shift modifier
- 可拖曳的標題列 + min/max/close 視窗按鈕（多螢幕可正常移動）
- WAV 格式錄音（16 kHz mono PCM），相容 OpenAI / Whisper / Gemini / Claude

**LiteLLM Proxy 支援** 🔌
- 新增 LiteLLM provider，自動從 `/v1/models` 抓取模型清單並快取
- 智慧路由：whisper-* 走 `/v1/audio/transcriptions`、其他走 `/v1/chat/completions` 多模態
- 友善的錯誤訊息，當選到不支援 audio 的模型會直接列出可用替代

**文字優化** ✨
- 新增「文字優化」功能，轉錄後再過一層 chat LLM 做格式化／錯字修正
- 獨立的 provider / model / prompt 設定，可在「模型」頁與「提示詞」頁分別配置
- 設定頁 toggle 控制，預設關閉

**Windows installer + CI** 📦
- GitHub Actions 自動 build Windows release，每次 push 都產生 installer artifact
- Inno Setup 安裝程式：admin 模式自動寫麥克風白名單與開機啟動，一般模式則裝到 LocalAppData
- Tag-driven release：push `vX.Y.Z` tag 自動發 GitHub Release

**Logging** 🔎
- 新增檔案 logger 寫到 `%TEMP%\zero_type.log`（macOS: `/tmp/zero_type.log`）
- 浮動圓條顯示完整錯誤訊息（不只「錯誤」兩個字），含 HTTP status + 回應 body

### [v1.0.2]
- **新增歷史紀錄頁** 🎨
  - 提供歷史產生逐字稿的紀錄語音檔，並可提供檢視。
  - 新增總轉寫次數與總花費（USD）的持久化累計統計。
- **最長錄音自訂** ⏱️
  - 設定中新增「最長錄音時間」選項，範圍 1-5 分鐘，預設為 1 分鐘。
- **編輯器優化** ✍️
  - 提示詞編輯框寬度與高度現在會隨視窗大小自適應，不再固定長度。

### [v1.0.1]
- **錄音音效支援** 🔊 — 可設定錄音開始與結束提示音。
- **功能修復** 🐛 — 修正 macOS 上視窗關閉後無法再次開啟的問題。
- **提示詞優化** 📝 — 進一步精簡轉錄用的系統 Prompt。

---

## 📝 License

MIT — 自由使用、修改、散布，唯需自備 API Key。
