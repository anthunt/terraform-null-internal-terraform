@echo off
setlocal

Rem ---------------------------------------------------------------------------
Rem Environment Variables
Rem ---------------------------------------------------------------------------
Rem %SOURCE%
Rem %COMMAND%
Rem %ROOT_PATH%
Rem %WORKSPACE%
Rem %MODULE_NAME%
Rem %MODULE_PATH%
Rem %COPYED_NAME%
Rem %VARIABLES%
Rem %OUTPUTS%

echo. %SOURCE%
echo. %COMMAND%
echo. %ROOT_PATH%
echo. %WORKSPACE%
echo. %MODULE_NAME%
echo. %MODULE_PATH%
echo. %COPYED_NAME%
echo. %VARIABLES%
echo. %OUTPUTS%

if "%COMMAND%" equ "apply" (
    set AUTO_APPROVE=-auto-approve
)

cd /D %ROOT_PATH%
if not exist %WORKSPACE% ( 
    mkdir %WORKSPACE%
)

cd %WORKSPACE%
if not exist %MODULE_NAME%.%COPYED_NAME% ( 
    mkdir %MODULE_NAME%.%COPYED_NAME%
)

xcopy "%SOURCE%" "%MODULE_PATH%.%COPYED_NAME%" /S /Y

cd %MODULE_NAME%.%COPYED_NAME%
echo %VARIABLES% > %COPYED_NAME%.auto.tfvars.json
terraform init
terraform %COMMAND% %AUTO_APPROVE%

for %%i in (%OUTPUTS%) do (
    terraform output %%i > %%i.json
)
