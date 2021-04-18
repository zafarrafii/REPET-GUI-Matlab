# REPET-GUI-Matlab

Matlab GUIs to demo the original REPET and REPET-SIM.

Files:
- [`repet_gui`](#repet_gui): Matlab GUI to demo the original REPET.
- [`repetsim_gui`](#repetsim_gui): Matlab GUI to demo REPET-SIM.
- [`audio_file.wav`](#audio_filewav): audio file used for the examples.

See also:
- [REPET-Matlab](https://github.com/zafarrafii/REPET-Matlab): REPET in Matlab for audio source separation.
- [REPET-GUI-Matlab](https://github.com/zafarrafii/REPET-GUI-Matlab): Matlab GUIs to demo the original REPET and REPET-SIM.
- [uREPET-Matlab](https://github.com/zafarrafii/uREPET-Matlab): Matlab GUI for uREPET, a simple user interface system for recovering patterns repeating in time and frequency in mixtures of sounds.

## repet_gui

REPET graphical user interface (GUI).

Functionalities:

- [Open Mixture](#open-mixture)
- [Play/Stop Mixture](#playstop-mixture)
- [Select/Drag](#selectdrag)
- [Zoom](#zoom)
- [Pan](#pan)
- [REPET](#repet)
- [Save Background](#save-background)
- [Play/Stop Background](#playstop-background)
- [Save foreground](#save-foreground)
- [Play/Stop Foreground](#playstop-foreground)

### Open Mixture

- Select a WAVE or MP3 to open; the mixture can be mono or stereo.
- Display the mixture signal and the mixture spectrogram; the x-axis limits of the mixture signal axes and the mixture spectrogram axes will be synchronized (and will stay synchronized if a zoom or pan is applied on any of the axes, including the background and foreground signal and spectrogram axes).

<img src="images/open_mixture.gif" width="1000">

### Play/Stop Mixture

- Play the mixture if the playback is not in progress; stop the mixture if the playback is in progress; a playback line will be displayed as the playback is in progress.
- If there is no selection line or region, the mixture will be played from the start to the end; if there is a selection line, the mixture will be played from the selection line to the end of the mixture; if there is a selection region, the mixture will be played from the start to the end of the selection region.

<img src="images/play_mixture.gif" width="1000">

### Select/Drag

- If a left mouse click is done on any signal axes (mixture, background, or foreground signal axes), a selection line is created; the audio will be played from the selection line to the end of the audio.
- If a left mouse click and drag is done on any signal axes or on a selection line, a selection region is created; the audio will be played from the start to the end of the selection region and REPET will be applied only to the selection region.
- If a left mouse click and drag is done on the left or right boundary of a selection region, the selection region is resized.
- If a right mouse click is done on any signal axes, any selection line or region is removed.

<img src="images/select.gif" width="1000">

### Zoom

- Turn zooming on or off or magnify by factor (see https://mathworks.com/help/matlab/ref/zoom.html)

- If used on a signal axes, zoom horizontally only; the x-axis limits of all the signal axes and all the spectrogram axes will stay synchronized.

<img src="images/zoom.gif" width="1000">

### Pan

- Pan view of graph interactively (see https://www.mathworks.com/help/matlab/ref/pan.html)

- If used on a signal axes, pan horizontally only; the x-axis limits of all the signal axes and all the spectrogram axes will stay synchronized.

<img src="images/pan.gif" width="1000">

### REPET

- Apply the original REPET to the mixture signal or the selected region of the mixture signal if any.
- Compute the beat spectrum and estimate the repeating period, and display them; the repeating period period can be changed by dragging the beat line or by selecting on the beat spectrum axes, which will update the background and foreground estimates.
- Derive the background and foreground estimates from the mixture signal or the selected region of the mixture signal, and display their signals and spectrograms; the select, zoom, and pan tools will work the same way on the background and foreground signal and spectrogram axes.

<img src="images/repet.gif" width="1000">

### Save Background

- Save the background estimate as a WAVE file; the default name is "background_file.wav."

<img src="images/save_background.gif" width="1000">

### Play/Stop Background

- Play or stop the background estimate (see [Play/Stop Mixture](#playstop-mixture)).

<img src="images/play_background.gif" width="1000">

### Save Foreground

- Save the foreground estimate (see [Save Background](#save-background)).

### Play/Stop Foreground

- Play or stop the foreground estimate (see [Play/Stop Mixture](#playstop-mixture)).

## repetsim_gui

REPET-SIM graphical user interface (GUI).

Functionalities:

- [Open Mixture](#open-mixture-1)
- [Play/Stop Mixture](#playstop-mixture-1)
- [Select/Drag](#selectdrag-1)
- [Zoom](#zoom-1)
- [Pan](#pan-1)
- [REPET-SIM](#repet-sim)
- [Save Background](#save-background-1)
- [Play/Stop Background](#playstop-background-1)
- [Save foreground](#save-foreground-1)
- [Play/Stop Foreground](#playstop-foreground-1)

### Open Mixture

- Open the mixture (see [Open Mixture](#open-mixture)).

### Play/Stop Mixture

- Play or stop the mixture (see [Play/Stop Mixture](#playstop-mixture)).

### Select/Drag

- select or drag on a signal or spectogram axes (see [Select/Drag](#selectdrag)).

### Zoom

- Zoom on a signal or spectogram axes (see [Zoom](#zoom)).

### Pan

- Pan on a signal or spectogram axes (see [Pan](#pan)).

### REPET-SIM

- Apply REPET-SIM to the mixture signal or the selected region of the mixture signal if any.
- Compute the self-similarity matrix and display it, and estimate the repeating elements.
- Derive the background and foreground estimates from the mixture signal or the selected region of the mixture signal, and display their signals and spectrograms; the select, zoom, and pan tools will work the same way on the background and foreground signal and spectrogram axes.

<img src="images/repetsim.gif" width="1000">

### Save Background

- Save the background estimate (see [Save Background](#save-background)).

### Play/Stop Background

- Play or stop the background estimate (see [Play/Stop Background](#playstop-background)).

### Save Foreground

- Save the foreground estimate (see [Save Foreground](#save-foreground)).

### Play/Stop Foreground

- Play or stop the foreground estimate (see [Play/Stop Foreground](#playstop-foreground)).


## audio_file.wav

23 second audio excerpt from the song *Que Pena Tanto Faz* performed by *Tamy*.


# References

- Bryan Pardo, Zafar Rafii, and Zhiyao Duan. "Audio Source Separation in a Musical Context," *Handbook of Systematic Musicology*, Springer, Berlin, Heidelberg, 2018. [[article](http://zafarrafii.com/Documents/Other/Pardo-Rafii-Duan%20-%20Audio%20Source%20Separation%20in%20a%20Musical%20Context%20-%202018.pdf)]

- Zafar Rafii, Antoine Liutkus, and Bryan Pardo. "REPET for Background/Foreground Separation in Audio," *Blind Source Separation*, Springer, Berlin, Heidelberg, 2014. [[article](http://zafarrafii.com/Documents/Other/Rafii-Liutkus-Pardo%20-%20REPET%20for%20Background-Foreground%20Separation%20in%20Audio%20-%202014.pdf)]

- Zafar Rafii and Bryan Pardo. "Audio Separation System and Method," 13612413, March 2013. [[URL](http://www.freepatentsonline.com/y2013/0064379.html)]

- Zafar Rafii and Bryan Pardo. "REpeating Pattern Extraction Technique (REPET): A Simple Method for Music/Voice Separation," *IEEE Transactions on Audio, Speech, and Language Processing*, vol. 21, no. 1, January 2013. [[article](http://zafarrafii.com/Documents/Journals/Rafii-Pardo%20-%20REpeating%20Pattern%20Extraction%20Technique%20(REPET)%20A%20Simple%20Method%20for%20Music-Voice%20Separation%20-%202013.pdf)]

- Zafar Rafii and Bryan Pardo. "Music/Voice Separation using the Similarity Matrix," *13th International Society on Music Information Retrieval*, Porto, Portugal, October 8-12, 2012. [[article](http://zafarrafii.com/Documents/Conferences/Rafii-Pardo%20-%20Music-Voice%20Separation%20using%20the%20Similarity%20Matrix%20-%202012.pdf)][[slides](http://zafarrafii.com/Documents/Conferences/Rafii-Pardo%20-%20Music-Voice%20Separation%20using%20the%20Similarity%20Matrix%20-%202012%20(slides).pdf)]

- Zafar Rafii and Bryan Pardo. "A Simple Music/Voice Separation Method based on the Extraction of the Repeating Musical Structure," *36th IEEE International Conference on Acoustics, Speech and Signal Processing*, Prague, Czech Republic, May 22-27, 2011. [[article](http://zafarrafii.com/Documents/Conferences/Rafii-Pardo%20-%20A%20Simple%20Music-Voice%20Separation%20Method%20based%20on%20the%20Extraction%20of%20the%20Repeating%20Musical%20Structure%20-%202011.pdf)][[poster](http://zafarrafii.com/Documents/Conferences/Rafii-Pardo%20-%20A%20Simple%20Music-Voice%20Separation%20Method%20based%20on%20the%20Extraction%20of%20the%20Repeating%20Musical%20Structure%20-%202011%20(poster).pdf)]


# Author

- Zafar Rafii
- zafarrafii@gmail.com
- http://zafarrafii.com/
- [CV](http://zafarrafii.com/Zafar%20Rafii%20-%20C.V..pdf)
- [GitHub](https://github.com/zafarrafii)
- [LinkedIn](https://www.linkedin.com/in/zafarrafii/)
- [Google Scholar](https://scholar.google.com/citations?user=8wbS2EsAAAAJ&hl=en)
