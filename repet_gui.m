function repet_gui
% REPET_GUI REpeating Pattern Extraction Technique (REPET) graphical user interface (GUI).
%
%   Toolbar:
%       Open Mixture:                   Open mixture file (as .wav or .mp3)
%       Play Mixture:                   Play/stop selected mixture audio
%       Select:                         Select/deselect on signal axes (left/right mouse click)
%       Zoom:                           Zoom on any axes
%       Pan:                            Pan on any axes
%       REPET:                          Process selected mixture using REPET
%       Save Background:                Save background estimate of selected mixture (as .wav)
%       Play Background:                Play/stop background audio of selected mixture
%       Save Foreground:                Save foreground estimate of selected mixture (as .wav)
%       Play Foreground:                Play/stop foreground audio of selected mixture
%   Mixture axes:
%       Mixture signal axes:            Display mixture signal
%       Mixture spectrogram axes:       Display mixture spectrogram
%       Beat spectrum axes:             Display beat spectrum of selected mixture
%   Background and foreground axes:
%       Background signal axes:         Display background signal of selected mixture
%       Background spectrogram axes:    Display background spectrogram of selected mixture
%       Foreground signal axes:         Display foreground signal of selected mixture
%       Foreground spectrogram axes:    Display foreground spectrogram of selected mixture
%
%   See also http://zafarrafii.com/#REPET
%
%   References:
%       Zafar Rafii, Antoine Liutkus, and Bryan Pardo. "REPET for
%       Background/Foreground Separation in Audio," Blind Source
%       Separation, chapter 14, pages 395-411, Springer Berlin Heidelberg,
%       2014.
%
%       Zafar Rafii and Bryan Pardo. "Audio Separation System and Method,"
%       US 20130064379 A1, March 2013.
%
%       Zafar Rafii and Bryan Pardo. "REpeating Pattern Extraction
%       Technique (REPET): A Simple Method for Music/Voice Separation,"
%       IEEE Transactions on Audio, Speech, and Language Processing, volume
%       21, number 1, pages 71-82, January, 2013.
%
%       Zafar Rafii and Bryan Pardo. "A Simple Music/Voice Separation
%       Method based on the Extraction of the Repeating Musical Structure,"
%       36th International Conference on Acoustics, Speech and Signal
%       Processing, Prague, Czech Republic, May 22-27, 2011.
%
%   Author:
%       Zafar Rafii
%       zafarrafii@gmail.com
%       http://zafarrafii.com
%       https://github.com/zafarrafii
%       https://www.linkedin.com/in/zafarrafii/
%       10/23/18

% Get screen size
screen_size = get(0,'ScreenSize');

% Create the figure window
figure_object = figure( ...
    'Visible','off', ...
    'Position',[screen_size(3:4)/4+1,screen_size(3:4)/2], ...
    'Name','REPET GUI', ...
    'NumberTitle','off', ...
    'MenuBar','none', ...
    'CloseRequestFcn',@figurecloserequestfcn);

% Create a toolbar on figure
toolbar_object = uitoolbar(figure_object);

% Play and stop icons for the play audio buttons
play_icon = playicon;
stop_icon = stopicon;

% Create the open and play push buttons on toolbar
openmixture_button = uipushtool(toolbar_object, ...
    'CData',iconread('file_open.png'), ...
    'TooltipString','Open Mixture', ...
    'Enable','on', ...
    'ClickedCallback',@openmixtureclickedcallback); %#ok<*NASGU>
playmixture_button = uipushtool(toolbar_object, ...
    'CData',play_icon, ...
    'TooltipString','Play Mixture', ...
    'Enable','off', ...
    'UserData',struct('PlayIcon',play_icon,'StopIcon',stop_icon));

% Create the pointer, zoom, and hand toggle buttons on toolbar
select_button = uitoggletool(toolbar_object, ...
    'Separator','On', ...
    'CData',iconread('tool_pointer.png'), ...
    'TooltipString','Select', ...
    'Enable','off', ...
    'ClickedCallBack',@selectclickedcallback);
zoom_button = uitoggletool(toolbar_object, ...
    'CData',iconread('tool_zoom_in.png'), ...
    'TooltipString','Zoom', ...
    'Enable','off',...
    'ClickedCallBack',@zoomclickedcallback);
pan_button = uitoggletool(toolbar_object, ...
    'CData',iconread('tool_hand.png'), ...
    'TooltipString','Pan', ...
    'Enable','off',...
    'ClickedCallBack',@panclickedcallback);

% Create the REPET push button on toolbar
repet_button = uipushtool(toolbar_object, ...
    'Separator','On', ...
    'CData',repeticon, ...
    'TooltipString','REPET', ...
    'Enable','off');

% Create save and play background and foreground push buttons on toolbar
savebackground_button = uipushtool(toolbar_object, ...
    'Separator','On', ...
    'CData',iconread('file_save.png'), ...
    'TooltipString','Save Background', ...
    'Enable','off');
playbackground_button = uipushtool(toolbar_object, ...
    'CData',play_icon, ...
    'TooltipString','Play Background', ...
    'Enable','off', ...
    'UserData',struct('PlayIcon',play_icon,'StopIcon',stop_icon));
saveforeground_button = uipushtool(toolbar_object, ...
    'Separator','On', ...
    'CData',iconread('file_save.png'), ...
    'Tooltip','Save Foreground', ...
    'Enable','off');
playforeground_button = uipushtool(toolbar_object, ...
    'CData',play_icon, ...
    'Tooltip','Play Foreground', ...
    'Enable','off', ...
    'UserData',struct('PlayIcon',play_icon,'StopIcon',stop_icon));

% Create the mixture signal and spectrogram axes, and the beat spectrum
% axes
mixturesignal_axes = axes( ...
    'OuterPosition',[0,0.9,0.5,0.1], ...
    'Visible','off');
mixturespectrogram_axes = axes( ...
    'OuterPosition',[0,0.5,0.5,0.4], ...
    'Visible','off');
beatspectrum_axes = axes( ...
    'OuterPosition',[0,0.2,0.5,0.2], ...
    'Visible','off');

% Create the background and foreground signal and spectrogram axes
backgroundsignal_axes = axes( ...
    'OuterPosition',[0.5,0.9,0.5,0.1], ...
    'Visible','off');
backgroundspectrogram_axes = axes( ...
    'OuterPosition',[0.5,0.5,0.5,0.4], ...
    'Visible','off');
