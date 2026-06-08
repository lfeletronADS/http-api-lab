@echo off
:: --- TRAVA DE SEGURANÇA: DETECTAR SE ESTÁ DENTRO DO ZIP ---
echo %CD% | findstr /i "AppData\Local\Temp" >nul
if %errorlevel%==0 (
    cls
    echo ======================================================
    echo           ERRO CRITICO: EXTRAIA O ARQUIVO!
    echo ======================================================
    echo.
    echo ATENCAO: Voce tentou rodar o instalador de dentro do ZIP.
    echo O Laboratorio NAO funciona assim.
    echo.
    echo FACA O SEGUINTE:
    echo 1. Feche esta janela preta.
    echo 2. Clique com o botao DIREITO no arquivo .zip que voce baixou.
    echo 3. Escolha a opcao "EXTRAIR TUDO".
    echo 4. Entre na pasta extraida e ai sim execute este arquivo.
    echo.
    pause
    exit
)
:: --- FIM DA TRAVA ---

title HTTP API LAB - LEANDRO FERREIRA
cls
echo ======================================================
echo           VERIFICANDO REQUISITOS DO SISTEMA
echo ======================================================
echo.

:: 1. Verifica se o Docker existe
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [AVISO] O Docker nao foi encontrado neste computador.
    echo.
    echo O Docker e o "motor" necessario para rodar este Laboratorio.
    echo Vou abrir a pagina de download para voce...
    echo.
    timeout /t 5
    start https://www.docker.com/products/docker-desktop/
    echo [INSTRUCAO] 1. Baixe e instale o Docker Desktop.
    echo             2. Reinicie o computador se necessario.
    echo             3. Apos o Docker estar aberto, execute este arquivo novamente.
    pause
    exit
)

:: 2. Verifica se o Docker esta rodando
echo [OK] Docker instalado. Verificando se esta aberto...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [AVISO] O Docker esta instalado, mas NAO ESTA ABERTO.
    echo Por favor, abra o "Docker Desktop" e aguarde ele ficar "verde".
    echo.
    echo Pressione qualquer tecla quando o Docker estiver pronto...
    pause
)

cls
echo ======================================================
echo      INICIANDO HTTP API LAB
echo ======================================================
echo.
echo  Banco de dados: SQLite (sem instalacao necessaria)
echo  O banco sera criado automaticamente na pasta do projeto.
echo.
echo [1/3] Subindo o container...
docker compose up -d

echo.
echo [2/3] Aguardando o servidor iniciar...
timeout /t 8 /nobreak >nul

echo.
echo [3/3] Abrindo o Laboratorio no navegador...
start http://localhost:3005

echo.
echo ======================================================
echo   SUCESSO! Laboratorio disponivel em:
echo   http://localhost:3005
echo ======================================================
echo.
echo   Para parar o laboratorio, execute:
echo   docker compose down
echo.
pause
