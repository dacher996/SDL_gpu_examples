# SDL GPU Examples Documentation

This document describes all the files located in the `Examples/` directory of the `SDL_gpu_examples` project, organized in order of increasing complexity.

## main.c

The main entry point for the application.

**Technical details:**
Contains the `main` loop, initializes SDL, handles window events (including suspension/resumption on supported platforms), gamepad input, and routes the application lifecycle to the currently selected example structure. It cycles through the examples when the user presses left/right inputs.

## Common (Common.c & Common.h)

The foundational framework and utility library used by all examples.

**Technical details:**
Provides cross-platform initialization (`CommonInit`), teardown (`CommonQuit`), and asset loading. It handles creating the `SDL_GPUDevice`, managing input states (`Context`), abstracting shader loading via SPIR-V/MSL/DXIL (`LoadShader`, `CreateComputePipelineFromShader`), and loading image files (`LoadImage`). 
*   **Shader Cross-Compilation**: Demonstrates how SDL GPU handles multiple backend-specific shader formats dynamically.

## ClearScreen

A fundamental example demonstrating the most basic GPU operation.

**Technical details:**
Shows how to set up a basic render pass to simply clear the swapchain texture to an alternating color each frame. Illustrates the core command buffer and render pass lifecycle.
*   **Command Buffer**: A queue where GPU commands (like rendering, copying, or computing) are recorded before being submitted (`SDL_AcquireGPUCommandBuffer`, `SDL_SubmitGPUCommandBuffer`).
*   **Swapchain Texture**: The specific texture currently designated to be presented to the user's window (`SDL_WaitAndAcquireGPUSwapchainTexture`).

## ClearScreenMultiWindow

Demonstrates handling and rendering to multiple windows using the same GPU device.

**Technical details:**
Creates a second SDL window and claims it for the existing GPU device using `SDL_ClaimWindowForGPUDevice`. It acquires swapchain textures for both windows simultaneously and submits distinct render passes to clear them with different colors.
*   **Multi-window Swapchains**: A single GPU context managing multiple presentation surfaces simultaneously.

## BasicTriangle

Illustrates the setup of a basic graphics pipeline to render geometry.

**Technical details:**
Renders a simple triangle without using a vertex buffer (vertices are generated directly within the vertex shader). It demonstrates two pipeline variations (solid fill and wireframe/line mode).
*   **Vertex / Fragment Shader**: The vertex shader processes geometry, while the fragment shader determines pixel colors.
*   **Viewport**: Defines the region of the render target where the output will be mapped (`SDL_SetGPUViewport`).
*   **Scissor Rectangle**: Defines a clipping rectangle outside of which pixels are discarded (`SDL_SetGPUScissor`).

## BasicVertexBuffer

Demonstrates uploading and using vertex data from the CPU to the GPU.

**Technical details:**
Shows how to create a GPU buffer for vertex data (`SDL_GPU_BUFFERUSAGE_VERTEX`), map a transfer buffer to upload vertex struct data, and then bind it during a render pass with `SDL_BindGPUVertexBuffers` before calling `SDL_DrawGPUPrimitives`.
*   **Vertex Buffer**: A block of GPU memory storing per-vertex attributes (like positions and colors).
*   **Transfer Buffer**: A staging buffer used to upload data from CPU-accessible memory to GPU-local memory.

## WindowResize

Demonstrates handling window resize events with the GPU API.

**Technical details:**
Allows interactively changing the SDL window resolution (`SDL_SetWindowSize`). Shows that `SDL_WaitAndAcquireGPUSwapchainTexture` automatically handles providing a swapchain texture that matches the new window dimensions without explicit swapchain recreation logic.
*   **Swapchain Management**: Modern graphic APIs require recreating the swapchain entirely upon resize; SDL GPU abstracts this complexity automatically.

## CullMode

Provides an interactive comparison of rasterizer cull modes and front-face winding orders.

**Technical details:**
Renders triangles and allows the user to interactively switch the `cull_mode` (None, Front, Back) and `front_face` (Clockwise, Counter-Clockwise) within the `SDL_GPURasterizerState` of the graphics pipeline to visualize how culling affects geometry.
*   **Back-face Culling**: An optimization technique where the GPU discards triangles facing away from the camera, saving fill-rate performance.

