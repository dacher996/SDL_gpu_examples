:: Requires shadercross CLI installed from SDL_shadercross
@echo off
setlocal enabledelayedexpansion

:: Create output directories first if not present
if not exist "..\Compiled\SPIRV" mkdir "..\Compiled\SPIRV"
if not exist "..\Compiled\MSL" mkdir "..\Compiled\MSL"
if not exist "..\Compiled\DXIL" mkdir "..\Compiled\DXIL"

for %%f in (*.vert.hlsl) do (
    if exist "%%f" (
        shadercross "%%f" -o "..\Compiled\SPIRV\%%~nf.spv"
        shadercross "%%f" -o "..\Compiled\MSL\%%~nf.msl"
        shadercross "%%f" -o "..\Compiled\DXIL\%%~nf.dxil"
    )
)

for %%f in (*.frag.hlsl) do (
    if exist "%%f" (
        shadercross "%%f" -o "..\Compiled\SPIRV\%%~nf.spv"
        shadercross "%%f" -o "..\Compiled\MSL\%%~nf.msl"
        shadercross "%%f" -o "..\Compiled\DXIL\%%~nf.dxil"
    )
)

for %%f in (*.comp.hlsl) do (
    if exist "%%f" (
        shadercross "%%f" -o "..\Compiled\SPIRV\%%~nf.spv"
        shadercross "%%f" -o "..\Compiled\MSL\%%~nf.msl"
        shadercross "%%f" -o "..\Compiled\DXIL\%%~nf.dxil"
    )
)