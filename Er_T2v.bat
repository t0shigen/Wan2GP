@echo off
echo activating environment wan2gp...
call conda activate wan2gp

echo opening Python wgp.py...
call python wgp.py --open-browser

echo process completed
pause