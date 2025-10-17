@echo off
echo activating environment wan2gp...
call conda activate wan2gp

echo opening Python wgp.py with argument --i2v...
call python wgp.py --i2v --open-browser

echo process completed
pause