@echo off
chcp 65001 >nul
title Almeida, Leal ^& Molina - servidor local
cd /d "%~dp0"
echo.
echo  ===============================================
echo   Almeida, Leal ^& Molina - site local
echo  ===============================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo  Node.js nao encontrado. Instale a versao LTS em https://nodejs.org/
  echo  ^(e so avancar ate o fim da instalacao^) e de dois cliques neste arquivo de novo.
  echo.
  start "" https://nodejs.org/
  pause
  exit /b 1
)

if not exist "node_modules\express" (
  echo  Primeira vez rodando aqui: instalando dependencias.
  echo  Precisa de internet e leva ate 1 minuto...
  call npm install --no-audit --no-fund
  if errorlevel 1 (
    echo.
    echo  Falha ao instalar as dependencias. Verifique a internet e tente de novo.
    pause
    exit /b 1
  )
)

if not exist ".env" (
  echo  Criando configuracao local de teste ^(nao usar em producao^)...
  > .env echo PORT=3000
  >> .env echo NODE_ENV=development
  >> .env echo JWT_SECRET=chave-apenas-para-teste-local-trocar-em-producao-0000
  >> .env echo ADMIN_EMAIL=admin@almeidaleal.adv.br
  >> .env echo ADMIN_PASSWORD=admin123456
  >> .env echo DATA_DIR=./data
  echo  Painel /admin/ neste teste: admin@almeidaleal.adv.br / admin123456
)

REM Se o servidor ja estiver rodando em outra janela, so abre o navegador.
powershell -NoProfile -Command "try{(Invoke-WebRequest -UseBasicParsing http://localhost:3000/ -TimeoutSec 2).StatusCode|Out-Null;exit 0}catch{exit 1}" >nul 2>nul
if not errorlevel 1 (
  echo  O site ja esta rodando. Abrindo o navegador...
  start "" http://localhost:3000/
  exit /b 0
)

echo.
echo  Iniciando o site em http://localhost:3000
echo  O navegador abre sozinho em instantes.
echo  DEIXE ESTA JANELA ABERTA enquanto usa o site; feche-a para desligar.
echo.

REM Abre o navegador so depois de o servidor responder (ate ~20s).
start "" /b powershell -NoProfile -WindowStyle Hidden -Command "for($i=0;$i -lt 40;$i++){try{Invoke-WebRequest -UseBasicParsing http://localhost:3000/ -TimeoutSec 1|Out-Null;break}catch{Start-Sleep -Milliseconds 500}};Start-Process 'http://localhost:3000/'"

node server/index.js
echo.
echo  O servidor parou. Se apareceu um erro acima, envie-o ao suporte.
pause