## BasicStencil

Demonstrates the use of stencil testing to mask rendering operations.

**Technical details:**
Creates two graphics pipelines: a "masker" pipeline that writes to the stencil buffer, and a "maskee" pipeline that only renders where the stencil buffer has specific values. 
*   **Stencil Buffer**: An additional buffer (often bundled with the depth buffer) used to limit rendering to specific areas of the screen.
*   **SDL_GPUStencilOpState**: Configures how the stencil test compares values and updates the stencil buffer when a test passes or fails.

## TriangleMSAA

Demonstrates rendering with Multisample Anti-Aliasing (MSAA).

**Technical details:**
Creates a render target texture with a multisample count > 1 (`SDL_GPU_SAMPLECOUNT_4`, etc.) and a corresponding pipeline with `multisample_state.sample_count`. Demonstrates how to resolve the multisampled target into a single-sample texture using `store_op = SDL_GPU_STOREOP_RESOLVE` and `resolve_texture`.
*   **Multisample Anti-Aliasing (MSAA)**: A hardware-accelerated technique that smooths jagged polygon edges by calculating coverage across sub-pixels.
*   **Resolve Operation**: The process of blending the multiple sub-samples of an MSAA texture down to a final, presentable 2D image.

## TexturedQuad

Renders a static textured quad and demonstrates various sampler states.

**Technical details:**
Interactively switches between different `SDL_GPUSampler` configurations (PointClamp, PointWrap, LinearClamp, LinearWrap, AnisotropicClamp, AnisotropicWrap) to visually demonstrate their effects on texture filtering and coordinate wrapping.
*   **Sampler State**: Controls how texture pixels (texels) are interpolated when scaled (Point/Nearest vs Linear filtering) and how coordinates outside the [0, 1] range are handled (Clamp vs Wrap/Repeat).
*   **Anisotropic Filtering**: Advanced filtering that maintains texture clarity when viewed at steep angles.

## TexturedAnimatedQuad

Renders a textured quad that animates via uniform matrices.

**Technical details:**
Passes dynamic `Matrix4x4` transform data and color multiplier data as uniforms to the vertex and fragment shaders using `SDL_PushGPUVertexUniformData` and `SDL_PushGPUFragmentUniformData`, causing the quad to spin and pulsate in color.
*   **Uniform Matrices**: Passing transformation data (Translation, Rotation, Scale) to modify geometry positions dynamically per-draw without changing the underlying vertex buffer.

## Texture2DArray

Demonstrates creating and sampling a 2D Array Texture.

**Technical details:**
Creates an `SDL_GPU_TEXTURETYPE_2D_ARRAY` texture with multiple layers, uploads different images to each layer, and uses a fragment shader to sample specific layers based on a layer index.
*   **Array Textures**: Unlike 3D textures which blend between depth slices, array textures are strictly discrete layers of identical size/format, useful for terrain atlases or sprite frames.

## Cubemap

Demonstrates rendering a skybox using a cubemap texture.

**Technical details:**
Loads 6 images into a single `SDL_GPU_TEXTURETYPE_CUBE` texture. Renders an inverted cube around the camera, sampling the cubemap texture in the fragment shader to display a continuous environment.
*   **Skybox Rendering**: Using an inside-out cube with depth testing disabled to create the illusion of a distant, encompassing background.

## Clear3DSlice

Shows how to clear individual slices of a 3D texture independently.

**Technical details:**
Creates a 3D texture and clears each of its 4 slices/depth planes to a different color using separate render passes by specifying `layer_or_depth_plane` in the color target info. It then blits those slices to the screen.
*   **3D Texture (Volume Texture)**: A texture containing volumetric data, functioning like a stack of 2D textures interpolated along the Z-axis.

## CompressedTextures

Demonstrates loading and validating hardware-compressed texture formats.

**Technical details:**
Tests loading textures using various compressed formats (e.g., BC1-7, ASTC) if the device supports them (`SDL_GPUTextureSupportsFormat`). 
*   **Texture Compression**: Specialized formats that stay compressed in GPU memory (VRAM), saving bandwidth and storage compared to traditional PNG/JPEG files which must be uncompressed into raw pixels.

## CustomSampling

Demonstrates custom texture sampling logic within a fragment shader.