foregroundsignal_axes = axes( ...
    'OuterPosition',[0.5,0.4,0.5,0.1], ...
    'Visible','off');
foregroundspectrogram_axes = axes( ...
    'OuterPosition',[0.5,0,0.5,0.4], ...
    'Visible','off');

% Synchronize the x-axis limits of all the axes but the beat spectrum axes
% and both the x-axis and y-axis limits of the spectrogram axes
linkaxes([mixturesignal_axes,mixturespectrogram_axes,...
    backgroundsignal_axes,backgroundspectrogram_axes, ...
    foregroundsignal_axes,foregroundspectrogram_axes],'x')
linkaxes([mixturespectrogram_axes,backgroundspectrogram_axes, ...
    foregroundspectrogram_axes],'xy')

% Change the pointer when the mouse moves over an audio signal or the beat
% spectrum axes
enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','ibeam');
iptSetPointerBehavior(mixturesignal_axes,enterFcn);
iptSetPointerBehavior(beatspectrum_axes,enterFcn);
iptSetPointerBehavior(backgroundsignal_axes,enterFcn);
iptSetPointerBehavior(foregroundsignal_axes,enterFcn);
iptPointerManager(figure_object);

% Change the pointer when the mouse moves over the figure object and the 
% spectrogram axes
enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','arrow');
iptSetPointerBehavior(figure_object,enterFcn)
iptSetPointerBehavior(mixturespectrogram_axes,enterFcn)
iptPointerManager(figure_object);

