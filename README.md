# mpv-osc-orange

This is a mpv osc script using my [oscf](https://github.com/maoiscat/mpv-osc-framework) tool.

![preview](https://github.com/maoiscat/mpv-osc-orange/blob/main/preview.png)

## Usage

1. Make a new folder in ''\~\~/scripts''. Let's take ''\~\~/scripts/orange'' for example.

2. Download all lua files and put them into that folder.

3. Remove/Disable other osc scripts.

4. Launch mpv and check if it works.

## Other stuff

1. More details about oscf can be found [here](https://github.com/maoiscat/mpv-osc-framework/)

2. You may encounter dark bars on both sides of the video. This is because neither I nor the mpv find a way to adjust the window on the fly.

3. The maximize button in the title bar is actually ''toggle fullscreen''

4. If anyone feels the osc too small, open ''main.lua'' with any text editor, locate the ''user options'' comment, and change **scale** below.
