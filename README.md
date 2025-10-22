# WanGP for Runpod Blackwell GPU

-----
<p align="center">
<b>WanGP by DeepBeepMeep : The best Open Source Video Generative Models Accessible to the GPU Poor</b>
</p>

WanGP supports the Wan (and derived models), Hunyuan Video and LTV Video models with:
- Low VRAM requirements (as low as 6 GB of VRAM is sufficient for certain models)
- Support for old Nvidia GPUs (RTX 10XX, 20xx, ...)
- Support for AMD GPUs Radeon RX 76XX, 77XX, 78XX & 79XX, instructions in the Installation Section Below.
- Very Fast on the latest GPUs
- Easy to use Full Web based interface
- Auto download of the required model adapted to your specific architecture
- Tools integrated to facilitate Video Generation : Mask Editor, Prompt Enhancer, Temporal and Spatial Generation, MMAudio, Video Browser, Pose / Depth / Flow extractor
- Loras Support to customize each model
- Queuing system : make your shopping list of videos to generate and come back later

**Discord Server to get Help from Other Users and show your Best Videos:** https://discord.gg/g7efUW9jGV

**Follow DeepBeepMeep on Twitter/X to get the Latest News**: https://x.com/deepbeepmeep

## 🔥 Latest Updates : 
### October 20 2025: WanGP v9.01 - 0.001 Later

What else will you ever need after this one ?

With WanGP v9 you will have enough features to go to a desert island with no internet connection and comes back with a full Hollywood movie.

