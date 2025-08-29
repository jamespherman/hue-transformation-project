function runHueExpansionApp()
    % Main function to create and run the Hue Expansion Tool GUI.
    % This function encapsulates the entire application, including UI setup,
    % data management, and callback definitions.

    % --- App Data ---
    % Initialize variables to store image data and UI component handles.
    originalImage = [];    % Stores the loaded, unmodified image.
    processedImage = [];   % Stores the image after hue expansion.
    handles = struct();    % Struct to hold handles to UI components for easy access.

    % --- UI Setup ---
    % Create the main application window (figure).
    fig = uifigure('Name', 'Hue Expansion Tool', 'Position', [100 100 1200 800]);

    % Set up the main grid layout to organize the UI into a control panel and an image display area.
    mainGrid = uigridlayout(fig, [1, 2]);
    mainGrid.ColumnWidth = {250, '1x'}; % Left column for controls, right for images.
    mainGrid.RowHeight = {'1x'};

    % Create a nested grid in the right column to stack the original and processed image axes.
    imageGrid = uigridlayout(mainGrid, [2, 1]);
    imageGrid.Layout.Row = 1;
    imageGrid.Layout.Column = 2;
    imageGrid.RowHeight = {'1x', '1x'}; % Equal height for both image axes.
    imageGrid.ColumnWidth = {'1x'};

    % Create axes for displaying the original image.
    handles.originalAxes = uiaxes(imageGrid);
    handles.originalAxes.Layout.Row = 1;
    handles.originalAxes.Layout.Column = 1;
    title(handles.originalAxes, 'Original Image');
    disableDefaultInteractivity(handles.originalAxes); % Disable zoom, pan, etc.
    handles.originalAxes.XTick = []; % Hide axis ticks.
    handles.originalAxes.YTick = [];

    % Create axes for displaying the processed image.
    handles.processedAxes = uiaxes(imageGrid);
    handles.processedAxes.Layout.Row = 2;
    handles.processedAxes.Layout.Column = 1;
    title(handles.processedAxes, 'Processed Image');
    disableDefaultInteractivity(handles.processedAxes);
    handles.processedAxes.XTick = [];
    handles.processedAxes.YTick = [];

    % Create the main control panel on the left side.
    controlPanel = uipanel(mainGrid, 'Title', 'Controls');
    controlPanel.Layout.Row = 1;
    controlPanel.Layout.Column = 1;

    % Use a grid layout within the control panel to arrange all widgets.
    controlGrid = uigridlayout(controlPanel, [14, 4]); % 14 rows, 4 columns.
    controlGrid.RowHeight = {40, 40, ... % Buttons
                             22, '1x', 30, ... % Input Hist + Controls
                             22, '1x', 30, ... % Output Hist + Controls
                             22, 40, ...    % Ref Spectrum
                             22, 22, 22, 22}; % Sliders
    controlGrid.ColumnWidth = {'fit', '1x', 'fit', '1x'}; % Define column widths.

    % --- UI Component Definitions ---

    % Load Image Button
    handles.loadImageButton = uibutton(controlGrid, 'Text', 'Load Image');
    handles.loadImageButton.Layout.Row = 1;
    handles.loadImageButton.Layout.Column = [1, 4]; % Span all 4 columns.

    % Save Image Button
    handles.saveImageButton = uibutton(controlGrid, 'Text', 'Save Processed Image');
    handles.saveImageButton.Layout.Row = 2;
    handles.saveImageButton.Layout.Column = [1, 4];

    % Input Hue Histogram Components
    uilabel(controlGrid, 'Text', 'Input Hue Histogram', 'Layout', struct('Row', 3, 'Column', [1, 4]));
    handles.inputHueHistogramAxes = uiaxes(controlGrid);
    handles.inputHueHistogramAxes.Layout.Row = 4;
    handles.inputHueHistogramAxes.Layout.Column = [1, 4];
    handles.inputHueHistogramAxes.YTick = [];
    disableDefaultInteractivity(handles.inputHueHistogramAxes);

    % Input Hue Range Numeric Edit Fields
    uilabel(controlGrid, 'Text', 'Min:', 'Layout', struct('Row', 5, 'Column', 1));
    handles.inputMinEdit = uieditfield(controlGrid, 'numeric', 'Value', 350, 'Limits', [0, 360]);
    handles.inputMinEdit.Layout.Row = 5;
    handles.inputMinEdit.Layout.Column = 2;
    uilabel(controlGrid, 'Text', 'Max:', 'Layout', struct('Row', 5, 'Column', 3));
    handles.inputMaxEdit = uieditfield(controlGrid, 'numeric', 'Value', 10, 'Limits', [0, 360]);
    handles.inputMaxEdit.Layout.Row = 5;
    handles.inputMaxEdit.Layout.Column = 4;

    % Output Hue Histogram Components
    uilabel(controlGrid, 'Text', 'Output Hue Histogram', 'Layout', struct('Row', 6, 'Column', [1, 4]));
    handles.outputHueHistogramAxes = uiaxes(controlGrid);
    handles.outputHueHistogramAxes.Layout.Row = 7;
    handles.outputHueHistogramAxes.Layout.Column = [1, 4];
    handles.outputHueHistogramAxes.YTick = [];
    disableDefaultInteractivity(handles.outputHueHistogramAxes);

    % Output Hue Range Numeric Edit Fields
    uilabel(controlGrid, 'Text', 'Min:', 'Layout', struct('Row', 8, 'Column', 1));
    handles.outputMinEdit = uieditfield(controlGrid, 'numeric', 'Value', 0, 'Limits', [0, 360]);
    handles.outputMinEdit.Layout.Row = 8;
    handles.outputMinEdit.Layout.Column = 2;
    uilabel(controlGrid, 'Text', 'Max:', 'Layout', struct('Row', 8, 'Column', 3));
    handles.outputMaxEdit = uieditfield(controlGrid, 'numeric', 'Value', 360, 'Limits', [0, 360]);
    handles.outputMaxEdit.Layout.Row = 8;
    handles.outputMaxEdit.Layout.Column = 4;

    % Reference Hue Spectrum Display
    uilabel(controlGrid, 'Text', 'Reference Hue Spectrum', 'Layout', struct('Row', 9, 'Column', [1, 4]));
    handles.referenceHueSpectrumAxes = uiaxes(controlGrid);
    handles.referenceHueSpectrumAxes.Layout.Row = 10;
    handles.referenceHueSpectrumAxes.Layout.Column = [1, 4];
    handles.referenceHueSpectrumAxes.XTick = [];
    handles.referenceHueSpectrumAxes.YTick = [];
    disableDefaultInteractivity(handles.referenceHueSpectrumAxes);

    % Saturation Threshold Slider and Edit Field
    uilabel(controlGrid, 'Text', 'Sat Thresh', 'Layout', struct('Row', 11, 'Column', 1));
    handles.saturationSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.saturationSlider.Layout.Row = 11;
    handles.saturationSlider.Layout.Column = [2, 3];
    handles.saturationEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.saturationEdit.Layout.Row = 11;
    handles.saturationEdit.Layout.Column = 4;

    % Value Threshold Slider and Edit Field
    uilabel(controlGrid, 'Text', 'Val Thresh', 'Layout', struct('Row', 12, 'Column', 1));
    handles.valueSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.valueSlider.Layout.Row = 12;
    handles.valueSlider.Layout.Column = [2, 3];
    handles.valueEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.valueEdit.Layout.Row = 12;
    handles.valueEdit.Layout.Column = 4;

    % --- Callbacks ---
    % Assign functions to be executed on UI interactions.
    handles.loadImageButton.ButtonPushedFcn = @loadImageCallback;
    handles.saveImageButton.ButtonPushedFcn = @saveImageCallback;

    % Set up synchronization between sliders and their corresponding edit fields.
    % Changing one updates the other and triggers the main image processing function.
    handles.saturationSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationEdit);
    handles.saturationEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationSlider);
    handles.valueSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueEdit);
    handles.valueEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueSlider);

    % --- App Startup ---
    % Initialize UI elements that require programmatic setup after creation.
    initializeHueControls();
    % Attempt to load a default image for immediate use.
    loadDefaultImage();

    % --- Nested Callback Functions ---
    % These functions are defined within the main function scope, so they have access to `handles`, `originalImage`, etc.

    function loadDefaultImage()
        % Checks for a default image file and loads it on startup.
        defaultImageFile = 'your_endoscopic_image.jpg';
        if exist(defaultImageFile, 'file')
            try
                originalImage = imread(defaultImageFile);
                imshow(originalImage, 'Parent', handles.originalAxes);
                handles.originalAxes.Title.String = sprintf('Original Image: %s', defaultImageFile);
                updateView(); % Update processed image and histograms.
            catch ME
                uialert(fig, ['Error loading default image: ' ME.message], 'Image Load Error');
            end
        end
    end

    function saveImageCallback(~, ~)
        % Opens a dialog to save the processed image to a file.
        if isempty(processedImage)
            uialert(fig, 'There is no processed image to save.', 'Save Error');
            return;
        end

        % Prompt user for filename and format.
        [file, path] = uiputfile(...
            {'*.png', 'PNG Image (*.png)'; ...
             '*.jpg', 'JPEG Image (*.jpg)'; ...
             '*.tif', 'TIFF Image (*.tif)'}, ...
             'Save Processed Image As...');

        if isequal(file, 0)
            return; % User canceled the dialog.
        end

        fullPath = fullfile(path, file);
        try
            imwrite(processedImage, fullPath);
        catch ME
            uialert(fig, ['Error saving image: ' ME.message], 'Save Error');
        end
    end

    function loadImageCallback(~, ~)
        % Opens a dialog for the user to select and load an image.
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif', 'Image Files (*.jpg, *.png, *.tif)'; '*.*', 'All Files (*.*)'}, 'Select an Image');
        if isequal(file, 0)
            return; % User canceled.
        end

        fullPath = fullfile(path, file);
        try
            originalImage = imread(fullPath);
            imshow(originalImage, 'Parent', handles.originalAxes);
            handles.originalAxes.Title.String = sprintf('Original Image: %s', file);

            plotInputHistogram(); % Update the input histogram for the new image.
            updateView();         % Process and display the new image.
        catch ME
            uialert(fig, ['Error loading image: ' ME.message], 'Image Load Error');
        end
    end

    function syncAndUpdate(source, target)
        % Synchronizes the value between a slider and its edit field.
        target.Value = source.Value;
        % Triggers the main update function to re-process the image.
        updateView();
    end

    function updateView(~, ~)
        % Central function to update the processed image and output histogram.
        % This is called whenever a control value changes.
        try
            processedImage = processImage(); % Perform the hue remapping.
            if ~isempty(processedImage)
                imshow(processedImage, 'Parent', handles.processedAxes);
                handles.processedAxes.Title.String = 'Processed Image';

                % --- Update Output Hue Histogram ---
                % Clear previous histogram bars.
                set(handles.outputHueHistogramAxes, 'NextPlot', 'add');
                delete(findobj(handles.outputHueHistogramAxes, 'Type', 'bar'));

                % Calculate and display the new histogram.
                [counts, edges] = calculateHueHistogram(processedImage);
                binCenters = edges(1:end-1) + 0.5;

                % This section appears to have a logic bug where it filters by output range.
                % For a simple histogram display, this filtering is not needed.
                % The code is retained to match original behavior.
                g = binCenters >= handles.outputMinLine.XData(1) & ...
                    binCenters <= handles.outputMaxLine.XData(1);
                binCenters_filtered = binCenters(g);
                counts_filtered = counts(g);

                bar(handles.outputHueHistogramAxes, binCenters, counts, 'BarWidth', 1); % Plot full histogram

                % Adjust Y-axis limits for visibility.
                set(handles.outputHueHistogramAxes, 'XLim', [0 360]);
                newYLim = [0 max(counts)*1.05];
                if all(newYLim == 0); newYLim = [0 1]; end
                set(handles.outputHueHistogramAxes, 'YLim', newYLim);

                % Update the vertical range indicator lines to span the new Y-axis height.
                set(handles.outputMinLine, 'YData', newYLim);
                set(handles.outputMaxLine, 'YData', newYLim);
            else
                % If no image is processed, clear the axes.
                cla(handles.processedAxes);
                title(handles.processedAxes, 'Processed Image');
                cla(handles.outputHueHistogramAxes);
            end
        catch ME
            uialert(fig, ['Error processing image: ' ME.message], 'Processing Error');
        end
    end

    function outputImage = processImage()
        % Core image processing function.
        if isempty(originalImage)
            outputImage = [];
            return;
        end

        % Get control values and normalize hue values from 0-360 to 0-1 range.
        inputMin = handles.inputMinEdit.Value / 360;
        inputMax = handles.inputMaxEdit.Value / 360;
        outputMin = handles.outputMinEdit.Value / 360;
        outputMax = handles.outputMaxEdit.Value / 360;
        satThreshold = handles.saturationSlider.Value;
        valThreshold = handles.valueSlider.Value;

        % Convert the image from RGB to HSV color space.
        hsvImage = rgb2hsv(originalImage);
        h = hsvImage(:,:,1); % Hue
        s = hsvImage(:,:,2); % Saturation
        v = hsvImage(:,:,3); % Value

        % Create a mask for pixels that meet the saturation and value thresholds.
        satValMask = (s >= satThreshold) & (v >= valThreshold);

        % Create a mask for pixels within the selected input hue range.
        % Handles wrapping around 0 degrees (e.g., red hues).
        if inputMin <= inputMax
            hueMask = (h >= inputMin) & (h <= inputMax);
        else % The range crosses the 0-degree boundary.
            hueMask = (h >= inputMin) | (h <= inputMax);
        end

        % Combine masks to find target pixels for remapping.
        finalMask = satValMask & hueMask;
        targetHues = h(finalMask);

        % --- Hue Remapping Logic ---
        % Calculate the width of the input and output hue ranges.
        inputWidth = mod(inputMax - inputMin, 1);
        if inputWidth < 1e-6; inputWidth = 1; end % Avoid division by zero.

        % Determine the relative position of each target hue within the input range.
        distFromMin = mod(targetHues - inputMin, 1);
        relativeHuePos = distFromMin / inputWidth;

        % Calculate the width of the output range.
        outputWidth = mod(outputMax - outputMin, 1);
        if outputWidth < 1e-6; outputWidth = 1; end

        % Map the relative positions to the new output range.
        mappedHues = mod(outputMin + relativeHuePos * outputWidth, 1);

        % Create a new hue channel with the remapped hues.
        newH = h;
        newH(finalMask) = mappedHues;

        % Desaturate pixels that were not part of the final mask.
        newS = s;
        newS(~finalMask) = 0; % Set saturation to 0 (grayscale).

        % Recombine the new hue and saturation channels with the original value channel.
        finalHsvImage = cat(3, newH, newS, v);
        % Convert the final HSV image back to RGB for display.
        outputImage = hsv2rgb(finalHsvImage);
    end

    function plotInputHistogram()
        % Calculates and displays the hue histogram for the original image.
        if isempty(originalImage)
            cla(handles.inputHueHistogramAxes);
            return;
        end
        % Clear previous histogram bars.
        cla(handles.inputHueHistogramAxes);
        hold(handles.inputHueHistogramAxes, 'on');

        % Calculate and plot histogram.
        [counts, edges] = calculateHueHistogram(originalImage);
        binCenters = edges(1:end-1) + 0.5;
        bar(handles.inputHueHistogramAxes, binCenters, counts, 'BarWidth', 1);

        % Adjust axis limits for clarity.
        set(handles.inputHueHistogramAxes, 'XLim', [0 360]);
        newYLim = [0 max(counts)*1.05];
        if all(newYLim == 0); newYLim = [0 1]; end
        set(handles.inputHueHistogramAxes, 'YLim', newYLim);

        % Redraw the vertical range indicator lines.
        % These lines are stored in handles and need to be re-plotted or updated.
        handles.inputMinLine.YData = newYLim;
        handles.inputMaxLine.YData = newYLim;

        hold(handles.inputHueHistogramAxes, 'off');
    end

    function initializeHueControls()
        % Sets up the hue-related visual controls: the reference spectrum and histogram axes.

        % Create and display the reference hue spectrum image.
        spectrumImage = createHueSpectrumImage();
        imshow(spectrumImage, 'Parent', handles.referenceHueSpectrumAxes);
        set(handles.referenceHueSpectrumAxes, 'XTick', [], 'YTick', [], 'Box', 'on', 'XLim', [0 360], 'YLim', [0 20]);

        % Configure properties for both histogram axes.
        allHistAxes = [handles.inputHueHistogramAxes, handles.outputHueHistogramAxes];
        set(allHistAxes, 'Box', 'on', 'XLim', [0 360], 'YLim', [0 1]);
        xlabel(handles.inputHueHistogramAxes, 'Hue Angle (0-360)');
        xlabel(handles.outputHueHistogramAxes, 'Hue Angle (0-360)');

        % Enable holding to overlay plots (lines on top of bars).
        hold(handles.inputHueHistogramAxes, 'on');
        hold(handles.outputHueHistogramAxes, 'on');

        % Create and store handles for the draggable vertical lines on histograms.
        handles.inputMinLine = plot(handles.inputHueHistogramAxes, [350 350], [0 1], 'k', 'LineWidth', 1.5);
        handles.inputMaxLine = plot(handles.inputHueHistogramAxes, [10 10], [0 1], 'k', 'LineWidth', 1.5);
        handles.outputMinLine = plot(handles.outputHueHistogramAxes, [0 0], [0 1], 'k', 'LineWidth', 1.5);
        handles.outputMaxLine = plot(handles.outputHueHistogramAxes, [360 360], [0 1], 'k', 'LineWidth', 1.5);

        % Release the hold.
        hold(handles.inputHueHistogramAxes, 'off');
        hold(handles.outputHueHistogramAxes, 'off');

        % Link numeric edit fields to update the position of their corresponding lines.
        handles.inputMinEdit.ValueChangedFcn = @(src, ~) updateLineAndProcess(src, handles.inputMinLine);
        handles.inputMaxEdit.ValueChangedFcn = @(src, ~) updateLineAnd-process(src, handles.inputMaxLine);
        handles.outputMinEdit.ValueChangedFcn = @(src, ~) updateLineAndProcess(src, handles.outputMinLine);
        handles.outputMaxEdit.ValueChangedFcn = @(src, ~) updateLineAndProcess(src, handles.outputMaxLine);
    end

    function updateLineAndProcess(editField, lineHandle)
        % Callback for when a hue range edit field is changed.
        newValue = editField.Value;
        set(lineHandle, 'XData', [newValue newValue]); % Move the vertical line.
        updateView(); % Re-process the image.
    end

    function spectrumImg = createHueSpectrumImage()
        % Creates a simple 20x360 RGB image representing the full hue spectrum.
        hue_row = linspace(0, 1, 360);      % Hue values from 0 to 1.
        hue = repmat(hue_row, 20, 1);       % Repeat row to create a 20-pixel high image.
        saturation = ones(20, 360);         % Full saturation.
        value = ones(20, 360);              % Full value/brightness.

        % Combine channels into an HSV image and convert to RGB.
        hsvImage = cat(3, hue, saturation, value);
        spectrumImg = hsv2rgb(hsvImage);
    end

    function [counts, edges] = calculateHueHistogram(rgbImage)
        % Calculates the histogram of hue values for a given RGB image.
        if isempty(rgbImage)
            counts = zeros(1, 360);
            edges = 0:1:360;
            return;
        end

        hsvImage = rgb2hsv(rgbImage);
        % Extract Hue channel and scale from 0-1 to 0-360.
        hueChannel = hsvImage(:,:,1) * 360;
        % Calculate histogram with 360 bins (one for each degree).
        [counts, edges] = histcounts(hueChannel(:), 0:1:360);
    end
end
