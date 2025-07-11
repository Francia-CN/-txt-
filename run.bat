@echo off
setlocal

:: ============================================================================
:: ���ʽ�ĵ�����ת������ v1.0 - ������
:: ============================================================================

:: --- 1. ���ñ��� ---
set "PYTHON_SCRIPT=run.py"
set "DEFAULT_INPUT_DIR=input"
set "DEFAULT_OUTPUT_DIR=output"
set "CLEAN_FLAG="
set "PYTHON_EXE="

:: ������Ļ���ṩһ���ɾ��Ľ���
cls

title ���ʽ�ĵ�����ת������ v1.0

echo.
echo  ================================================================
echo.
echo                ���ʽ�ĵ�����ת������ v1.0
echo.
echo  ================================================================
echo.

:: --- 2. ����Ԥ�� ---
echo [��Ϣ] ���ڼ�����л���...

:: ���Python��ִ���ļ� (����python, ���python3)
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
    echo [��������] δ��ϵͳ���ҵ� Python ������
    echo.
    echo   ����� https://www.python.org/downloads/ ��װ Python,
    echo   ��ȷ���ڰ�װʱ��ѡ�� "Add Python to PATH" ѡ�
    goto :error_exit
)

:: �����ĵ�Python�ű��ļ��Ƿ����
if not exist "%~dp0%PYTHON_SCRIPT%" (
    echo [��������] ���Ľű� "%PYTHON_SCRIPT%" �����ڣ�
    echo.
    echo   ��ȷ�� "%PYTHON_SCRIPT%" �ļ����������λ��ͬһĿ¼�¡�
    goto :error_exit
)
echo [�ɹ�] �������ͨ����
echo.

:: --- 3. ȷ������/���·�� ---
if "%~1"=="" (
    echo [ģʽ] ˫������ģʽ����ʹ��Ĭ�ϵ� input/output �ļ��С�
    set "INPUT_DIR=%~dp0%DEFAULT_INPUT_DIR%"
    set "OUTPUT_DIR=%~dp0%DEFAULT_OUTPUT_DIR%"

    if not exist "%INPUT_DIR%\" (
        echo [��������] Ĭ�ϵ� "input" �ļ��в����ڣ�
        echo.
        echo   ���ڱ�����Ŀ¼���ֶ�����һ����Ϊ "input" ���ļ��У�������ת���ļ��������С�
        goto :error_exit
    )
) else (
    echo [ģʽ] ��ק�ļ���ģʽ��
    if not exist "%~1\" (
        echo [��������] ����ק�� "%~1" ����һ����Ч���ļ��У�
        goto :error_exit
    )
    set "INPUT_DIR=%~f1"
    set "OUTPUT_DIR=%~f1_output"
)
echo.

:: --- 4. ����ʽ��ȫȷ�� (������Ŀ¼) ---
if exist "%OUTPUT_DIR%\" (
    echo [����] ���Ŀ¼ "%OUTPUT_DIR%" �Ѵ��ڡ�
    choice /C YN /M "������ת��ǰ�������(Y/N): "
    
    if errorlevel 2 (
        echo [��Ϣ] ��ѡ���˲���ա�������Ŀ¼�д���ͬ��.txt�ļ������ǽ������ǡ�
    ) else (
        echo [ȷ��] ��ѡ������ա�����׼�����Ŀ¼...
        set "CLEAN_FLAG=--clean-output"
    )
)
echo.

:: --- 5. ִ��ת�� ---
echo ----------------------------------------------------------------
echo [ִ��] ׼������Python�ű���ʼת��...
echo.
echo   - ����Ŀ¼: "%INPUT_DIR%"
echo   - ���Ŀ¼: "%OUTPUT_DIR%"
echo.
echo ----------------------------------------------------------------
echo.

:: �л���Python�ű����ڵ�Ŀ¼��Ȼ��ִ��
cd /d "%~dp0"
%PYTHON_EXE% "%PYTHON_SCRIPT%" "%INPUT_DIR%" "%OUTPUT_DIR%" %CLEAN_FLAG%

echo.
echo ----------------------------------------------------------------
echo.

:: --- 6. ��ɲ��˳� ---
echo [���] �ű�ִ����ϣ�
echo.
echo   ����ѱ�����: "%OUTPUT_DIR%"
echo.
echo   ����Ϊ���Զ��򿪸��ļ���...
start "" "%OUTPUT_DIR%"

goto :graceful_exit


:error_exit
echo.
echo  ================================================================
echo.
echo                          ��������ֹ
echo.
echo  ================================================================
pause
goto :end

:graceful_exit
echo.
echo  ================================================================
echo.
echo                   ��лʹ�ã�����5����Զ��ر�
echo.
echo  ================================================================
timeout /t 5 >nul

:end
endlocal