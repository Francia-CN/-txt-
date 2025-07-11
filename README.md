======================================================================
多格式文档批量转换工具 (v1.0) - README
======================================================================

一个高效、健壮、可扩展的命令行工具，用于将多种格式的文档（如 EPUB, MOBI,
PDF, DOCX）批量转换为纯文本（.txt）文件。

## ✨ 主要特性

- 多格式支持: 原生支持对 .epub, .docx, .pdf 格式的文本提取，并可借助
  Calibre 环境支持 .mobi 和 .azw3 等更多电子书格式。
- 高性能: 利用多进程并行处理，能充分利用现代多核 CPU 的性能，大幅缩短
  大批量文件的转换时间。
- 高度健壮: 对加密文件、内容为空、格式不规范等异常情况有良好的处理和
  回退机制，确保单个文件的失败不影响整体任务。
- 用户友好:
  - 提供实时进度条（tqdm），直观展示处理进度。
  - 在终端使用彩色状态输出，转换结果一目了然。
  - 为每次运行生成详细的日志报告，便于排查问题。
- 灵活配置: 支持通过命令行参数自定义并发进程数、单个文件处理超时时间、
  包含/排除特定文件类型等。
- 安全可靠: 对于清空输出目录等危险操作，需要用户显式授权，防止意外
  数据丢失。
- 易于扩展: 采用策略模式设计，添加对新文件格式的支持非常简单。

## 📚 支持格式

| 格式     | 依赖库/工具          | 处理方式                             |
| :------- | :------------------- | :----------------------------------- |
| .epub    | lxml, beautifulsoup4 | **转换为 .txt** (内置解析器)         |
| .docx    | python-docx          | **转换为 .txt** (内置解析器)         |
| .pdf     | PyMuPDF              | **转换为 .txt** (内置解析器)         |
| .mobi    | Calibre              | **转换为 .txt** (调用 ebook-convert) |
| .azw3    | Calibre              | **转换为 .txt** (调用 ebook-convert) |
| 其他格式 | _无_                 | **直接复制**到输出目录               |

## ⚙️ 环境要求与安装

1. Python 环境
   确保您已安装 Python 3.7 或更高版本。

2. 安装依赖库

   核心依赖 (必须安装):
   [BASH]
   pip install lxml beautifulsoup4 tqdm

   可选依赖 (根据需要安装):

   - 要转换 .docx 文件，请安装 python-docx。
   - 要转换 .pdf 文件，请安装 PyMuPDF。

   推荐一次性安装所有 Python 依赖：
   [BASH]
   pip install lxml beautifulsoup4 tqdm python-docx PyMuPDF

3. 安装 Calibre (用于转换 .mobi/.azw3)

   为了转换 .mobi 和 .azw3 格式，您必须安装 Calibre 软件。
   (下载地址: https://calibre-ebook.com/download)

   重要提示: 在安装 Calibre 后，请确保其命令行工具 (`ebook-convert`)
   所在的路径已被添加到系统的环境变量 `PATH` 中。

   您可以在终端中运行以下命令来检查 `ebook-convert` 是否配置成功：
   [CMD/BASH]
   ebook-convert --version

   如果命令成功执行并返回版本号，则表示配置正确。

## 🚀 使用方法

1. 准备目录

   - 输入目录: 默认情况下，脚本会读取名为 `input` 的文件夹。您可以将
     所有待转换的文档放入此文件夹（支持子文件夹）。
   - 输出目录: 转换后的文件将保存到 `output` 文件夹中，并保持与输入
     目录相同的目录结构。

2. 运行脚本

   基本用法
   (处理 `input` 目录, 输出到 `output` 目录)
   [CMD/BASH]
   python run.py

   指定输入/输出目录
   [CMD/BASH]
   python run.py ./我的书籍 ./转换结果

   指定进程数并清空输出目录
   (使用 8 个进程，并在开始前强制清空 `texts` 目录)
   警告: `--clean-output` 会删除输出目录下的所有内容，请谨慎使用！
   [CMD/BASH]
   python run.py ./books ./texts -t 8 --clean-output

   只转换特定类型的文件
   (仅处理目录中的 .epub 和 .pdf 文件)
   [CMD/BASH]
   python run.py ./in ./out --include .epub,.pdf

   排除特定类型的文件
   (处理所有支持的文件，但跳过所有的图片和压缩包)
   [CMD/BASH]
   python run.py ./in ./out --exclude .jpg,.png,.zip

3. 命令行参数详解

   usage: run.py [-h] [-t THREADS] [--timeout TIMEOUT] [--clean-output]
   [--include INCLUDE] [--exclude EXCLUDE] [--no-color]
   [input] [output]

   多格式文档批量转换工具 (v1.1)

   positional arguments:
   input 输入目录路径 (默认: 'input')
   output 输出目录路径 (默认: 'output')

   options:
   -h, --help show this help message and exit
   -t THREADS, --threads THREADS
   处理进程数 (默认: 系统 CPU 核心数)
   --timeout TIMEOUT 单个文件的最大处理时间(秒) (默认: 120)
   --clean-output 在开始前清空已存在的输出目录 (危险操作!)
   --include INCLUDE 只处理指定后缀的文件, 用逗号分隔 (例: .epub,.pdf)
   --exclude EXCLUDE 排除指定后缀的文件, 用逗号分隔 (例: .jpg,.png)
   --no-color 禁用所有彩色控制台输出

## 📁 目录结构

执行脚本后，您的项目目录将如下所示：

.
├── input/ # 你的原始文件放在这里
│ ├── book1.epub
│ ├── subfolder/
│ │ └── report.docx
│ └── picture.jpg
│
├── output/ # 转换后的 .txt 文件会在这里生成
│ ├── book1.txt
│ ├── subfolder/
│ │ └── report.txt
│ └── picture.jpg # 不支持转换的文件被直接复制
│
├── logs/ # 日志文件夹
│ └── conversion_20250711_100500.log # 记录了每次运行的详细信息
│
└── run.py # 主脚本

## 💡 工作原理

- 策略模式: 脚本内部使用一个字典（`PROCESSOR_STRATEGIES`）将文件
  后缀映射到对应的处理函数。
- 多进程池: 利用 `concurrent.futures.ProcessPoolExecutor` 创建一个
  进程池，将文件处理任务异步提交，实现并行化处理。
- EPUB 健壮解析: `handle_epub` 函数在解析时会首先尝试使用严格的
  XML 解析器，如果遇到不规范的 XML，它会自动切换到容错性更强的
  HTML 解析器，大大提高了兼容性。
- 详细的日志与报告: 每次运行都会在 `logs` 目录下生成独立的日志文件，
  并在控制台打印一份简洁明了的总结报告。
