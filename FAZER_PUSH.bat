@echo off
REM Script para fazer push dos arquivos atualizados
REM Coloca este arquivo na pasta do projeto (C:\Users\55119\Desktop\OSCARIBA)
REM Depois clica 2x pra executar

cd /d %~dp0

echo.
echo 📁 Pasta atual: %cd%
echo.

REM Copiar o novo index.html e o áudio
REM (Você já tem esses arquivos baixados)

echo ✅ Adicionando arquivos ao Git...
git add index.html dice-sound.mp3

echo ✅ Fazendo commit...
git commit -m "Adicionar som dos dados quando rodam"

echo ✅ Fazendo push para GitHub...
git push origin main

echo.
echo 🎉 PRONTO! Vercel vai atualizar automaticamente em alguns segundos
echo.
pause
