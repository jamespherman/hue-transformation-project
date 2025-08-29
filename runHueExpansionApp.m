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
    controlGrid = uigridlayout(controlPanel, [8, 3]);
    controlGrid.RowHeight = [40, 40, 22, 60, 22, 60, 22, 22];
    controlGrid.ColumnWidth = {'fit', '1x', 50};

    % Load Image Button
    handles.loadImageButton = uibutton(controlGrid, 'Text', 'Load Image');
    handles.loadImageButton.Layout.Row = 1;
    handles.loadImageButton.Layout.Column = [1, 3];

    % Save Image Button
    handles.saveImageButton = uibutton(controlGrid, 'Text', 'Save Processed Image');
    handles.saveImageButton.Layout.Row = 2;
    handles.saveImageButton.Layout.Column = [1, 3];

    % --- Input Hue Range ---
    lbl1 = uilabel(controlGrid, 'Text', 'Input Hue Range');
    lbl1.Layout.Row = 3;          % Set the row
    lbl1.Layout.Column = [1, 3];  % Set the columns
    handles.inputHueAxes = uiaxes(controlGrid);
    handles.inputHueAxes.Layout.Row = 4;
    handles.inputHueAxes.Layout.Column = [1, 3];
    handles.inputHueAxes.XTick = [];
    handles.inputHueAxes.YTick = [];
    disableDefaultInteractivity(handles.inputHueAxes);

    % --- Output Hue Range ---
    lbl2 = uilabel(controlGrid, 'Text', 'Output Hue Range');
    lbl2.Layout.Row = 5;
    lbl2.Layout.Column = [1, 3];
    handles.outputHueAxes = uiaxes(controlGrid);
    handles.outputHueAxes.Layout.Row = 6;
    handles.outputHueAxes.Layout.Column = [1, 3];
    handles.outputHueAxes.XTick = [];
    handles.outputHueAxes.YTick = [];
    disableDefaultInteractivity(handles.outputHueAxes);

    % --- Saturation Threshold ---
    lbl3 = uilabel(controlGrid, 'Text', 'Sat Thresh');
    lbl3.Layout.Row = 7;
    handles.saturationSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.saturationSlider.Layout.Row = 7;
    handles.saturationSlider.Layout.Column = 2;
    handles.saturationEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.saturationEdit.Layout.Row = 7;
    handles.saturationEdit.Layout.Column = 3;

    % --- Value Threshold ---
    lbl4 = uilabel(controlGrid, 'Text', 'Val Thresh');
    lbl4.Layout.Row = 8;
    handles.valueSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.valueSlider.Layout.Row = 8;
    handles.valueSlider.Layout.Column = 2;
    handles.valueEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'ValueDisplayFormat', '%.2f');
    handles.valueEdit.Layout.Row = 8;
    handles.valueEdit.Layout.Column = 3;

    % --- Callbacks ---
    handles.loadImageButton.ButtonPushedFcn = @loadImageCallback;
    handles.saveImageButton.ButtonPushedFcn = @saveImageCallback;

    % Synchronization and update callbacks
    handles.saturationSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationEdit);
    handles.saturationEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationSlider);

    handles.valueSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueEdit);
    handles.valueEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueSlider);

    % --- App Startup ---
    initializeHueAxes();
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

            % Update view immediately after loading
            updateView();
        catch ME
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
            else
                % Clear axes if there's no image to process
                imshow([], 'Parent', handles.processedAxes);
                handles.processedAxes.Title.String = 'Processed Image';
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

        % Get marker positions and normalize from [0, 360] to [0, 1]
        inputMinPos = getPosition(handles.inputMinLine);
        inputMin = inputMinPos(1,1) / 360;
        inputMaxPos = getPosition(handles.inputMaxLine);
        inputMax = inputMaxPos(1,1) / 360;

        outputMinPos = getPosition(handles.outputMinLine);
        outputMin = outputMinPos(1,1) / 360;
        outputMaxPos = getPosition(handles.outputMaxLine);
        outputMax = outputMaxPos(1,1) / 360;

        satThreshold = handles.saturationSlider.Value;
        valThreshold = handles.valueSlider.Value;

        % Convert to HSV
        hsvImage = rgb2hsv(originalImage);
        h = hsvImage(:,:,1);
        s = hsvImage(:,:,2);
        v = hsvImage(:,:,3);

        % Create a mask for pixels to process based on saturation and value
        satValMask = (s >= satThreshold) & (v >= valThreshold);

        % Create a mask for hues within the input range
        if inputMin <= inputMax
            hueMask = (h >= inputMin) & (h <= inputMax);
        else % Handle wrap-around case
            hueMask = (h >= inputMin) | (h <= inputMax);
        end

        % Combine masks
        finalMask = satValMask & hueMask;

        % Get original hues of the pixels to be changed
        targetHues = h(finalMask);

        % Calculate normalized distance from the input minimum
        inputWidth = mod(inputMax - inputMin, 1);
        if inputWidth < 1e-6; inputWidth = 1; end % Avoid division by zero if range is full circle or tiny

        distFromMin = mod(targetHues - inputMin, 1);

        % Scale to a [0, 1] range representing position within the input window
        relativeHuePos = distFromMin / inputWidth;

        % Map to the output range
        outputWidth = mod(outputMax - outputMin, 1);
        if outputWidth < 1e-6; outputWidth = 1; end

        mappedHues = mod(outputMin + relativeHuePos * outputWidth, 1);

        % Create a new hue channel and update the selected pixels
        newH = h;
        newH(finalMask) = mappedHues;

        % Recombine channels and convert back to RGB
        finalHsvImage = cat(3, newH, s, v);
        outputImage = hsv2rgb(finalHsvImage);
    end

    function initializeHueAxes()
        % Create and display the hue spectrum image on both axes
        spectrumImage = createHueSpectrumImage();
        imshow(spectrumImage, 'Parent', handles.inputHueAxes);
        imshow(spectrumImage, 'Parent', handles.outputHueAxes);

        % Set axis properties
        set([handles.inputHueAxes, handles.outputHueAxes], ...
            'XTick', [], 'YTick', [], 'Box', 'on', 'XLim', [0 360], 'YLim', [0 1]);

        % Create draggable lines (imline) for input and output ranges
        % Input range defaults to a narrow red band (e.g., 350 to 10 degrees)
        handles.inputMinLine = imline(handles.inputHueAxes, [350 350], [0 1]);
        handles.inputMaxLine = imline(handles.inputHueAxes, [10 10], [0 1]);

        % Output range defaults to the full spectrum
        handles.outputMinLine = imline(handles.outputHueAxes, [0 0], [0 1]);
        handles.outputMaxLine = imline(handles.outputHueAxes, [360 360], [0 1]);

        % Customize line appearance
        allLines = [handles.inputMinLine, handles.inputMaxLine, handles.outputMinLine, handles.outputMaxLine];
        setColor(allLines, [0.9 0.9 0.9]); % Light gray for better visibility

        % Set constraints for dragging
        fcn = makeConstrainToRectFcn('imline', get(handles.inputHueAxes,'XLim'), [0 1]);
        setPositionConstraintFcn(handles.inputMinLine, fcn);
        setPositionConstraintFcn(handles.inputMaxLine, fcn);

        fcn_out = makeConstrainToRectFcn('imline', get(handles.outputHueAxes,'XLim'), [0 1]);
        setPositionConstraintFcn(handles.outputMinLine, fcn_out);
        setPositionConstraintFcn(handles.outputMaxLine, fcn_out);

        % Add callbacks to update the view when lines are moved
        addNewPositionCallback(handles.inputMinLine, @(pos) updateView());
        addNewPositionCallback(handles.inputMaxLine, @(pos) updateView());
        addNewPositionCallback(handles.outputMinLine, @(pos) updateView());
        addNewPositionCallback(handles.outputMaxLine, @(pos) updateView());
    end

    function spectrumImg = createHueSpectrumImage()
        % Creates a 1x360x3 HSV image representing the hue spectrum
        % and converts it to an RGB image.
        hue = linspace(0, 1, 360); % Hue from 0 to 1
        saturation = ones(1, 360); % Full saturation
        value = ones(1, 360);      % Full value/brightness

        hsvImage = cat(3, reshape(hue, [1, 360, 1]), ...
                          reshape(saturation, [1, 360, 1]), ...
                          reshape(value, [1, 360, 1]));

        spectrumImg = hsv2rgb(hsvImage);
    end
end