**Technical details:**
Instead of using a standard sampler object, this example uses a storage texture in a fragment shader, utilizing `imageStore` (or equivalent) for custom read/write logic, allowing manual pixel coordinate manipulation.

## CopyAndReadback

Demonstrates copying data on the GPU and reading it back to the CPU.

**Technical details:**
Shows how to copy data between GPU textures and buffers, and then download that data back into CPU-accessible transfer buffers using `SDL_DownloadFromGPUTexture` and `SDL_DownloadFromGPUBuffer`. 
*   **Fences**: Synchronization objects (`SDL_GPUFence`) used by the CPU to wait until the GPU has finished specific commands before reading memory back.

## CopyConsistency

Demonstrates copying data to buffers and textures and verifying copy consistency.

**Technical details:**
Ensures that data copied via `SDL_CopyGPUBufferToBuffer` and `SDL_CopyGPUTextureToTexture` matches the expected state, validating that memory transfers are executing correctly within the GPU.

## BlitMirror

Demonstrates texture flipping (horizontal and vertical) during a blit operation.

**Technical details:**
Uploads an image to a texture and uses `SDL_BlitGPUTexture` with different `flip_mode` settings (`SDL_FLIP_NONE`, `SDL_FLIP_HORIZONTAL`, `SDL_FLIP_VERTICAL`) to display mirrored variations of the texture on screen.
*   **Flip Mode**: Hardware-level instruction to invert texture coordinates along an axis during a blit.

## Blit2DArray

Demonstrates how to work with and blit to 2D array textures.

**Technical details:**
Uploads different images into specific layers of a 2D array texture. Then, uses `SDL_BlitGPUTexture` to blit specific layers of the array texture to the screen.
*   **2D Array Texture**: A single texture object containing an array of 2D images, useful for avoiding texture binding changes.
*   **Blitting**: Fast, hardware-accelerated copying of texture data from one region/layer to another.

## BlitCube

Demonstrates rendering to and blitting with cubemap textures.

**Technical details:**
Creates a cubemap texture and renders different colors to each of its 6 faces using multiple render passes. Then uses `SDL_BlitGPUTexture` to copy those faces onto the swapchain for display.
*   **Cubemap**: A texture consisting of 6 square 2D textures representing the faces of a cube, commonly used for skyboxes or environment mapping.

## GenerateMipmaps

Demonstrates hardware-accelerated mipmap generation for a texture.

**Technical details:**
Loads an image and uses `SDL_GenerateMipmapsForGPUTexture` to automatically generate the mipmap chain. It then blits the smallest mip level to the screen to verify it was generated correctly.
*   **Mipmaps**: Progressively smaller versions of a texture (Levels of Detail) used by the GPU to prevent aliasing and improve cache performance when rendering textures at a distance.

## TextureTypeTest

A robust test suite for copying and blitting between various texture types.

**Technical details:**
Tests copying, blitting, and downloading between all combinations of 2D, 2DArray, 3D, Cubemap, and CubemapArray texture types (`SDL_CopyGPUTextureToTexture`, `SDL_BlitGPUTexture`). It validates the correct handling of layers, depth planes, and mip levels across different types.

## InstancedIndexed

Demonstrates rendering multiple instances of indexed geometry.

**Technical details:**
Uses `SDL_DrawGPUIndexedPrimitives` to draw multiple instances of a mesh using both an index buffer and a vertex buffer. Shows how to use vertex and index offsets to draw specific subsections of the buffer data.
*   **Instanced Rendering**: Submitting a single draw call to render many copies of the same geometry, significantly reducing CPU draw call overhead.
*   **Index Buffer**: An array of pointers (indices) to vertex data, preventing duplicate vertices from being processed.

## DrawIndirect

Demonstrates using indirect drawing commands to drive rendering from the GPU.

**Technical details:**
Uses `SDL_DrawGPUPrimitivesIndirect` and `SDL_DrawGPUIndexedPrimitivesIndirect`. The draw arguments (vertex count, instance count, offsets) are sourced directly from GPU buffers (`SDL_GPU_BUFFERUSAGE_INDIRECT`), avoiding the need to read them back to the CPU.
*   **Indirect Rendering**: A technique where the GPU tells itself what to render, enabling features like GPU culling or dynamic LOD without CPU synchronization.