% Initialize the audio players for the mixture, background, and foreground
% (for the figure's close request callback)
mixture_player = audioplayer(0,80);
background_player = audioplayer(0,80);
foreground_player = audioplayer(0,80);

% Make the figure visible
figure_object.Visible = 'on';

    % Clicked callback function for the open mixture toggle button
    function openmixtureclickedcallback(~,~)
        
        % Open file selection dialog box; return if cancel
        [mixture_name,mixture_path] = uigetfile({'*.wav';'*.mp3'}, ...
            'Select WAVE or MP3 File to Open');
        if isequal(mixture_name,0) || isequal(mixture_path,0)
            return
        end
        
        % Remove the figure's close request callback so that it allows all 
        % the other objects to get created before it can get closed
        figure_object.CloseRequestFcn = '';
        
        % Change the pointer symbol while the figure is busy
        figure_object.Pointer = 'watch';
        drawnow
        
        % If any audio is playing, stop it
        if isplaying(mixture_player)
            stop(mixture_player)
        end
        if isplaying(background_player)
            stop(background_player)
        end
        if isplaying(foreground_player)
            stop(foreground_player)
        end
        
        % Clear all the (old) axes and hide them
        cla(mixturesignal_axes)
        mixturesignal_axes.Visible = 'off';
        cla(mixturespectrogram_axes)
        mixturespectrogram_axes.Visible = 'off';
        cla(beatspectrum_axes)
        beatspectrum_axes.Visible = 'off';
        cla(backgroundsignal_axes)
        backgroundsignal_axes.Visible = 'off';
        cla(backgroundspectrogram_axes)
        backgroundspectrogram_axes.Visible = 'off';
        cla(foregroundsignal_axes)
        foregroundsignal_axes.Visible = 'off';
        cla(foregroundspectrogram_axes)
        foregroundspectrogram_axes.Visible = 'off';
        drawnow
        
        % Build full file name
        mixture_file = fullfile(mixture_path,mixture_name);
        
        % Read mixture file and return sample rate in Hz
        [mixture_signal,sample_rate] = audioread(mixture_file);
        
        % Number of samples and channels
        [number_samples,number_channels] = size(mixture_signal);
        
        % Plot the mixture signal and make it unable to capture mouse
        % clicks
        plot(mixturesignal_axes, ...
            1/sample_rate:1/sample_rate:number_samples/sample_rate, ...
            mixture_signal, ...
            'PickableParts','none');
        
        % Update the mixture signal axes properties
        mixturesignal_axes.XLim = [1,number_samples]/sample_rate;
        mixturesignal_axes.YLim = [-1,1];
        mixturesignal_axes.XGrid = 'on';
        mixturesignal_axes.Title.String = mixture_name;
        mixturesignal_axes.Title.Interpreter = 'None';
        mixturesignal_axes.XLabel.String = 'Time (s)';
        mixturesignal_axes.Layer = 'top';
        mixturesignal_axes.UserData.PlotXLim = [1,number_samples]/sample_rate;
        mixturesignal_axes.UserData.SelectXLim = [1,number_samples]/sample_rate;
        drawnow
        
        % Window length in samples (audio stationary around 40 ms and power
        % of 2 for fast FFT and constant overlap-add)
        window_length = 2.^nextpow2(0.04*sample_rate);
        
        % Window function ('periodic' Hamming window for constant
        % overlap-add)
        window_function = hamming(window_length,'periodic');
        
        % Step length (half the (even) window length for constant
        % overlap-add)
        step_length = window_length/2;
        
        % Number of time frames
        number_times = ceil((window_length-step_length+number_samples)/step_length);
        
        % Short-time Fourier transform (STFT) for every channel
        mixture_stft = zeros(window_length,number_times,number_channels);
        for channel_index = 1:number_channels
            mixture_stft(:,:,channel_index) ...
                = stft(mixture_signal(:,channel_index),window_function,step_length);
        end
        
        % Magnitude spectrogram (with DC component and without mirrored
        % frequencies)
        mixture_spectrogram = abs(mixture_stft(1:window_length/2+1,:,:));
        
        % Functions to convert time from seconds to frames and from frames
        % to seconds
        sec2tim = @(x) round(x*sample_rate/number_samples*number_times);
        tim2sec = @(x) x/number_times*number_samples/sample_rate;
        
        % Display the mixture spectrogram (in dB, averaged over the
        % channels)
        imagesc(mixturespectrogram_axes, ...
            tim2sec([1,number_times]), ...
            [1,window_length/2]/window_length*sample_rate, ...
            db(mean(mixture_spectrogram(2:end,:),3)))
        
        % Update the mixture spectrogram axes properties
        mixturespectrogram_axes.XLim = [1,number_samples]/sample_rate;
        mixturespectrogram_axes.YDir = 'normal';
        mixturespectrogram_axes.XGrid = 'on';
        mixturespectrogram_axes.Colormap = jet;
        mixturespectrogram_axes.Title.String = 'Audio Spectrogram';
        mixturespectrogram_axes.XLabel.String = 'Time (s)';
        mixturespectrogram_axes.YLabel.String = 'Frequency (Hz)';
        drawnow
        
        % Create object for playing audio for the mixture signal
        mixture_player = audioplayer(mixture_signal,sample_rate);
        
        % Set a select line and a play line on the mixture signal axes
        selectline(mixturesignal_axes)
        playline(mixturesignal_axes,mixture_player,playmixture_button);
        
        % Add clicked callback function to the play mixture button
        playmixture_button.ClickedCallback = {@playaudioclickedcallback,mixture_player,mixturesignal_axes};
        
        % Add clicked callback function to the REPET button
        repet_button.ClickedCallback = @repetclickedcallback;
        
        % Enable the play mixture, select, zoom, pan, and REPET buttons
        playmixture_button.Enable = 'on';
        select_button.Enable = 'on';
        zoom_button.Enable = 'on';
        pan_button.Enable = 'on';
        repet_button.Enable = 'on';
        
        % Change the select button state to on
        select_button.State = 'on';
        
        % Add the figure's close request callback back
        figure_object.CloseRequestFcn = @figurecloserequestfcn;
        
        % Change the pointer symbol back
        figure_object.Pointer = 'arrow';
        drawnow
        
        % Clicked callback function for the REPET button
        function repetclickedcallback(~,~)
            
            % Remove the figure's close request callback so that it allows
            % all the other objects to get created before it can get closed
            figure_object.CloseRequestFcn = '';
            
            % Change the pointer symbol while the figure is busy
            figure_object.Pointer = 'watch';
            drawnow
            
            % Select limits from the mixture signal axes' user data
            select_limits = mixturesignal_axes.UserData.SelectXLim;
            
            % Derive the sample range
            if select_limits(1) == select_limits(2)
                % If it is a select line
                sample_range = [1,number_samples];
            else
                % If it is a select region
                sample_range = round(select_limits*sample_rate);
            end
            
            % Translate to a time range in time frames
            time_range = ceil(sample_range/number_samples*number_times);
            
            % Beat spectrum of the spectrogram averaged over the channels
            % (squared to emphasize peaks of periodicitiy)
            beat_spectrum = beatspectrum(mean(mixture_spectrogram(:,time_range(1):time_range(2)),3).^2);
            
            % Normalize the beat spectrum by lag 0
            beat_spectrum = beat_spectrum/beat_spectrum(1);
            
            % Number of lags in time frames (including lag 0)
            number_lags = length(beat_spectrum);
            
            % Beat limits for the repeating period on the beat spectrum in
            % seconds
            beat_limits = tim2sec([1,floor(number_lags/3)]);
            
            % Period range in seconds for the beat spectrum
            period_range = [1,10];
            
            % Repeating period in time frames given the period range
            repeating_period = repeatingperiod(beat_spectrum,sec2tim(period_range));
            
            % Plot the beat spectrum and make it unable to capture mouse
            % clicks
            plot(beatspectrum_axes, ...
                (0:tim2sec(1):tim2sec(number_lags-1)),beat_spectrum,'k','PickableParts','none')
            
            % Update the beat spectrum axes properties
            beatspectrum_axes.XLim = [0,tim2sec(number_lags-1)];
            beatspectrum_axes.YLim = [0,1];
            beatspectrum_axes.XGrid = 'on';
            beatspectrum_axes.XMinorGrid = 'on';
            beatspectrum_axes.Title.String = ['Beat Spectrum: repeating period = ', ...
                num2str(round(tim2sec(repeating_period),3)),' seconds'];
            beatspectrum_axes.XLabel.String = 'Lag (s)';
            drawnow
            
            % Initialize the beat lines as an array for graphic objects
            number_lines = floor((number_lags-1)/repeating_period);
            beat_lines = gobjects(number_lines,1);
            
            % Create the main beat line and the other dotted lines on the
            % beat spectrum axes
            beat_lines(1) = line(beatspectrum_axes, ...
                tim2sec(repeating_period)*[1,1],[-1,1], ...
                'Color','r');
            for line_index = 2:number_lines
                beat_lines(line_index) = line(beatspectrum_axes, ...
                    tim2sec(repeating_period)*line_index*[1,1],[-1,1], ...
                    'Color','r', ...
                    'LineStyle',':', ...
                    'PickableParts','none');
            end
            
            % Change the pointer when the mouse moves over the main beat
            % line
            enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','hand');
            iptSetPointerBehavior(beat_lines(1),enterFcn);
            iptPointerManager(figure_object);
            
            % Add mouse-click callback functions to the beat spectrum axes
            % and the main beat line
            beatspectrum_axes.ButtonDownFcn = @beatspectrumaxesbuttondownfcn;
            beat_lines(1).ButtonDownFcn = @beatlinebuttondownfcn;
            
            % Cutoff frequency in Hz for the high-pass filtering of the
            % foreground
            cutoff_frequency = 100;
            
            % Cutoff frequency in frequency channels
            cutoff_frequency = round(cutoff_frequency*window_length/sample_rate);
            
            % Initialize the background and foreground STFTs and signals
            background_stft = zeros(window_length,time_range(2)-time_range(1)+1,number_channels);
            background_signal = zeros(sample_range(2)-sample_range(1)+1,number_channels);
            foreground_stft = zeros(window_length,time_range(2)-time_range(1)+1,number_channels);
            foreground_signal = zeros(sample_range(2)-sample_range(1)+1,number_channels);
            
            % Run REPET given the repeating period in time frames
            repet(repeating_period)
            
            % Add clicked callback functions for the save background and
            % foreground buttons
            savebackground_button.ClickedCallback = @savebackgroundclickedcallback;
            saveforeground_button.ClickedCallback = @saveforegroundclickedcallback;
            
            % Enable the save and play background and foreground buttons
            savebackground_button.Enable = 'on';
            playbackground_button.Enable = 'on';
            saveforeground_button.Enable = 'on';
            playforeground_button.Enable = 'on';
            
            % Add the figure's close request callback back
            figure_object.CloseRequestFcn = @figurecloserequestfcn;
            
            % Change the pointer symbol back
            figure_object.Pointer = 'arrow';
            drawnow
            
            % Mouse-click callback function for the beat spectrum axes
            function beatspectrumaxesbuttondownfcn(~,~)
                
                % Mouse selection type
                selection_type = figure_object.SelectionType;
                
                % If not click left mouse button, return
                if ~strcmp(selection_type,'normal')
                    return
                end
                
                % Location of the mouse pointer
                current_point = beatspectrum_axes.CurrentPoint;
                
                % If the current point is out of the beat limits, return
                if current_point(1,1) < beat_limits(1) || current_point(1,1) > beat_limits(2) || ...
                        current_point(1,2) < -1 || current_point(1,2) > 1
                    return
                end

                % Change the pointer when the mouse moves over the beat
                % spectrum axes
                enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','hand');
                iptSetPointerBehavior(beatspectrum_axes,enterFcn);
                iptPointerManager(figure_object);
                
                % Update the main beat line and re-create the dotted lines
                beat_lines(1).XData = current_point(1,1)*[1,1];
                delete(beat_lines(2:end))
                number_lines = floor(tim2sec(number_lags-1)/current_point(1,1));
                beat_lines = [beat_lines(1);gobjects(number_lines-1,1)];
                for line_index = 2:number_lines %#ok<*FXUP>
                    beat_lines(line_index) = line(beatspectrum_axes, ...
                        current_point(1,1)*line_index*[1,1],[-1,1], ...
                        'Color','r', ...
                        'LineStyle',':', ...
                        'PickableParts','none');
                end
                
                % Update the repeating period in the beat spectrum title
                beatspectrum_axes.Title.String = ['Beat Spectrum: repeating period = ', ...
                    num2str(round(current_point(1,1),3)),' seconds'];
                
                % Add window button motion and up callback functions to the
                % figure
                figure_object.WindowButtonMotionFcn = @figurewindowbuttonmotionfcn;
                figure_object.WindowButtonUpFcn = @figurewindowbuttonupfcn;
                
                % Run REPET again given the current point in time frames
                repet(sec2tim(current_point(1,1)))
                
            end
            
            % Mouse-click callback function for the main beat line
            function beatlinebuttondownfcn(~,~)
                
                % Mouse selection type
                selection_type = figure_object.SelectionType;
                
                % If not click left mouse button, return
                if ~strcmp(selection_type,'normal')
                    return
                end
                
                % Change the pointer when the mouse moves over the beat
                % spectrum axes and the figure object
                enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','hand');
                iptSetPointerBehavior(beatspectrum_axes,enterFcn);
                iptSetPointerBehavior(figure_object,enterFcn);
                iptPointerManager(figure_object);
                
                % Add window button motion and up callback functions to the
                % figure
                figure_object.WindowButtonMotionFcn = @figurewindowbuttonmotionfcn;
                figure_object.WindowButtonUpFcn = @figurewindowbuttonupfcn;
                
            end
            
            % Window button motion callback function for the figure
            function figurewindowbuttonmotionfcn(~,~)
                
                % Location of the mouse pointer
                current_point = beatspectrum_axes.CurrentPoint;
                
                % If the current point is out of the beat limits, change it
                % into the beat limits
                if current_point(1,1) < beat_limits(1)
                    current_point(1,1) = beat_limits(1);
                elseif current_point(1,1) > beat_limits(2)
                    current_point(1,1) = beat_limits(2);
                end
                
                % Update the main beat line and re-create the dotted lines
                beat_lines(1).XData = current_point(1,1)*[1,1];
                delete(beat_lines(2:end))
                number_lines = floor(tim2sec(number_lags-1)/current_point(1,1));
                beat_lines = [beat_lines(1);gobjects(number_lines-1,1)];
                for line_index = 2:number_lines %#ok<*FXUP>
                    beat_lines(line_index) = line(beatspectrum_axes, ...
                        current_point(1,1)*line_index*[1,1],[-1,1], ...
                        'Color','r', ...
                        'LineStyle',':', ...
                        'PickableParts','none');
                end
                
                % Update repeating period in the beat spectrum title
                beatspectrum_axes.Title.String = ['Beat Spectrum: repeating period = ', ...
                    num2str(round(current_point(1,1),3)),' seconds'];
                
            end
            
            % Window button up callback function for the figure
            function figurewindowbuttonupfcn(~,~)
                
                % Change the pointer when the mouse moves over the beat
                % spectrum axes and the figure object
                enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','ibeam');
                iptSetPointerBehavior(beatspectrum_axes,enterFcn);
                iptPointerManager(figure_object);
                enterFcn = @(figure_handle,currentPoint) set(figure_handle,'Pointer','arrow');
                iptSetPointerBehavior(figure_object,enterFcn);
                iptPointerManager(figure_object);
                
                % Remove the window button motion and up callback functions
                % of the figure
                figure_object.WindowButtonMotionFcn = '';
                figure_object.WindowButtonUpFcn = '';
                
                % Repeating period in seconds from the main beat line
                repeat_period = beat_lines(1).XData(1);
                
                % Run REPET again given the current point in time frames
                repet(sec2tim(repeat_period))
                
            end
            
            % REPET function given a repeating period in time frames
            function repet(repeating_period)
                
                % Loop over the channels
                for channel_index = 1:number_channels
                    
                    % Repeating mask for the current channel
                    repeating_mask ...
                        = repeatingmask(mixture_spectrogram(:,time_range(1):time_range(2),channel_index),repeating_period);
                    
                    % High-pass filtering of the foreground
                    repeating_mask(2:cutoff_frequency+1,:) = 1;
                    
                    % Mirror the frequency channels
                    repeating_mask = cat(1,repeating_mask,repeating_mask(end-1:-1:2,:));
                    
                    % Estimated background STFT for the current channel
                    background_stft(:,:,channel_index) ...
                        = repeating_mask.*mixture_stft(:,time_range(1):time_range(2),channel_index);
                    
                    % Estimated background signal
                    background_signal1 = istft(background_stft(:,:,channel_index),window_function,step_length);
                    
                    % Truncate to the true number of samples
                    background_signal(:,channel_index) ...
                        = background_signal1(1:sample_range(2)-sample_range(1)+1);
                    
                end
                
                % Plot the background signal and make it unable to capture
                % mouse clicks
                plot(backgroundsignal_axes, ...
                    sample_range(1)/sample_rate:1/sample_rate:sample_range(2)/sample_rate,background_signal, ...
                    'PickableParts','none');
                
                % Update the background signal axes properties
                backgroundsignal_axes.XLim = [1,number_samples]/sample_rate;
                backgroundsignal_axes.YLim = [-1,1];
                backgroundsignal_axes.XGrid = 'on';
                backgroundsignal_axes.Title.String = 'Background Signal';
                backgroundsignal_axes.XLabel.String = 'Time (s)';
                backgroundsignal_axes.Layer = 'top';
                backgroundsignal_axes.UserData.PlotXLim = select_limits;
                backgroundsignal_axes.UserData.SelectXLim = select_limits;
                drawnow
                
                % Display the background spectrogram (in dB, averaged over
                % the channels)
                imagesc(backgroundspectrogram_axes, ...
                    tim2sec([time_range(1),time_range(2)]), ...
                    [1,window_length/2]/window_length*sample_rate, ...
                    db(mean(abs(background_stft(2:window_length/2+1,:,:)),3)))
                
                % Update the background spectrogram axes properties
                backgroundspectrogram_axes.XLim = [1,number_samples]/sample_rate;
                backgroundspectrogram_axes.YDir = 'normal';
                backgroundspectrogram_axes.XGrid = 'on';
                backgroundspectrogram_axes.Colormap = jet;
                backgroundspectrogram_axes.CLim = mixturespectrogram_axes.CLim;
                backgroundspectrogram_axes.Title.String = 'Background Spectrogram';
                backgroundspectrogram_axes.XLabel.String = 'Time (s)';
                backgroundspectrogram_axes.YLabel.String = 'Frequency (Hz)';
                drawnow
                
                % Corresponding foreground signal and STFT
                foreground_signal = mixture_signal(sample_range(1):sample_range(2),:)-background_signal;
                foreground_stft = mixture_stft(:,time_range(1):time_range(2),:)-background_stft;
                
                % Plot the foreground signal and make it unable to capture
                % mouse clicks
                plot(foregroundsignal_axes, ...
                    sample_range(1)/sample_rate:1/sample_rate:sample_range(2)/sample_rate,foreground_signal, ...
                    'PickableParts','none');
                
                % Update the foreground signal axes properties
                foregroundsignal_axes.XLim = [1,number_samples]/sample_rate;
                foregroundsignal_axes.YLim = [-1,1];
                foregroundsignal_axes.XGrid = 'on';
                foregroundsignal_axes.Title.String = 'Foreground Signal';
                foregroundsignal_axes.XLabel.String = 'Time (s)';
                foregroundsignal_axes.Layer = 'top';
                foregroundsignal_axes.UserData.PlotXLim = select_limits;
                foregroundsignal_axes.UserData.SelectXLim = select_limits;
                drawnow
                
                % Display the foreground spectrogram (in dB, averaged over
                % the channels)
                imagesc(foregroundspectrogram_axes, ...
                    tim2sec([time_range(1),time_range(2)]), ...
                    [1,window_length/2]/window_length*sample_rate, ...
                    db(mean(abs(foreground_stft(2:window_length/2+1,:,:)),3)))
                
                % Update the foreground spectrogram axes properties
                foregroundspectrogram_axes.XLim = [1,number_samples]/sample_rate;
                foregroundspectrogram_axes.YDir = 'normal';
                foregroundspectrogram_axes.XGrid = 'on';
                foregroundspectrogram_axes.Colormap = jet;
                foregroundspectrogram_axes.CLim = mixturespectrogram_axes.CLim;
                foregroundspectrogram_axes.Title.String = 'Foreground Spectrogram';
                foregroundspectrogram_axes.XLabel.String = 'Time (s)';
                foregroundspectrogram_axes.YLabel.String = 'Frequency (Hz)';
                drawnow
                
                % Create objects for playing audio for the background and
                % foreground signals
                background_player = audioplayer(background_signal,sample_rate);
                foreground_player = audioplayer(foreground_signal,sample_rate);
                
                % Add clicked callback functions to the play background and
                % foreground buttons
                playbackground_button.ClickedCallback = {@playaudioclickedcallback,background_player,backgroundsignal_axes};
                playforeground_button.ClickedCallback = {@playaudioclickedcallback,foreground_player,foregroundsignal_axes};
                
                % Set play lines and select lines on the background and
                % foreground signal axes
                selectline(backgroundsignal_axes)
                playline(backgroundsignal_axes,background_player,playbackground_button);
                selectline(foregroundsignal_axes)
                playline(foregroundsignal_axes,foreground_player,playforeground_button);
                
            end
            
            % Clicked callback function for the save background button
            function savebackgroundclickedcallback(~,~)
                
                % Open dialog box for saving files; return if cancel
                [background_name,background_path] = uiputfile('*.wav*', ...
                    'Save Background as WAVE File','background_file.wav');
                if isequal(background_name,0) || isequal(background_path,0)
                    return
                end
                
                % Build full file name
                background_file = fullfile(background_path,background_name);
                
                % Write audio file
                audiowrite(background_file,background_signal,sample_rate)
                
            end
            
            % Clicked callback function for the save foreground button
            function saveforegroundclickedcallback(~,~)
                
                % Open dialog box for saving files; return if cancel
                [foreground_name,foreground_path] = uiputfile('*.wav*', ...
                    'Save Foreground as WAVE File','foreground_file.wav');
                if isequal(foreground_name,0) || isequal(foreground_path,0)
                    return
                end
                
                % Build full file name
                foreground_file = fullfile(foreground_path,foreground_name);
                
                % Write audio file
                audiowrite(foreground_file,foreground_signal,sample_rate)
                
            end
            
        end
        
    end
    
    % Clicked callback function for the select button
    function selectclickedcallback(~,~)
        
        % Keep the select button state to on and change the zoom and pan 
        % button states to off
        select_button.State = 'on';
        zoom_button.State = 'off';
        pan_button.State = 'off';
        
        % Turn the zoom off
        zoom off
        
        % Turn the pan off
        pan off
        
    end

    % Clicked callback function for the zoom button
    function zoomclickedcallback(~,~)
        
        % Keep the zoom button state to on and change the select and pan 
        % button states to off
        select_button.State = 'off';
        zoom_button.State = 'on';
        pan_button.State = 'off';
        
        % Make the zoom enable on the figure
        zoom_object = zoom(figure_object);
        zoom_object.Enable = 'on';
        
        % Set the zoom for the x-axis only on the mixture, background, and
        % foreground signal axes
        setAxesZoomConstraint(zoom_object,mixturesignal_axes,'x');
        setAxesZoomConstraint(zoom_object,backgroundsignal_axes,'x');
        setAxesZoomConstraint(zoom_object,foregroundsignal_axes,'x');
        
        % Turn the pan off
        pan off
        
    end

    % Clicked callback function for the pan button
    function panclickedcallback(~,~)
        
        % Keep the pan button state to on and change the select and zoom 
        % button states to off
        select_button.State = 'off';
        zoom_button.State = 'off';
        pan_button.State = 'on';
        
        % Turn the zoom off
        zoom off
        
        % Make the pan enable on the figure
        pan_object = pan(figure_object);
        pan_object.Enable = 'on';
        
        % Set the pan for the x-axis only on the mixture, background, and
        % foreground signal axes
        setAxesPanConstraint(pan_object,mixturesignal_axes,'x');
        setAxesPanConstraint(pan_object,backgroundsignal_axes,'x');
        setAxesPanConstraint(pan_object,foregroundsignal_axes,'x');
        
    end

    % Close request callback function for the figure
    function figurecloserequestfcn(~,~)
        
        % If any audio is playing, stop it
        if isplaying(mixture_player)
            stop(mixture_player)
        end
        if isplaying(background_player)
            stop(background_player)
        end
        if isplaying(foreground_player)
            stop(foreground_player)
        end
        
        % Create question dialog box to close the figure
        user_answer = questdlg('Close REPET GUI?',...
            'Close REPET GUI','Yes','No','Yes');
        switch user_answer
            case 'Yes'
                delete(figure_object)
            case 'No'
                return
        end
        
    end

end

% Read icon from Matlab
function image_data = iconread(icon_name)

% Read icon image from Matlab ([16x16x3] 16-bit PNG) and also return
% its transparency ([16x16] AND mask)
[image_data,~,image_transparency] ...
    = imread(fullfile(matlabroot,'toolbox','matlab','icons',icon_name),'PNG');

% Convert the image to double precision (in [0,1])
image_data = im2double(image_data);

% Convert the 0's to NaN's in the image using the transparency
image_data(image_transparency==0) = NaN;

end

% Create play icon
function image_data = playicon

% Create the upper-half of a black play triangle with NaN's everywhere else
image_data = [nan(2,16);[nan(6,3),kron(triu(nan(6,5)),ones(1,2)),nan(6,3)]];

% Make the whole black play triangle image
image_data = repmat([image_data;image_data(end:-1:1,:)],[1,1,3]);

end

% Create stop icon
function image_data = stopicon

% Create a black stop square with NaN's everywhere else
image_data = nan(16,16);
image_data(4:13,4:13) = 0;

% Make the black stop square an image
image_data = repmat(image_data,[1,1,3]);

end

% Create REPET icon
function image_data = repeticon

% Create a matrix with NaN's
image_data = nan(16,16,1);

% Create black R, E, P, E, and T letters
image_data(2:8,2:3) = 0;
image_data([2,3,5,6],4) = 0;
image_data([3:5,7:8],5) = 0;

image_data(2:8,7:8) = 0;
image_data([2,3,5,7,8],9) = 0;
image_data([2,3,7,8],10) = 0;

image_data(10:16,2:3) = 0;
image_data([10,11,13,14],4) = 0;
image_data(11:13,5) = 0;

image_data(10:16,7:8) = 0;
image_data([10,11,13,15,16],9) = 0;
image_data([10,11,15,16],10) = 0;

image_data(10:11,12:15) = 0;
image_data(12:16,13:14) = 0;

% Make the image
image_data = repmat(image_data,[1,1,3]);

end

% Set a select line on an audio signal axes
function selectline(audiosignal_axes)

% Initialize the select line as an array for graphic objects (two lines and
% one patch)
select_line = gobjects(3,1);

% Add mouse-click callback function to the audio signal axes
audiosignal_axes.ButtonDownFcn = @audiosignalaxesbuttondownfcn;

    % Mouse-click callback function for the audio signal axes
    function audiosignalaxesbuttondownfcn(~,~)
        
        % Location of the mouse pointer
        current_point = audiosignal_axes.CurrentPoint;
        
        % Plot limits from the audio signal axes' user data
        plot_limits = audiosignal_axes.UserData.PlotXLim;
        
        % If the current point is out of the plot limits, return
        if current_point(1,1) < plot_limits(1) || current_point(1,1) > plot_limits(2) || ...
                current_point(1,2) < -1 || current_point(1,2) > 1
            return
        end
        
        % Current figure handle
        figure_object = gcf;
        
        % Mouse selection type
        selection_type = figure_object.SelectionType;
        
        % If click left mouse button
        if strcmp(selection_type,'normal')
            
            % If not empty, delete the select line
            if ~isempty(select_line)
                delete(select_line)
            end
            
            % Create a first line on the audio signal axes
            color_value1 = 0.5*[1,1,1];
            select_line(1) = line(audiosignal_axes, ...
                current_point(1,1)*[1,1],[-1,1], ...
                'Color',color_value1, ...
                'ButtonDownFcn',@selectlinebuttondownfcn);
            
            % Create a second line and a non-clickable patch with different
            % colors and move them at the bottom of the current stack
            color_value2 = 0.75*[1,1,1];
            select_line(2) = line(audiosignal_axes, ...
                current_point(1,1)*[1,1],[-1,1], ...
                'Color',color_value2, ...
                'ButtonDownFcn',@selectlinebuttondownfcn);
            uistack(select_line(2),'bottom')
            select_line(3) = patch(audiosignal_axes, ...
                current_point(1,1)*[1,1,1,1],[-1,1,1,-1],color_value2, ...
                'LineStyle','none', ...
                'PickableParts','none');
            uistack(select_line(3),'bottom')
            
            % Change the pointer when the mouse moves over the lines, the
            % audio signal axes, and the figure object
            enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','hand');
            iptSetPointerBehavior(select_line(1),enterFcn);
            iptSetPointerBehavior(select_line(2),enterFcn);
            iptSetPointerBehavior(audiosignal_axes,enterFcn);
            iptSetPointerBehavior(figure_object,enterFcn);
            iptPointerManager(figure_object);
            
            % Add window button motion and up callback functions to the
            % figure
            figure_object.WindowButtonMotionFcn = {@figurewindowbuttonmotionfcn,select_line(1)};
            figure_object.WindowButtonUpFcn = @figurewindowbuttonupfcn;
            
            % Update the select limits in the audio signal axes' user data
            audiosignal_axes.UserData.SelectXLim = current_point(1,1)*[1,1];
            
        % If click right mouse button
        elseif strcmp(selection_type,'alt')
            
            % If not empty, delete the select line
            if ~isempty(select_line)
                delete(select_line)
            end
            
            % Update the select limits in the audio signal axes' user data
            audiosignal_axes.UserData.SelectXLim = plot_limits;
            
        end
        
        % Mouse-click callback function for the lines
        function selectlinebuttondownfcn(object_handle,~)
            
            % Mouse selection type
            selection_type = figure_object.SelectionType;
            
            % If click left mouse button
            if strcmp(selection_type,'normal')
                
                % Change the pointer when the mouse moves over the audio
                % signal axes or the figure object
                enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','hand');
                iptSetPointerBehavior(audiosignal_axes,enterFcn);
                iptSetPointerBehavior(figure_object,enterFcn);
                iptPointerManager(figure_object);
                
                % Add window button motion and up callback functions to
                % the figure
                figure_object.WindowButtonMotionFcn = {@figurewindowbuttonmotionfcn,object_handle};
                figure_object.WindowButtonUpFcn = @figurewindowbuttonupfcn;
                
            % If click right mouse button
            elseif strcmp(selection_type,'alt')
                
                % Delete the select line
                delete(select_line)
                
                % Update the select limits in the audio signal axes' user
                % data
                audiosignal_axes.UserData.SelectXLim = plot_limits;
                
            end
            
        end
        
        % Window button motion callback function for the figure
        function figurewindowbuttonmotionfcn(~,~,select_linei)
            
            % Location of the mouse pointer
            current_point = audiosignal_axes.CurrentPoint;
            
            % If the current point is out of the plot limits, change it 
            % into the plot limits
            if current_point(1,1) < plot_limits(1)
                current_point(1,1) = plot_limits(1);
            elseif current_point(1,1) > plot_limits(2)
                current_point(1,1) = plot_limits(2);
            end
            
            % Update the coordinates of the audio line that has been
            % clicked and the coordinates of the audio patch
            select_linei.XData = current_point(1,1)*[1,1];
            select_line(3).XData = [select_line(1).XData,select_line(2).XData];
            
            % If the two lines are at different coordinates and the patch
            % is a full rectangle
            if select_line(1).XData(1) ~= select_line(2).XData(1)
                
                % Change the color of the first line to match the color of
                % the second line and the patch, and move it at the bottom
                % of the current stack
                select_line(1).Color = color_value2;
                uistack(select_line(1),'bottom')
                
            % If the two lines are at the same coordinates and the patch is
            % a vertical line
            else
                
                % Change the color of the first line back, and move
                % it at the top of the current stack
                select_line(1).Color = color_value1;
                uistack(select_line(1),'top')
                
            end
            
        end
        
        % Window button up callback function for the figure
        function figurewindowbuttonupfcn(~,~)
            
            % Change the pointer back when the mouse moves over the audio
            % signal axes and the figure object
            enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','ibeam');
            iptSetPointerBehavior(audiosignal_axes,enterFcn);
            iptPointerManager(figure_object);
            enterFcn = @(figure_handle, currentPoint) set(figure_handle,'Pointer','arrow');
            iptSetPointerBehavior(figure_object,enterFcn);
            iptPointerManager(figure_object);
            
            % Coordinates of the two audio lines
            x_value1 = select_line(1).XData(1);
            x_value2 = select_line(2).XData(1);
            
            % Update the select limits in the audio signal axes' user data
            % depending if the two lines have the same or different
            % coordinates
            if x_value1 == x_value2
                audiosignal_axes.UserData.SelectXLim = [x_value1,x_value1];
            elseif x_value1 < x_value2
                audiosignal_axes.UserData.SelectXLim = [x_value1,x_value2];
            else
                audiosignal_axes.UserData.SelectXLim = [x_value2,x_value1];
            end
            
            % Remove the window button motion and up callback functions of
            % the figure
            figure_object.WindowButtonMotionFcn = '';
            figure_object.WindowButtonUpFcn = '';
            
        end
        
    end

end

% Set a play line on an audio signal axes using an audio player
function playline(audiosignal_axes,audio_player,playaudio_button)

% Play and stop icons from the play audio buttons' user data
play_icon = playaudio_button.UserData.PlayIcon;
stop_icon = playaudio_button.UserData.StopIcon;

% Sample rate in Hz from the audio player
sample_rate = audio_player.SampleRate;

% Get the plot limits from the audio signal axes' user data
plot_limits = audiosignal_axes.UserData.PlotXLim;

% Initialize the play line
play_line = [];

% Add callback functions to the audio player
audio_player.StartFcn = @audioplayerstartfcn;
audio_player.StopFcn = @audioplayerstopfcn;
audio_player.TimerFcn = @audioplayertimerfcn;

    % Function to execute one time when the playback starts
    function audioplayerstartfcn(~,~)
        
        % Change the play audio button icon to a stop icon and the tooltip 
        % to 'Stop'
        playaudio_button.CData = stop_icon;
        playaudio_button.TooltipString = ['Stop',playaudio_button.TooltipString(5:end)];
        
        % Get the select limits from the audio signal axes' user data
        select_limits = audiosignal_axes.UserData.SelectXLim;
        
        % Create a play line on the audio signal axes
        play_line = line(audiosignal_axes,select_limits(1)*[1,1],[-1,1]);
        
    end

    % Function to execute one time when playback stops
    function audioplayerstopfcn(~,~)
        
        % Change the play audio button icon to a play icon and the tooltip 
        % to 'Play'
        playaudio_button.CData = play_icon;
        playaudio_button.TooltipString = ['Play',playaudio_button.TooltipString(5:end)];
        
        % Delete the play line
        delete(play_line)
        
    end

    % Function to execute repeatedly during playback
    function audioplayertimerfcn(~,~)
        
        % Current sample and sample range from the audio player
        current_sample = audio_player.CurrentSample;
        
        % Make sure the current sample is only increasing (to prevent the
        % play line from showing up at the start when the playback is over)
        if current_sample > 1
            
            % Update the play line
            play_line.XData = (plot_limits(1)+current_sample/sample_rate)*[1,1];
            
        end
        
    end

end

% Clicked callback function for the play audio buttons
function playaudioclickedcallback(~,~,audio_player,audiosignal_axes)

% If the playback is in progress
if isplaying(audio_player)
    
    % Stop the audio
    stop(audio_player)
    
else
    
    % Sample rate and number of samples from the audio player
    sample_rate = audio_player.SampleRate;
    number_samples = audio_player.TotalSamples;
    
    % Plot and select limits from the audio signal axes' user data
    plot_limits = audiosignal_axes.UserData.PlotXLim;
    select_limits = audiosignal_axes.UserData.SelectXLim;
    
    % Derive the sample range for the audio player
    if select_limits(1) == select_limits(2)
        % If it is a select line
        sample_range = [round((select_limits(1)-plot_limits(1))*sample_rate)+1,number_samples];
    else
        % If it is a select region
        sample_range = round((select_limits-plot_limits(1))*sample_rate+1);
    end
    
    % Play the audio given the sample range
    play(audio_player,sample_range)
    
end

end

% Short-time Fourier transform (STFT) (with zero-padding at the edges)
function audio_stft = stft(audio_signal,window_function,step_length)

% Number of samples and window length
number_samples = length(audio_signal);
window_length = length(window_function);

% Number of time frames
number_times = ceil((window_length-step_length+number_samples)/step_length);

% Zero-padding at the start and the end to center the windows
audio_signal = [zeros(window_length-step_length,1);audio_signal; ...
    zeros(number_times*step_length-number_samples,1)];

% Initialize the STFT
audio_stft = zeros(window_length,number_times);

% Loop over the time frames
for time_index = 1:number_times
    
    % Framing and windowing of the signal
    sample_index = step_length*(time_index-1);
    audio_stft(:,time_index) = audio_signal(1+sample_index:window_length+sample_index) ...
        .*window_function;
    
end

% Fourier transform of the frames
audio_stft = fft(audio_stft);

end

% Inverse short-time Fourier transform
function audio_signal = istft(audio_stft,window_function,step_length)

% Window length and number of time frames
[window_length,number_times] = size(audio_stft);

% Number of samples for the signal
number_samples = (number_times-1)*step_length+window_length;

% Initialize the signal
audio_signal = zeros(number_samples,1);

% Inverse Fourier transform of the frames and ensure real values
audio_stft = real(ifft(audio_stft));

% Loop over the time frames
for time_index = 1:number_times
    
    % Overlap-add of the signal (normalized proper window and step length)
    sample_index = step_length*(time_index-1);
    audio_signal(1+sample_index:window_length+sample_index) ...
        = audio_signal(1+sample_index:window_length+sample_index)+audio_stft(:,time_index);
    
end

% Remove the zero-padding at the start and the end
audio_signal = audio_signal(window_length-step_length+1:number_samples-(window_length-step_length));

% Normalize by the window (just in case)
audio_signal = audio_signal/sum(window_function(1:step_length:window_length));

end

% Autocorrelation using the Wiener�Khinchin theorem (faster than xcorr)
function autocorrelation_matrix = acorr(data_matrix)

% Number of points in each column
number_points = size(data_matrix,1);

% Power Spectral Density (PSD): PSD(X) = fft(X).*conj(fft(X)) (after
% zero-padding for proper autocorrelation)
data_matrix = abs(fft(data_matrix,2*number_points)).^2;

% Wiener�Khinchin theorem: PSD(X) = fft(acorr(X))
autocorrelation_matrix = ifft(data_matrix);

% Discard the symmetric part
autocorrelation_matrix = autocorrelation_matrix(1:number_points,:);

% Unbiased autocorrelation (lag 0 to number_points-1)
autocorrelation_matrix = autocorrelation_matrix./(number_points:-1:1)';

end

% Beat spectrum using the autocorrelation
function beat_spectrum = beatspectrum(audio_spectrogram)

% Autocorrelation of the frequency channels
beat_spectrum = acorr(audio_spectrogram');

% Mean over the frequency channels
beat_spectrum = mean(beat_spectrum,2);

end

% Repeating period from the beat spectrum
function repeating_period = repeatingperiod(beat_spectrum,period_range)

% Update the maximum period so that the repeating period is at most a third
% of the maximum lag, as at least three segments are needed for the median
period_range(2) = min(period_range(2),floor((length(beat_spectrum)-1)/3));

% Update the minimum period to 1 lag if the maximum period is smaller than
% the minimum period
if period_range(2)<period_range(1)
    period_range(1) = 1;
end

% The repeating period is the index of the maximum peak in the beat
% spectrum given the period range (its does not account for lag 0)
beat_spectrum = beat_spectrum(period_range(1)+1:period_range(2)+1);
[~,repeating_period] = max(beat_spectrum.* ...
    [0;(beat_spectrum(2:end-1)>=beat_spectrum(1:end-2)) ...
    & (beat_spectrum(2:end-1)>=beat_spectrum(3:end));0]);
repeating_period = repeating_period+period_range(1);

end

% Repeating mask using the repeating period
function repeating_mask = repeatingmask(audio_spectrogram,repeating_period)

% Number of frequency channels and time frames
[number_frequencies,number_times] = size(audio_spectrogram);

% Number of repeating segments, including the last partial one
number_segments = ceil(number_times/repeating_period);

% Pad the audio spectrogram to have an integer number of segments and
% reshape it to a tensor
audio_spectrogram = [audio_spectrogram,nan(number_frequencies,number_segments*repeating_period-number_times)];
audio_spectrogram = reshape(audio_spectrogram,[number_frequencies,repeating_period,number_segments]);

% Derive the repeating segment by taking the median over the segments,
% ignoring the nan parts
repeating_segment = [median(audio_spectrogram(:,1:number_times-(number_segments-1)*repeating_period,:),3), ...
    median(audio_spectrogram(:,number_times-(number_segments-1)*repeating_period+1:repeating_period,1:end-1),3)];

% Derive the repeating spectrogram by ensuring it has less energy than the
% audio spectrogram
repeating_spectrogram = min(audio_spectrogram,repeating_segment);

% Derive the repeating mask by normalizing the repeating spectrogram by the
% audio spectrogram
repeating_mask = (repeating_spectrogram+eps)./(audio_spectrogram+eps);

% Reshape the repeating mask and truncate to the original number of time
% frames
repeating_mask = reshape(repeating_mask,[number_frequencies,number_segments*repeating_period]);
repeating_mask = repeating_mask(:,1:number_times);

end
