# Requires shadercross CLI installed from SDL_shadercross

# Create directories
mkdir -p ../Compiled/{SPIRV,MSL,DXIL}

# Loop through all HLSL files that match the patterns
for filename in *.vert.hlsl *.frag.hlsl *.comp.hlsl; do
    if [ -f "$filename" ]; then
        shadercross "$filename" -o "../Compiled/SPIRV/${filename/.hlsl/.spv}"
        shadercross "$filename" -o "../Compiled/MSL/${filename/.hlsl/.msl}"
        shadercross "$filename" -o "../Compiled/DXIL/${filename/.hlsl/.dxil}"
    fi
done