## DepthSampler

Demonstrates a multi-pass technique using depth buffers as textures.

**Technical details:**
Renders a scene into a color target and a depth target. In a subsequent pass, the depth texture is bound as a sampler (`SDL_BindGPUFragmentSamplers`). A shader reads this depth data to perform post-processing, specifically generating a depth-aware outline effect.
*   **Multi-pass Rendering**: Rendering scene data to off-screen textures (G-Buffers or Depth Buffers) and using them as inputs for later rendering stages (Deferred Rendering / Post-Processing).

## Latency

Demonstrates input latency testing and the effect of allowed frames in flight.

**Technical details:**
Draws a colored sprite directly below the cursor to measure input latency. It interactively adjusts `SDL_SetGPUAllowedFramesInFlight` to test how queue depth impacts visual latency and tearing.
*   **Frames in Flight**: How many frames the CPU is allowed to prepare ahead of the GPU. Lower values reduce input lag but can hurt framerate stability.

## PullSpriteBatch

Demonstrates a vertex-pulling workflow for sprite batching.

**Technical details:**
Instead of using traditional vertex buffers, this approach stores sprite instance data (position, rotation, color, UVs) in a storage buffer. The vertex shader determines its vertex ID and "pulls" the relevant instance data directly from the storage buffer to construct the geometry.
*   **Vertex Pulling**: A modern technique bypassing the input assembler (IA), fetching vertex data directly from storage buffers using `gl_VertexIndex`, offering high flexibility.

## BasicCompute

A basic example of a compute-to-graphics workflow.

**Technical details:**
Demonstrates creating a compute pipeline using a compute shader (`ClearColor.comp`) to fill a storage texture with a color, and then rendering that texture using a standard graphics pipeline. 
*   **Compute Pipeline**: A pipeline that runs arbitrary computational tasks rather than rendering geometry.
*   **Storage Texture**: A texture that allows random-access reads and writes from shaders.
*   **SDL_DispatchGPUCompute**: Executes the compute shader across a specified number of thread groups.

## ComputeUniforms

Demonstrates passing uniform data to a compute shader.

**Technical details:**
Passes dynamic uniform data (like time and color multipliers) to a compute shader using `SDL_PushGPUComputeUniformData`. The compute shader generates a dynamic texture pattern based on these uniforms, which is then rendered to the screen.
*   **Uniforms (Push Constants)**: Small amounts of fast, frequently-updated data sent directly to shaders per-draw or per-dispatch.

## ComputeSampler

Demonstrates sampling a texture within a compute shader.

**Technical details:**
Loads a texture and processes it via a compute shader. The compute pipeline binds a sampler and a texture (`SDL_BindGPUComputeSamplers`), reads the pixel data, modifies it, and writes the output to a storage texture (`SDL_BindGPUComputeStorageTextures`) which is subsequently rendered.
*   **Compute Sampler**: Allowing non-graphics shaders to read image data using filtering and addressing modes.

## ComputeSpriteBatch

An advanced example showing a compute-to-graphics workflow for generating geometry data.

**Technical details:**
Uses a compute shader to process sprite position and animation logic, writing the resulting vertex data directly into a GPU storage buffer. The subsequent graphics pass then binds this buffer as a vertex buffer (`SDL_BindGPUVertexBuffers`) to render thousands of sprites without CPU intervention.
*   **GPU-Driven Workflow**: Moving simulation and vertex generation off the CPU, drastically reducing CPU-to-GPU data transfer overhead.

## ToneMapping

Demonstrates post-processing tonemapping using compute shaders and swapchain composition.

**Technical details:**
Processes a floating-point HDR texture using compute shaders to apply different tonemapping operators (Reinhard, Hable, ACES). Interactively changes the swapchain format (`SDL_SetGPUSwapchainParameters`) to test SDR, SDR Linear, HDR Extended Linear, and HDR10 ST2084 outputs.
*   **Tonemapping**: The process of mapping high dynamic range (HDR) lighting values down to the limited range displayable by standard monitors (SDR) while preserving visual details.
*   **Floating-Point Textures**: Textures supporting values far exceeding standard 0.0 - 1.0 limits, used to store realistic brightness values.
