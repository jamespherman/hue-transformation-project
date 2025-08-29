# Hue-Expansion Interactive Tool

## Synopsis

This tool is a MATLAB application for visualizing and performing hue expansion transformations on images. It is designed for research and educational purposes, particularly in fields like medical imaging, materials science, and visual neuroscience where specific hue ranges carry significant information. The application provides a graphical user interface (GUI) to interactively select a range of hues from an original image and remap them to a new, expanded or altered range in a processed image.

## Core Features

* **Image Loading**: Supports standard image formats (e.g., JPG, PNG, TIFF).
* **Dual Image View**: Displays the original and processed images side-by-side for immediate comparison.
* **Interactive Hue Histograms**:
    * **Input Histogram**: Visualizes the hue distribution of the original image. Users can define the source hue range using two vertical markers controlled by numeric input fields.
    * **Output Histogram**: Visualizes the hue distribution of the processed image in real-time. The target hue range is also defined by markers linked to numeric inputs.
* **Hue Remapping**: Pixels within the selected input hue range (and satisfying saturation/value thresholds) are remapped to the output range. The remapping preserves the relative distribution of hues.
* **Desaturation of Non-Selected Pixels**: All pixels outside the selected hue, saturation, and value range are desaturated (converted to grayscale), effectively isolating the remapped colors.
* **Saturation and Value Thresholds**: Sliders and corresponding numeric fields allow users to set minimum saturation and value (brightness) levels. Only pixels that meet these criteria are processed, which helps in excluding grayscale or dark regions from hue manipulation.
* **Reference Hue Spectrum**: A static spectrum image is displayed as a visual aid for identifying and selecting hues.
* **Save Functionality**: The processed image can be saved in various standard formats.
* **Default Image**: Automatically loads `your_endoscopic_image.jpg` on startup if it is present in the application's directory.

## How It Works

The core of the application operates in the HSV (Hue, Saturation, Value) color space.

1.  **Conversion to HSV**: The input RGB image is converted to HSV.
2.  **Masking**: A binary mask is created to identify pixels that fall within the user-defined `input` hue range and exceed the `saturation` and `value` thresholds.
3.  **Hue Remapping**:
    * For each pixel identified by the mask, its hue value is normalized based on its position within the input hue range (e.g., a hue exactly in the middle of the input range gets a relative position of 0.5).
    * This relative position is then used to calculate a new hue value within the `output` hue range. This ensures that the "gradient" or relative ordering of the original hues is preserved in the remapped output.
    * The application correctly handles the circular nature of the hue space (where 359 degrees is adjacent to 0 degrees).
4.  **Desaturation**: A new saturation channel is created where pixels not included in the mask have their saturation set to 0.
5.  **Recombination and Conversion**: The new hue and saturation channels are combined with the original value channel to form a new HSV image, which is then converted back to RGB for display.

## Technology

This application is built entirely in **MATLAB** using its programmatic UI-building tools (i.e., `uifigure` and `uigridlayout`). It does not rely on GUIDE or App Designer, making the code self-contained and transparent.

## How to Run

1.  Ensure you have MATLAB installed with the Image Processing Toolbox.
2.  Open MATLAB.
3.  Navigate to the directory containing the `runHueExpansionApp.m` file.
4.  Run the script by typing `runHueExpansionApp` in the MATLAB Command Window or by opening the file in the editor and pressing the "Run" button.