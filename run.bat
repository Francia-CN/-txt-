@echo off
setlocal

:: ============================================================================
:: 多格式文档批量转换txt工具 v1.0 - 启动器
:: ============================================================================

:: --- 0. 编码兼容性处理 ---
:: 切换代码页为UTF-8 (65001)，以正确显示脚本中的中文字符。
:: >nul 用于隐藏 "Active code page: 65001" 的输出，保持界面整洁。
chcp 65001 >nul

:: --- 1. 配置变量 ---
set "PYTHON_SCRIPT=run.py"
set "DEFAULT_INPUT_DIR=input"
set "DEFAULT_OUTPUT_DIR=output"
set "CLEAN_FLAG="
set "PYTHON_EXE="
set "ORIGINAL_CODE_PAGE=%errorlevel%"

:: 清理屏幕，提供一个干净的界面
cls

title 多格式文档批量转换txt工具 v1.0

echo.
echo  ================================================================
echo.
echo                多格式文档批量转换txt工具 v1.0
echo.
echo  ================================================================
echo.

:: --- 2. 环境预检 ---
echo [信息] 正在检查运行环境...

:: 检查Python可执行文件 (优先python, 其次python3)
where python >nul 2>nul
if %errorlevel% == 0 (
    set "PYTHON_EXE=python"
) else (
    where python3 >nul 2>nul
    if %errorlevel% == 0 (
        set "PYTHON_EXE=python3"
    )
)

if not defined PYTHON_EXE (
    echo [致命错误] 未在系统中找到 Python 环境！
    echo.
    echo   请访问 https://www.python.org/downloads/ 安装 Python,
    echo   并确保在安装时勾选了 "Add Python to PATH" 选项。
    goto :error_exit
)

:: 检查核心的Python脚本文件是否存在
if not exist "%~dp0%PYTHON_SCRIPT%" (
    echo [致命错误] 核心脚本 "%PYTHON_SCRIPT%" 不存在！
    echo.
    echo   请确保 "%PYTHON_SCRIPT%" 文件与此启动器位于同一目录下。
    goto :error_exit
)
echo [成功] 环境检查通过。
echo.

:: --- 3. 确定输入/输出路径 ---
if "%~1"=="" (
    echo [模式] 双击运行模式。将使用默认的 input/output 文件夹。
    set "INPUT_DIR=%~dp0%DEFAULT_INPUT_DIR%"
    set "OUTPUT_DIR=%~dp0%DEFAULT_OUTPUT_DIR%"

    if not exist "%INPUT_DIR%\" (
        echo [致命错误] 默认的 "input" 文件夹不存在！
        echo.
        echo   请在本工具目录下手动创建一个名为 "input" 的文件夹，并将待转换文件放入其中。
        goto :error_exit
    )
) else (
    echo [模式] 拖拽文件夹模式。
    if not exist "%~1\" (
        echo [致命错误] 您拖拽的 "%~1" 不是一个有效的文件夹！
        goto :error_exit
    )
    set "INPUT_DIR=%~f1"
    set "OUTPUT_DIR=%~f1_output"
)
echo.

:: --- 4. 交互式安全确认 (清空输出目录) ---
if exist "%OUTPUT_DIR%\" (
    echo [警告] 输出目录 "%OUTPUT_DIR%" 已存在。
    choice /C YN /M "您想在转换前清空它吗？(Y/N): "
    
    if errorlevel 2 (
        echo [信息] 您选择了不清空。如果输出目录中存在同名.txt文件，它们将被覆盖。
    ) else (
        echo [确认] 您选择了清空。正在准备清空目录...
        set "CLEAN_FLAG=--clean-output"
    )
)
echo.

:: --- 5. 执行转换 ---
echo ----------------------------------------------------------------
echo [执行] 准备调用Python脚本开始转换...
echo.
echo   - 输入目录: "%INPUT_DIR%"
echo   - 输出目录: "%OUTPUT_DIR%"
echo.
echo ----------------------------------------------------------------
echo.

:: 切换到Python脚本所在的目录，然后执行
cd /d "%~dp0"
%PYTHON_EXE% "%PYTHON_SCRIPT%" "%INPUT_DIR%" "%OUTPUT_DIR%" %CLEAN_FLAG%

echo.
echo ----------------------------------------------------------------
echo.

:: --- 6. 完成并退出 ---
echo [完成] 脚本执行完毕！
echo.
echo   结果已保存至: "%OUTPUT_DIR%"
echo.
echo   正在为您自动打开该文件夹...
start "" "%OUTPUT_DIR%"

goto :graceful_exit


:error_exit
echo.
echo  ================================================================
echo.
echo                          操作已终止
echo.
echo  ================================================================
pause
goto :end

:graceful_exit
echo.
echo  ================================================================
echo.
echo                   感谢使用，窗口5秒后自动关闭
echo.
echo  ================================================================
timeout /t 5 >nul

:end
:: 恢复原始代码页，这是一个好习惯
chcp %ORIGINAL_CODE_PAGE% >nul
endlocal
