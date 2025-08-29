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
    controlGrid = uigridlayout(controlPanel, [7, 3]);
    controlGrid.RowHeight = [40, 40, 22, 22, 22, 22, 40]; % Added row for save button
    controlGrid.ColumnWidth = {'fit', '1x', 50};

    % Load Image Button
    handles.loadImageButton = uibutton(controlGrid, 'Text', 'Load Image');
    handles.loadImageButton.Layout.Row = 1;
    handles.loadImageButton.Layout.Column = [1, 3];

    % Save Image Button
    handles.saveImageButton = uibutton(controlGrid, 'Text', 'Save Processed Image');
    handles.saveImageButton.Layout.Row = 2;
    handles.saveImageButton.Layout.Column = [1, 3];

    % --- Hue Center ---
    lbl1 = uilabel(controlGrid, 'Text', 'Hue Center');
    lbl1.Layout.Row = 3;
    handles.hueCenterSlider = uislider(controlGrid, 'Limits', [0, 360], 'Value', 180);
    handles.hueCenterSlider.Layout.Row = 3;
    handles.hueCenterSlider.Layout.Column = 2;
    handles.hueCenterEdit = uieditfield(controlGrid, 'numeric', 'Value', 180, 'Limits', [0, 360]);
    handles.hueCenterEdit.Layout.Row = 3;
    handles.hueCenterEdit.Layout.Column = 3;

    % --- Hue Width ---
    lbl2 = uilabel(controlGrid, 'Text', 'Hue Width');
    lbl2.Layout.Row = 4;
    handles.hueWidthSlider = uislider(controlGrid, 'Limits', [0, 360], 'Value', 90);
    handles.hueWidthSlider.Layout.Row = 4;
    handles.hueWidthSlider.Layout.Column = 2;
    handles.hueWidthEdit = uieditfield(controlGrid, 'numeric', 'Value', 90, 'Limits', [0, 360]);
    handles.hueWidthEdit.Layout.Row = 4;
    handles.hueWidthEdit.Layout.Column = 3;

    % --- Saturation Threshold ---
    lbl3 = uilabel(controlGrid, 'Text', 'Sat Thresh');
    lbl3.Layout.Row = 5;
    handles.saturationSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.saturationSlider.Layout.Row = 5;
    handles.saturationSlider.Layout.Column = 2;
    handles.saturationEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'Format', '%.2f');
    handles.saturationEdit.Layout.Row = 5;
    handles.saturationEdit.Layout.Column = 3;

    % --- Value Threshold ---
    lbl4 = uilabel(controlGrid, 'Text', 'Val Thresh');
    lbl4.Layout.Row = 6;
    handles.valueSlider = uislider(controlGrid, 'Limits', [0, 1], 'Value', 0.1);
    handles.valueSlider.Layout.Row = 6;
    handles.valueSlider.Layout.Column = 2;
    handles.valueEdit = uieditfield(controlGrid, 'numeric', 'Value', 0.1, 'Limits', [0, 1], 'Format', '%.2f');
    handles.valueEdit.Layout.Row = 6;
    handles.valueEdit.Layout.Column = 3;

    % --- Shift Spectrum Checkbox ---
    handles.shiftSpectrumCheckbox = uicheckbox(controlGrid, 'Text', 'Shift Output Spectrum');
    handles.shiftSpectrumCheckbox.Layout.Row = 7;
    handles.shiftSpectrumCheckbox.Layout.Column = [1, 3];

    % --- Callbacks ---
    handles.loadImageButton.ButtonPushedFcn = @loadImageCallback;
    handles.saveImageButton.ButtonPushedFcn = @saveImageCallback;

    % Synchronization and update callbacks
    handles.hueCenterSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.hueCenterEdit);
    handles.hueCenterEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.hueCenterSlider);

    handles.hueWidthSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.hueWidthEdit);
    handles.hueWidthEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.hueWidthSlider);

    handles.saturationSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationEdit);
    handles.saturationEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.saturationSlider);

    handles.valueSlider.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueEdit);
    handles.valueEdit.ValueChangedFcn = @(src, ~) syncAndUpdate(src, handles.valueSlider);

    handles.shiftSpectrumCheckbox.ValueChangedFcn = @updateView;

    % --- App Startup ---
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

        % Get parameter values from UI
        hueCenter = handles.hueCenterSlider.Value / 360; % Normalize to [0,1]
        hueWidth = handles.hueWidthSlider.Value / 360;   % Normalize to [0,1]
        satThreshold = handles.saturationSlider.Value;
        valThreshold = handles.valueSlider.Value;
        shiftOutput = handles.shiftSpectrumCheckbox.Value;

        % Convert to HSV
        hsvImage = rgb2hsv(originalImage);
        h = hsvImage(:,:,1);
        s = hsvImage(:,:,2);
        v = hsvImage(:,:,3);

        % Create a mask for pixels to process
        mask = (s >= satThreshold) & (v >= valThreshold);

        % Calculate angular distance from the center hue
        dist = abs(h - hueCenter);
        dist = min(dist, 1 - dist); % Handle wrap-around distance

        % Create a mask for hues within the specified width
        hueMask = (dist <= hueWidth / 2);

        % Combine masks
        finalMask = mask & hueMask;

        % Get hue values to be expanded
        targetHues = h(finalMask);

        % Perform hue expansion
        % Calculate distance from lower bound of the hue window
        lowerBound = hueCenter - hueWidth / 2;
        hueDistFromLower = targetHues - lowerBound;

        % Handle negative results from wrap-around
        hueDistFromLower(hueDistFromLower < 0) = hueDistFromLower(hueDistFromLower < 0) + 1;

        % Scale the hue to the full [0, 1] range
        expandedHues = hueDistFromLower / hueWidth;

        % Apply shift if checked
        if shiftOutput
            expandedHues = mod(expandedHues + 0.5, 1);
        end

        % Create a new hue channel
        newH = h;
        newH(finalMask) = expandedHues;

        % Recombine channels and convert back to RGB
        finalHsvImage = cat(3, newH, s, v);
        outputImage = hsv2rgb(finalHsvImage);
    end
end
