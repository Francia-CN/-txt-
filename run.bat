@echo off
REM 使用 setlocal 和 endlocal 是一个好习惯，可以防止脚本中的变量污染用户的系统环境。
REM enabledelayedexpansion 允许在循环或IF语句中正确读取变化的变量（如此脚本中的!DEBUG_MODE!）。
setlocal enabledelayedexpansion

REM ============================================================================
REM  多格式文档批量转换txt工具 v1.0 - 启动器
REM ============================================================================
REM
REM   功能特性:
REM   - 自动检测并兼容 UTF-8 编码，防止中文乱码。
REM   - 提供调试模式：启动时按住 Shift 键，脚本会分步执行，便于排查问题。
REM   - 自动查找 Python 环境，无需手动配置。
REM   - 支持双击运行（处理input目录）和拖拽文件夹两种模式。
REM   - 对清空输出目录等危险操作进行交互式二次确认。
REM   - 捕获 Python 脚本的执行错误，确保窗口不会闪退。
REM
REM ============================================================================


REM --- 0. 调试模式检测 ---
REM 如果在双击此脚本时按下了SHIFT键，则激活调试模式，分步暂停执行。
if defined SHIFT (
    set "DEBUG_MODE=ON"
    echo [调试模式] 已激活。脚本将分步执行，请按任意键继续...
    pause
) else (
    set "DEBUG_MODE=OFF"
)

REM 清理屏幕，提供一个干净的界面。
cls


REM --- 1. 环境初始化：设置编码与标题 ---
title 多格式文档批量转换txt工具 v1.0

REM 切换代码页为UTF-8 (65001) 来正确显示中文字符，>nul 用于隐藏切换时的提示信息。
chcp 65001 >nul


REM --- 2. 显示欢迎信息 ---
echo.
echo  ================================================================
echo.
echo                多格式文档批量转换txt工具 v1.0
echo.
echo  ================================================================
echo.


REM --- 3. 环境预检 ---
set "PYTHON_SCRIPT=run.py"
set "DEFAULT_INPUT_DIR=input"
set "DEFAULT_OUTPUT_DIR=output"
set "CLEAN_FLAG="
set "PYTHON_EXE="

echo [信息] 正在检查运行环境...

REM 检查Python可执行文件 (优先查找python, 其次是python3)。
where python >nul 2>nul
if %errorlevel% == 0 (
    set "PYTHON_EXE=python"
) else (
    where python3 >nul 2>nul
    if %errorlevel% == 0 (
        set "PYTHON_EXE=python3"
    )
)

REM 如果未找到任何Python可执行文件，则报错退出。
if not defined PYTHON_EXE (
    echo [致命错误] 未在系统中找到 Python 环境！
    echo.
    echo   请访问 https://www.python.org/downloads/ 安装 Python,
    echo   并确保在安装时勾选了 "Add Python to PATH" 选项。
    goto :error_exit
)

REM 检查核心的Python脚本文件是否存在。
if not exist "%~dp0%PYTHON_SCRIPT%" (
    echo [致命错误] 核心脚本 "%PYTHON_SCRIPT%" 不存在！
    echo.
    echo   请确保 "%PYTHON_SCRIPT%" 文件与此启动器位于同一目录下。
    goto :error_exit
)

echo [成功] 环境检查通过。
echo.
if "!DEBUG_MODE!"=="ON" (pause)


REM --- 4. 确定输入/输出路径 ---
REM 判断是双击运行还是拖拽文件运行。
if "%~1"=="" (
    echo [模式] 双击运行。将使用默认的 "input" 和 "output" 文件夹。
    set "INPUT_DIR=%~dp0%DEFAULT_INPUT_DIR%"
    set "OUTPUT_DIR=%~dp0%DEFAULT_OUTPUT_DIR%"

    if not exist "%INPUT_DIR%\" (
        echo [致命错误] 默认的 "input" 文件夹不存在！
        echo.
        echo   请在本工具目录下手动创建一个名为 "input" 的文件夹，并将待转换文件放入其中。
        goto :error_exit
    )
) else (
    echo [模式] 拖拽文件夹。
    if not exist "%~1\" (
        echo [致命错误] 您拖拽的 "%~1" 不是一个有效的文件夹！
        goto :error_exit
    )
    set "INPUT_DIR=%~f1"
    set "OUTPUT_DIR=%~f1_output"
)
echo.
if "!DEBUG_MODE!"=="ON" (
    echo [调试] 输入目录: "!INPUT_DIR!"
    echo [调试] 输出目录: "!OUTPUT_DIR!"
    pause
)


REM --- 5. 安全确认 (清空输出目录) ---
if exist "%OUTPUT_DIR%\" (
    echo [警告] 输出目录 "!OUTPUT_DIR!" 已存在。
    REM /N 使“N”(否)成为默认选项，防止用户误操作。
    choice /C YN /N /M "您想在转换前清空它吗? [Y/N]:"
    
    if errorlevel 2 (
        echo [信息] 您选择了不清空。目录中已存在的文件可能会被覆盖。
    ) else (
        echo [确认] 您选择了清空，相关标志已设置。
        set "CLEAN_FLAG=--clean-output"
    )
)
echo.
if "!DEBUG_MODE!"=="ON" (pause)


REM --- 6. 执行核心转换任务 ---
echo ----------------------------------------------------------------
echo [执行] 准备调用Python脚本，请稍候...
echo.
echo   - 输入目录: "!INPUT_DIR!"
echo   - 输出目录: "!OUTPUT_DIR!"
echo.
echo ----------------------------------------------------------------
echo.

REM 切换到Python脚本所在的目录，然后用找到的Python解释器执行主脚本。
cd /d "%~dp0"
!PYTHON_EXE! "!PYTHON_SCRIPT!" "!INPUT_DIR!" "!OUTPUT_DIR!" !CLEAN_FLAG!

REM 检查Python脚本的退出代码。如果非0，则表示执行过程中发生了错误。
if errorlevel 1 (
	echo.
	echo [致命错误] Python 脚本执行失败，请检查以上由Python输出的错误信息。
	goto :error_exit
)


REM --- 7. 完成与收尾 ---
echo.
echo ----------------------------------------------------------------
echo.
echo [完成] 脚本执行完毕！
echo.
echo   结果已保存至: "!OUTPUT_DIR!"
echo.
echo   正在为您自动打开结果文件夹...
start "" "!OUTPUT_DIR!"
goto :graceful_exit


REM --- 错误处理与退出流程 ---
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
echo                   感谢使用，窗口5秒后将自动关闭
echo.
echo  ================================================================
timeout /t 5 >nul
goto :end

:end
endlocal```
