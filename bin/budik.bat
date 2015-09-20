@echo off

cd %~dp0
cd ..
ruby ./lib/budik.rb %*