First here are the new models supported:
- **Wan 2.1 Alpha** : a very requested model that can generate videos with *semi transparent background* (as it is very lora picky it supports only the *Self Forcing / lightning* loras accelerators)
- **Chatterbox Multilingual**: the first *Voice Generator* in WanGP. Let's say you have a flu and lost your voice (somehow I can't think of another usecase), the world will still be able to hear you as *Chatterbox* can generate up to 15s clips of your voice using a recorded voice sample. Chatterbox works with numerous languages out the box.
- **Flux DreamOmni2** : another wannabe *Nano Banana* image Editor / image composer. The *Edit Mode* ("Conditional Image is first Main Subject ...") seems to work better than the *Gen Mode* (Conditional Images are People / Objects ..."). If you have at least 16 GB of VRAM it is recommended to force profile 3 for this model (it uses an autoregressive model for the prompt encoding and the start may be slow).

Upgraded Features:
- A new **Audio Gallery** to store your Chatterbox generations and import your audio assets. *Metadata support* (stored gen settings) for *Wav files* generated with WanGP available from day one. 
- **Matanyone** improvements: you can now use it during a video gen, it will *suspend gracefully the Gen in progress*. *Input Video / Images* can be resized for faster processing & lower VRAM. Image version can now generate *Green screens* (not used by WanGP but I did it because someone asked for it and I am nice) and *Alpha masks*.
- **Images Stored in Metadata**: Video Gen *Settings Metadata* that are stored in the Generated Videos can now contain the Start Image, Image Refs used to generate the Video. Many thanks to **Gunther-Schulz** for this contribution
- **Three Levels of Hierarchy** to browse the models / finetunes: you can collect as many finetunes as you want now and they will no longer encumber the UI.
- Added **Loras Accelerators** for *Wan 2.1 1.3B*, *Wan 2.2 i2v*, *Flux* and the latest *Wan 2.2 Lightning*
- Finetunes now support **Custom Text Encoders** : you will need to use the "text_encoder_URLs" key. Please check the finetunes doc. 
- Sometime Less is More: removed the palingenesis finetunes that were controversial

Huge Kudos & Thanks to **Tophness** that has outdone himself with these Great Features:
- **Multicolors Queue** items with **Drag & Drop** to reorder them
- **Edit a Gen Request** that is already in the queue
- Added **Plugin support** to WanGP : found that features are missing in WanGP, you can now add tabs at the top in WanGP. Each tab may contain a full embedded App that can share data with the Video Generator of WanGP. Please check the Plugin guide written by Tophness and don't hesitate to contact him or me on the Discord if you have a plugin you want to share. I have added a new Plugins channels to discuss idea of plugins and help each other developing plugins. *Idea for a PlugIn that may end up popular*: a screen where you view the hard drive space used per model and that will let you remove unused models weights
- Two Plugins ready to use designed & developped by **Tophness**: an **Extended Gallery** and a **Lora multipliers Wizard**

WanGP v9 is now targetting Pytorch 2.8 although it should still work with 2.7, don't forget to upgrade by doing:
```bash
pip install torch==2.8.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu128
```
You will need to upgrade Sage Attention or Flash (check the installation guide)

## 🔥 Latest Updates : 
### October 6 2025: WanGP v8.999 - A few last things before the Big Unknown ...

This new version hasn't any new model...

...but temptation to upgrade will be high as it contains a few Loras related features that may change your Life:
- **Ready to use Loras Accelerators Profiles** per type of model that you can apply on your current *Generation Settings*. Next time I will recommend a *Lora Accelerator*, it will be only one click away. And best of all of the required Loras will be downloaded automatically. When you apply an *Accelerator Profile*, input fields like the *Number of Denoising Steps* *Activated Loras*, *Loras Multipliers* (such as "1;0 0;1" ...) will be automatically filled. However your video specific fields will be preserved, so it will be easy to switch between Profiles to experiment. With *WanGP 8.993*, the *Accelerator Loras* are now merged with *Non Accelerator Loras". Things are getting too easy...

- **Embedded Loras URL** : WanGP will now try to remember every Lora URLs it sees. For instance if someone sends you some settings that contain Loras URLs or you extract the Settings of Video generated by a friend with Loras URLs, these URLs will be automatically added to *WanGP URL Cache*. Conversely everything you will share (Videos, Settings, Lset files) will contain the download URLs if they are known. You can also download directly a Lora in WanGP by using the *Download Lora* button a the bottom. The Lora will be immediatly available and added to WanGP lora URL cache. This will work with *Hugging Face* as a repository. Support for CivitAi will come as soon as someone will nice enough to post a GitHub PR ...

- **.lset file** supports embedded Loras URLs. It has never been easier to share a Lora with a friend. As a reminder a .lset file can be created directly from *WanGP Web Interface* and it contains a list of Loras and their multipliers, a Prompt and Instructions how to use these loras (like the Lora's *Trigger*). So with embedded Loras URL, you can send an .lset file by email or share it on discord: it is just a 1 KB tiny text, but with it other people will be able to use Gigabytes Loras as these will be automatically downloaded. 

I have created the new Discord Channel **share-your-settings** where you can post your *Settings* or *Lset files*. I will be pleased to add new Loras Accelerators in the list of WanGP *Accelerators Profiles if you post some good ones there. 

*With the 8.993 update*, I have added support for **Scaled FP8 format**. As a sample case, I have created finetunes for the **Wan 2.2 PalinGenesis** Finetune which is quite popular recently. You will find it in 3 flavors : *t2v*, *i2v* and *Lightning Accelerated for t2v*.

The *Scaled FP8 format* is widely used as it the format used by ... *ComfyUI*. So I except a flood of Finetunes in the *share-your-finetune* channel. If not it means this feature was useless and I will remove it &#x1F608;&#x1F608;&#x1F608;

Not enough Space left on your SSD to download more models ? Would like to reuse Scaled FP8 files in your ComfyUI Folder without duplicating them ? Here comes *WanGP 8.994* **Multiple Checkpoints Folders** : you just need to move the files into different folders / hard drives or reuse existing folders and let know WanGP about it in the *Config Tab* and WanGP will be able to put all the parts together.   

Last but not least the Lora's documentation has been updated.

*update 8.991*: full power of *Vace Lynx* unleashed with new combinations such as Landscape + Face / Clothes + Face  / Injectd Frame (Start/End frames/...) + Face
*update 8.992*: optimized gen with Lora, should be 10% faster if many loras
*update 8.993*: Support for *Scaled FP8* format and samples *Paligenesis* finetunes, merged Loras Accelerators and Non Accelerators
*update 8.994*: Added custom checkpoints folders
*update 8.999*: fixed a lora + fp8 bug and version sync for the jump to the unknown 

### September 30 2025: WanGP v8.9 - Combinatorics

This new version of WanGP introduces **Wan 2.1 Lynx** the best Control Net so far to transfer *Facial Identity*. You will be amazed to recognize your friends even with a completely different hair style. Congrats to the *Byte Dance team* for this achievement. Lynx works quite with well *Fusionix t2v* 10 steps.

*WanGP 8.9* also illustrate how existing WanGP features can be easily combined with new models. For instance with *Lynx* you will get out of the box *Video to Video* and *Image/Text to Image*.

Another fun combination is *Vace* + *Lynx*, which works much better than *Vace StandIn*. I have added sliders to change the weight of Vace & Lynx to allow you to tune the effects.


### September 28 2025: WanGP v8.76 - ~~Here Are Two Three New Contenders in the Vace Arena !~~ The Never Ending Release 

So in ~~today's~~ this release you will find two Wannabe Vace that covers each only a subset of Vace features but offers some interesting advantages:
- **Wan 2.2 Animate**: this model is specialized in *Body Motion* and *Facial Motion transfers*. It does that very well. You can use this model to either *Replace* a person in an in Video or *Animate* the person of your choice using an existing *Pose Video* (remember *Animate Anyone* ?). By default it will keep the original soundtrack. *Wan 2.2 Animate* seems to be under the hood a derived i2v model and should support the corresponding Loras Accelerators (for instance *FusioniX t2v*). Also as a WanGP exclusivity, you will find support for *Outpainting*.

In order to use Wan 2.2 Animate you will need first to stop by the *Mat Anyone* embedded tool, to extract the *Video Mask* of the person from which you want to extract the motion.

With version WanGP 8.74, there is an extra option that allows you to apply *Relighting* when Replacing a person. Also, you can now Animate a person without providing a Video Mask to target the source of the motion (with the risk it will be less precise) 

For those of you who have a mask halo effect when Animating a character I recommend trying *SDPA attention* and to use the *FusioniX i2v* lora. If this issue persists (this will depend on the control video) you have now a choice of the two *Animate Mask Options* in *WanGP 8.76*. The old masking option which was a WanGP exclusive has been renamed *See Through Mask* because the background behind the animated character was preserved but this creates sometime visual artifacts. The new option which has the shorter name is what you may find elsewhere online. As it uses internally a much larger mask, there is no halo. However the immediate background behind the character is not preserved and may end completely different.

- **Lucy Edit**: this one claims to be a *Nano Banana* for Videos. Give it a video and asks it to change it (it is specialized in clothes changing) and voila ! The nice thing about it is that is it based on the *Wan 2.2 5B* model and therefore is very fast especially if you the *FastWan* finetune that is also part of the package.

Also because I wanted to spoil you:
- **Qwen Edit Plus**: also known as the *Qwen Edit 25th September Update* which is specialized in combining multiple Objects / People. There is also a new support for *Pose transfer* & *Recolorisation*. All of this made easy to use in WanGP. You will find right now only the quantized version since HF crashes when uploading the unquantized version.

- **T2V Video 2 Video Masking**: ever wanted to apply a Lora, a process (for instance Upsampling) or a Text Prompt on only a (moving) part of a Source Video. Look no further, I have added *Masked Video 2 Video* (which works also in image2image) in the *Text 2 Video* models. As usual you just need to use *Matanyone* to creatre the mask.


*Update 8.71*: fixed Fast Lucy Edit that didnt contain the lora
*Update 8.72*: shadow drop of Qwen Edit Plus
*Update 8.73*: Qwen Preview & InfiniteTalk Start image 
*Update 8.74*: Animate Relighting / Nomask mode , t2v Masked Video to Video  
*Update 8.75*: REDACTED  
*Update 8.76*: Alternate Animate masking that fixes the mask halo effect that some users have    

### September 15 2025: WanGP v8.6 - Attack of the Clones

- The long awaited **Vace for Wan 2.2** is at last here or maybe not: it has been released by the *Fun Team* of *Alibaba* and it is not official. You can play with the vanilla version (**Vace Fun**) or with the one accelerated with Loras (**Vace Fan Cocktail**)

- **First Frame / Last Frame for Vace** : Vace models are so powerful that they could do *First frame / Last frame* since day one using the *Injected Frames* feature. However this required to compute by hand the locations of each end frame since this feature expects frames positions. I made it easier to compute these locations by using the "L" alias :

For a video Gen from scratch *"1 L L L"* means the 4 Injected Frames will be injected like this: frame no 1 at the first position, the next frame at the end of the first window, then the following frame at the end of the next window, and so on ....
If you *Continue a Video* , you just need *"L L L"* since the first frame is the last frame of the *Source Video*. In any case remember that numeral frames positions (like "1") are aligned by default to the beginning of the source window, so low values such as 1 will be considered in the past unless you change this behaviour in *Sliding Window Tab/ Control Video, Injected Frames aligment*.

- **Qwen Edit Inpainting** exists now in two versions: the original version of the previous release and a Lora based version. Each version has its pros and cons. For instance the Lora version supports also **Outpainting** ! However it tends to change slightly the original image even outside the outpainted area.

- **Better Lipsync with all the Audio to Video models**: you probably noticed that *Multitalk*, *InfiniteTalk* or *Hunyuan Avatar* had so so lipsync when the audio provided contained some background music. The problem should be solved now thanks to an automated background music removal all done by IA. Don't worry you will still hear the music as it is added back in the generated Video.

### September 11 2025: WanGP v8.5/8.55 - Wanna be a Cropper or a Painter ?

I have done some intensive internal refactoring of the generation pipeline to ease support of existing models or add new models. Nothing really visible but this makes WanGP is little more future proof.

Otherwise in the news:
- **Cropped Input Image Prompts**: as quite often most *Image Prompts* provided (*Start Image, Input Video, Reference Image,  Control Video, ...*) rarely matched your requested *Output Resolution*. In that case I used the resolution you gave either as a *Pixels Budget* or as an *Outer Canvas* for the Generated Video. However in some occasion you really want the requested Output Resolution and nothing else. Besides some models deliver much better Generations if you stick to one of their supported resolutions. In order to address this need I have added a new Output Resolution choice in the *Configuration Tab*:  **Dimensions Correspond to the Ouput Weight & Height as the Prompt Images will be Cropped to fit Exactly these dimensins**. In short if needed the *Input Prompt Images* will be cropped (centered cropped for the moment). You will see this can make quite a difference for some models

- *Qwen Edit* has now a new sub Tab called **Inpainting**, that lets you target with a brush which part of the *Image Prompt* you want to modify. This is quite convenient if you find that Qwen Edit modifies usually too many things. Of course, as there are more constraints for Qwen Edit don't be surprised if sometime it will return the original image unchanged. A piece of advise: describe in your *Text Prompt* where (for instance *left to the man*, *top*, ...) the parts that you want to modify are located.

The mask inpainting is fully compatible with *Matanyone Mask generator*: generate first an *Image Mask* with Matanyone, transfer it to the current Image Generator and modify the mask with the *Paint Brush*. Talking about matanyone I have fixed a bug that caused a mask degradation with long videos (now WanGP Matanyone is as good as the original app and still requires 3 times less VRAM)

- This **Inpainting Mask Editor** has been added also to *Vace Image Mode*. Vace is probably still one of best Image Editor today. Here is a very simple & efficient workflow that do marvels with Vace:
Select *Vace Cocktail > Control Image Process = Perform Inpainting & Area Processed = Masked Area > Upload a Control Image, then draw your mask directly on top of the image & enter a text Prompt that describes the expected change > Generate > Below the Video Gallery click 'To Control Image' > Keep on doing more changes*.

Doing more sophisticated thing Vace Image Editor works very well too: try Image Outpainting, Pose transfer, ...

For the best quality I recommend to set in *Quality Tab* the option: "*Generate a 9 Frames Long video...*" 

**update 8.55**: Flux Festival
- **Inpainting Mode** also added for *Flux Kontext*
- **Flux SRPO** : new finetune with x3 better quality vs Flux Dev according to its authors. I have also created a *Flux SRPO USO* finetune which is certainly the best open source *Style Transfer* tool available
- **Flux UMO**: model specialized in combining multiple reference objects / people together. Works quite well at 768x768

Good luck with finding your way through all the Flux models names !

### September 5 2025: WanGP v8.4 - Take me to Outer Space
You have probably seen these short AI generated movies created using *Nano Banana* and the *First Frame - Last Frame* feature of *Kling 2.0*. The idea is to generate an image, modify a part of it with Nano Banana and give the these two images to Kling that will generate the Video between these two images, use now the previous Last Frame as the new First Frame, rinse and repeat and you get a full movie.

I have made it easier to do just that with *Qwen Edit* and *Wan*:
- **End Frames can now be combined with Continue a Video** (and not just a Start Frame)
- **Multiple End Frames can be inputed**, each End Frame will be used for a different Sliding Window

You can plan in advance all your shots (one shot = one Sliding Window) : I recommend using Wan 2.2 Image to Image with multiple End Frames (one for each shot / Sliding Window), and a different Text Prompt for each shot / Sliding Winow (remember to enable *Sliding Windows/Text Prompts Will be used for a new Sliding Window of the same Video Generation*)

The results can quite be impressive. However, Wan 2.1 & 2.2 Image 2 Image are restricted to a single overlap frame when using Slide Windows, which means only one frame is reeused for the motion. This may be unsufficient if you are trying to connect two shots with fast movement.

This is where *InfinitTalk* comes into play. Beside being one best models to generate animated audio driven avatars, InfiniteTalk uses internally more one than motion frames. It is quite good to maintain the motions between two shots. I have tweaked InfinitTalk so that **its motion engine can be used even if no audio is provided**.
So here is how to use InfiniteTalk: enable *Sliding Windows/Text Prompts Will be used for a new Sliding Window of the same Video Generation*), and if you continue an existing Video  *Misc/Override Frames per Second" should be set to "Source Video*. Each Reference Frame inputed will play the same role as the End Frame except it wont be exactly an End Frame (it will correspond more to a middle frame, the actual End Frame will differ but will be close)


You will find below a 33s movie I have created using these two methods. Quality could be much better as I havent tuned at all the settings (I couldn't bother, I used 10 steps generation without Loras Accelerators for most of the gens).

### September 2 2025: WanGP v8.31 - At last the pain stops

- This single new feature should give you the strength to face all the potential bugs of this new release:
**Images Management (multiple additions or deletions, reordering) for Start Images / End Images / Images References.**  

- Unofficial **Video to Video (Non Sparse this time) for InfinitTalk**. Use the Strength Noise slider to decide how much motion of the original window you want to keep. I have also *greatly reduced the VRAM requirements for Multitalk / Infinitalk* (especially the multispeakers version & when generating at 1080p). 

- **Experimental Sage 3 Attention support**: you will need to deserve this one, first you need a Blackwell GPU (RTX50xx) and request an access to Sage 3 Github repo, then you will have to compile Sage 3, install it and cross your fingers ...


*update 8.31: one shouldnt talk about bugs if one doesn't want to attract bugs*


See full changelog: **[Changelog](docs/CHANGELOG.md)**

## 📋 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [📦 Installation](#-installation)
- [🎯 Usage](#-usage)
- [📚 Documentation](#-documentation)
- [🔗 Related Projects](#-related-projects)

## 🚀 Quick Start

**One-click installation:** 
- Get started instantly with [Pinokio App](https://pinokio.computer/)
- Use Redtash1 [One Click Install with Sage](https://github.com/Redtash1/Wan2GP-Windows-One-Click-Install-With-Sage)

**Manual installation:**
```bash
git clone https://github.com/t0shigen/Wan2GP.git
cd Wan2GP
conda create -n wan2gp python=3.10.9
conda activate wan2gp
pip install torch==2.8.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu128
pip install -r requirements.txt
```

**Run the application:**
```bash
python wgp.py
```

**Update the application:**
If using Pinokio use Pinokio to update otherwise:
Get in the directory where WanGP is installed and:
```bash
git pull
conda activate wan2gp
pip install -r requirements.txt
```

## 🐳 Docker:

**For Debian-based systems (Ubuntu, Debian, etc.):**

```bash
./run-docker-cuda-deb.sh
```

This automated script will:

- Detect your GPU model and VRAM automatically
- Select optimal CUDA architecture for your GPU
- Install NVIDIA Docker runtime if needed
- Build a Docker image with all dependencies
- Run WanGP with optimal settings for your hardware

**Docker environment includes:**

- NVIDIA CUDA 12.4.1 with cuDNN support
- PyTorch 2.6.0 with CUDA 12.4 support
- SageAttention compiled for your specific GPU architecture
- Optimized environment variables for performance (TF32, threading, etc.)
- Automatic cache directory mounting for faster subsequent runs
- Current directory mounted in container - all downloaded models, loras, generated videos and files are saved locally

**Supported GPUs:** RTX 40XX, RTX 30XX, RTX 20XX, GTX 16XX, GTX 10XX, Tesla V100, A100, H100, and more.

## 📦 Installation

### Nvidia
For detailed installation instructions for different GPU generations:
- **[Installation Guide](docs/INSTALLATION.md)** - Complete setup instructions for RTX 10XX to RTX 50XX

### AMD
For detailed installation instructions for different GPU generations:
- **[Installation Guide](docs/AMD-INSTALLATION.md)** - Complete setup instructions for Radeon RX 76XX, 77XX, 78XX & 79XX

## 🎯 Usage

### Basic Usage
- **[Getting Started Guide](docs/GETTING_STARTED.md)** - First steps and basic usage
- **[Models Overview](docs/MODELS.md)** - Available models and their capabilities

### Advanced Features
- **[Loras Guide](docs/LORAS.md)** - Using and managing Loras for customization
- **[Finetunes](docs/FINETUNES.md)** - Add manually new models to WanGP
- **[VACE ControlNet](docs/VACE.md)** - Advanced video control and manipulation
- **[Command Line Reference](docs/CLI.md)** - All available command line options

## 📚 Documentation

- **[Changelog](docs/CHANGELOG.md)** - Latest updates and version history
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

## 📚 Video Guides
- Nice Video that explain how to use Vace:\
https://www.youtube.com/watch?v=FMo9oN2EAvE
- Another Vace guide:\
https://www.youtube.com/watch?v=T5jNiEhf9xk

## 🔗 Related Projects

### Other Models for the GPU Poor
- **[HuanyuanVideoGP](https://github.com/deepbeepmeep/HunyuanVideoGP)** - One of the best open source Text to Video generators
- **[Hunyuan3D-2GP](https://github.com/deepbeepmeep/Hunyuan3D-2GP)** - Image to 3D and text to 3D tool
- **[FluxFillGP](https://github.com/deepbeepmeep/FluxFillGP)** - Inpainting/outpainting tools based on Flux
- **[Cosmos1GP](https://github.com/deepbeepmeep/Cosmos1GP)** - Text to world generator and image/video to world
- **[OminiControlGP](https://github.com/deepbeepmeep/OminiControlGP)** - Flux-derived application for object transfer
- **[YuE GP](https://github.com/deepbeepmeep/YuEGP)** - Song generator with instruments and singer's voice

---

<p align="center">
Made with ❤️ by DeepBeepMeep
</p>
