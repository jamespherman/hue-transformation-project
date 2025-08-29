function runHueExpansionApp()
    % Main function to create and run the Hue Expansion Tool GUI

    % --- App Data ---
    originalImage = [];
    processedImage = [];
    handles = struct();

    % --- UI Setup ---
    % Create the main figure
    fig = uifigure('Name', 'Hue Expansion Tool', 'Position', [100 100 1200 800]);

    % Set up the main grid layout
    mainGrid = uigridlayout(fig, [1, 2]);
    mainGrid.ColumnWidth = {250, '1x'};
    mainGrid.RowHeight = {'1x'};

    % Create a nested grid for the image axes in the right column
    imageGrid = uigridlayout(mainGrid, [2, 1]);
    imageGrid.Layout.Row = 1;
    imageGrid.Layout.Column = 2;
    imageGrid.RowHeight = {'1x', '1x'};
    imageGrid.ColumnWidth = {'1x'};

    % Create axes for the original image
    handles.originalAxes = uiaxes(imageGrid);
    handles.originalAxes.Layout.Row = 1;
    handles.originalAxes.Layout.Column = 1;
    title(handles.originalAxes, 'Original Image');
    disableDefaultInteractivity(handles.originalAxes);
    handles.originalAxes.XTick = [];
    handles.originalAxes.YTick = [];

    % Create axes for the processed image
    handles.processedAxes = uiaxes(imageGrid);
    handles.processedAxes.Layout.Row = 2;
    handles.processedAxes.Layout.Column = 1;
    title(handles.processedAxes, 'Processed Image');
    disableDefaultInteractivity(handles.processedAxes);
    handles.processedAxes.XTick = [];
    handles.processedAxes.YTick = [];

    % Create the controls panel in the left column
    controlPanel = uipanel(mainGrid, 'Title', 'Controls');
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = 1;

    % Create a grid layout for the controls
    controlGrid = uigridlayout(controlPanel, [14, 4]); % More rows and a new column
    controlGrid.RowHeight = {40, 40, ... % Buttons
                             22, '1x', 30, ... % Input Hist + Controls
                             22, '1x', 30, ... % Output Hist + Controls
                             22, 40, ...    % Ref Spectrum
                             22, 22, 22, 22}; % Sliders
    controlGrid.ColumnWidth = {'fit', '1x', 'fit', '1x'};

    % Load Image Button
    handles.loadImageButton = uibutton(controlGrid, 'Text', 'Load Image');
    handles.loadImageButton.Layout.Row = 1;
    handles.loadImageButton.Layout.Column = [1, 4];

    % Save Image Button
    handles.saveImageButton = uibutton(controlGrid, 'Text', 'Save Processed Image');
    handles.saveImageButton.Layout.Row = 2;
    handles.saveImageButton.Layout.Column = [1, 4];

    % --- Input Hue Histogram ---
    lbl1 = uilabel(controlGrid, 'Text', 'Input Hue Histogram');
    lbl1.Layout.Row = 3;
    lbl1.Layout.Column = [1, 4];
    handles.inputHueHistogramAxes = uiaxes(controlGrid);
    handles.inputHueHistogramAxes.Layout.Row = 4;
    handles.inputHueHistogramAxes.Layout.Column = [1, 4];
    handles.inputHueHistogramAxes.YTick = [];
    disableDefaultInteractivity(handles.inputHueHistogramAxes);

    uilabel(controlGrid, 'Text', 'Min:').Layout.Column = 1;
    uilabel(controlGrid, 'Text', 'Max:').Layout.Column = 3;
    handles.inputMinEdit = uieditfield(controlGrid, 'numeric', 'Value', 350, 'Limits', [0, 360]);
    handles.inputMaxEdit = uieditfield(controlGrid, 'numeric', 'Value', 10, 'Limits', [0, 360]);
    handles.inputMinEdit.Layout.Row = 5;
    handles.inputMinEdit.Layout.Column = 2;
    handles.inputMaxEdit.Layout.Row = 5;
    handles.inputMaxEdit.Layout.Column = 4;

    % --- Output Hue Histogram ---
    lbl2 = uilabel(controlGrid, 'Text', 'Output Hue Histogram');
    lbl2.Layout.Row = 6;
    lbl2.Layout.Column = [1, 4];
    handles.outputHueHistogramAxes = uiaxes(controlGrid);
    handles.outputHueHistogramAxes.Layout.Row = 7;
    handles.outputHueHistogramAxes.Layout.Column = [1, 4];
    handles.outputHueHistogramAxes.YTick = [];
    disableDefaultInteractivity(handles.outputHueHistogramAxes);

    uilabel(controlGrid, 'Text', 'Min:').Layout.Row = 8;
    uilabel(controlGrid, 'Text', 'Max:').Layout.Row = 8;
    uilabel(controlGrid, 'Text', 'Min:').Layout.Column = 1;
    uilabel(controlGrid, 'Text', 'Max:').Layout.Column = 3;
    handles.outputMinEdit = uieditfield(controlGrid, 'numeric', 'Value', 0, 'Limits', [0, 360]);
    handles.outputMaxEdit = uieditfield(controlGrid, 'numeric', 'Value', 360, 'Limits', [0, 360]);
    handles.outputMinEdit.Layout.Row = 8;
    handles.outputMinEdit.Layout.Column = 2;
    handles.outputMaxEdit.Layout.Row = 8;
    handles.outputMaxEdit.Layout.Column = 4;

    % --- Reference Hue Spectrum ---
    lbl3 = uilabel(controlGrid, 'Text', 'Reference Hue Spectrum');
    lbl3.Layout.Row = 9;
    lbl3.Layout.Column = [1, 4];
    handles.referenceHueSpectrumAxes = uiaxes(controlGrid);
    handles.referenceHueSpectrumAxes.Layout.Row = 10;
    handles.referenceHueSpectrumAxes.Layout.Column = [1, 4];
    handles.referenceHueSpectrumAxes.XTick = [];
    handles.referenceHueSpectrumAxes.YTick = [];
    disableDefaultInteractivity(handles.referenceHueSpectrumAxes);

    % --- Saturation Threshold ---
    lbl4 = uilabel(controlGrid, 'Text', 'Sat Thresh');
    lbl4.Layout.Row = 11;
    lbl4.Layout.Column = 1;
    handles.saturationSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.saturationSlider.Layout.Row = 11;
    handles.saturationSlider.Layout.Column = [2, 3];
    handles.saturationEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.saturationEdit.Layout.Row = 11;
    handles.saturationEdit.Layout.Column = 4;

    % --- Value Threshold ---
    lbl5 = uilabel(controlGrid, 'Text', 'Val Thresh');
    lbl5.Layout.Row = 12;
    lbl5.Layout.Column = 1;
    handles.valueSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.valueSlider.Layout.Row = 12;
    handles.valueSlider.Layout.Column = [2, 3];
    handles.valueEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.valueEdit.Layout.Row = 12;
    handles.valueEdit.Layout.Column = 4;

    % --- Callbacks ---
    handles.loadImageButton.ButtonPushedFcn = @loadImageCallback;
    handles.saveImageButton.ButtonPushedFcn = @saveImageCallback;

    % Synchronization and update callbacks
    handles.saturationSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationEdit);
    handles.saturationEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationSlider);

    handles.valueSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueEdit);
    handles.valueEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueSlider);

    % --- App Startup ---
    initializeHueControls();
    loadDefaultImage();

    % --- Nested Callback Functions ---
    function loadDefaultImage()
        defaultImageFile = 'your_endoscopic_image.jpg';
        if exist(defaultImageFile, 'file')
            try
                originalImage = imread(defaultImageFile);
                imshow(originalImage, 'Parent', handles.originalAxes);
                handles.originalAxes.Title.String = sprintf('Original Image: %s', defaultImageFile);
                updateView();
            catch ME
                uialert(fig, ['Error loading default image: ' ME.message], 'Image Load Error');
            end
        end
    end

    function saveImageCallback(~, ~)
        if isempty(processedImage)
            uialert(fig, 'There is no processed image to save.', 'Save Error');
            return;
        end

        [file, path] = uiputfile(...
            {'*.png', 'PNG Image (*.png)'; ...
             '*.jpg', 'JPEG Image (*.jpg)'; ...
             '*.tif', 'TIFF Image (*.tif)'}, ...
             'Save Processed Image As...');

        if isequal(file, 0)
            return; % User canceled
        end

        fullPath = fullfile(path, file);
        try
            imwrite(processedImage, fullPath);
        catch ME
            uialert(fig, ['Error saving image: ' ME.message], 'Save Error');
        end
    end

    function loadImageCallback(~, ~)
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif', 'Image Files (*.jpg, *.png, *.tif)'; '*.*', 'All Files (*.*)'}, 'Select an Image');
        if isequal(file, 0)
            return; % User canceled
        end

        fullPath = fullfile(path, file);
        try
            originalImage = imread(fullPath);
            imshow(originalImage, 'Parent', handles.originalAxes);
            handles.originalAxes.Title.String = sprintf('Original Image: %s', file);

            plotInputHistogram(); % Plot histogram for newly loaded image

            % Update view immediately after loading
            updateView();
        catch ME
            keyboard
            uialert(fig, ['Error loading image: ' ME.message], 'Image Load Error');
        end
    end

    function syncAndUpdate(source, target)
        % Sync the value from the source component to the target component
        target.Value = source.Value;
        % Trigger the main update function
        updateView();
    end

    function updateView(~, ~)
        try
            processedImage = processImage();
            if ~isempty(processedImage)
                imshow(processedImage, 'Parent', handles.processedAxes);
                handles.processedAxes.Title.String = 'Processed Image';

                set(handles.outputHueHistogramAxes, 'NextPlot', 'add');
                existing_bars = findobj(handles.outputHueHistogramAxes, 'Type', 'bar');
                delete(existing_bars);

                [counts, edges] = calculateHueHistogram(processedImage);
                binCenters = edges(1:end-1) + 0.5;
                barObj = bar(handles.outputHueHistogramAxes, binCenters, counts, 'BarWidth', 1);
                uistack(barObj, 'bottom');

                set(handles.outputHueHistogramAxes, 'XLim', [0 360]);
                newYLim = [0 max(counts)*1.05];
                if all(newYLim == 0); newYLim = [0 1]; end
                set(handles.outputHueHistogramAxes, 'YLim', newYLim);

                % Update line Y-Data
                set(handles.outputMinLine, 'YData', newYLim);
                set(handles.outputMaxLine, 'YData', newYLim);
            else
                imshow([], 'Parent', handles.processedAxes);
                handles.processedAxes.Title.String = 'Processed Image';
                cla(handles.outputHueHistogramAxes);
            end
        catch ME
            uialert(fig, ['Error processing image: ' ME.message], 'Processing Error');
        end
    end

    function outputImage = processImage()
        if isempty(originalImage)
            outputImage = [];
            return;
        end

        % Get values from edit fields and normalize
        inputMin = handles.inputMinEdit.Value / 360;
        inputMax = handles.inputMaxEdit.Value / 360;
        outputMin = handles.outputMinEdit.Value / 360;
        outputMax = handles.outputMaxEdit.Value / 360;

        satThreshold = handles.saturationSlider.Value;
        valThreshold = handles.valueSlider.Value;

        hsvImage = rgb2hsv(originalImage);
        h = hsvImage(:,:,1);
        s = hsvImage(:,:,2);
        v = hsvImage(:,:,3);

        satValMask = (s >= satThreshold) & (v >= valThreshold);

        if inputMin <= inputMax
            hueMask = (h >= inputMin) & (h <= inputMax);
        else
            hueMask = (h >= inputMin) | (h <= inputMax);
        end

        finalMask = satValMask & hueMask;
        targetHues = h(finalMask);

        inputWidth = mod(inputMax - inputMin, 1);
        if inputWidth < 1e-6; inputWidth = 1; end

        distFromMin = mod(targetHues - inputMin, 1);
        relativeHuePos = distFromMin / inputWidth;

        outputWidth = mod(outputMax - outputMin, 1);
        if outputWidth < 1e-6; outputWidth = 1; end

        mappedHues = mod(outputMin + relativeHuePos * outputWidth, 1);

        newH = h;
        newH(finalMask) = mappedHues;

        finalHsvImage = cat(3, newH, s, v);
        outputImage = hsv2rgb(finalHsvImage);
    end

    function plotInputHistogram()
        if isempty(originalImage)
            cla(handles.inputHueHistogramAxes);
            return;
        end
        set(handles.inputHueHistogramAxes, 'NextPlot', 'add');

        existing_bars = findobj(handles.inputHueHistogramAxes, 'Type', 'bar');
        delete(existing_bars);

        [counts, edges] = calculateHueHistogram(originalImage);
        binCenters = edges(1:end-1) + 0.5;
        barObj = bar(handles.inputHueHistogramAxes, binCenters, counts, 'BarWidth', 1);
        uistack(barObj, 'bottom');

        set(handles.inputHueHistogramAxes, 'XLim', [0 360]);
        newYLim = [0 max(counts)*1.05];
        if all(newYLim == 0); newYLim = [0 1]; end
        set(handles.inputHueHistogramAxes, 'YLim', newYLim);

        % Update line Y-Data
        set(handles.inputMinLine, 'YData', newYLim);
        set(handles.inputMaxLine, 'YData', newYLim);
    end

    function initializeHueControls()
        spectrumImage = createHueSpectrumImage();
        imshow(spectrumImage, 'Parent', handles.referenceHueSpectrumAxes);
        set(handles.referenceHueSpectrumAxes, 'XTick', [], 'YTick', [], 'Box', 'on', 'XLim', [0 360], 'YLim', [0 1]);

        allHistAxes = [handles.inputHueHistogramAxes, handles.outputHueHistogramAxes];
        set(allHistAxes, 'Box', 'on', 'XLim', [0 360], 'YLim', [0 1]);
        xlabel(handles.inputHueHistogramAxes, 'Hue Angle (0-360)');
        xlabel(handles.outputHueHistogramAxes, 'Hue Angle (0-360)');

        % Hold on to draw multiple lines
        hold(handles.inputHueHistogramAxes, 'on');
        hold(handles.outputHueHistogramAxes, 'on');

        % Create lines controlled by edit boxes
        handles.inputMinLine = plot(handles.inputHueHistogramAxes, [350 350], [0 1], 'k', 'LineWidth', 1.5);
        handles.inputMaxLine = plot(handles.inputHueHistogramAxes, [10 10], [0 1], 'k', 'LineWidth', 1.5);
        handles.outputMinLine = plot(handles.outputHueHistogramAxes, [0 0], [0 1], 'k', 'LineWidth', 1.5);
        handles.outputMaxLine = plot(handles.outputHueHistogramAxes, [360 360], [0 1], 'k', 'LineWidth', 1.5);

        % Hold off after plotting
        hold(handles.inputHueHistogramAxes, 'off');
        hold(handles.outputHueHistogramAxes, 'off');

        % Add callbacks
        handles.inputMinEdit.ValueChangedFcn = @(src, event) updateLineAndProcess(src, handles.inputMinLine);
        handles.inputMaxEdit.ValueChangedFcn = @(src, event) updateLineAndProcess(src, handles.inputMaxLine);
        handles.outputMinEdit.ValueChangedFcn = @(src, event) updateLineAndProcess(src, handles.outputMinLine);
        handles.outputMaxEdit.ValueChangedFcn = @(src, event) updateLineAndProcess(src, handles.outputMaxLine);
    end

    function updateLineAndProcess(editField, lineHandle)
        newValue = editField.Value;
        set(lineHandle, 'XData', [newValue newValue]);
        updateView();
    end

    function spectrumImg = createHueSpectrumImage()
        % Creates a 20x360x3 HSV image representing the hue spectrum
        % and converts it to an RGB image.

        % Define the hue values for a single row
        hue_row = linspace(0, 1, 360);

        % Create the full-sized matrices for hue, saturation, and value
        hue = repmat(hue_row, 20, 1); % 20 pixels high
        saturation = ones(20, 360);
        value = ones(20, 360);

        % Combine into an HSV image
        % Note: MATLAB automatically handles the 3rd dimension for cat
        hsvImage = cat(3, hue, saturation, value);

        % Convert to RGB
        spectrumImg = hsv2rgb(hsvImage);
    end

    function [counts, edges] = calculateHueHistogram(rgbImage)
        if isempty(rgbImage)
            counts = zeros(1, 360);
            edges = 0:1:360;
            return;
        end
        % Convert RGB to HSV
        hsvImage = rgb2hsv(rgbImage);
        % Extract Hue channel and scale to 0-360
        hueChannel = hsvImage(:,:,1) * 360;
        % Calculate histogram
        [counts, edges] = histcounts(hueChannel(:), 0:1:360);
    end
end
