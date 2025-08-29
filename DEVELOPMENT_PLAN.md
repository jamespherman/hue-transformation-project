This document tracks the development of the Hue-Expansion Tool. The original plan based on App Designer was replaced by a new plan to build the UI programmatically.

## Completed

### Phase 1: Programmatic UI Generation
- [x] Task 1.1: Create Main App File and Figure (`runHueExpansionApp.m`).
- [x] Task 1.2: Set Up the Layout Manager (`uigridlayout` with two columns).
- [x] Task 1.3: Programmatically Create Image Axes (`uiaxes` for original and processed images).
- [x] Task 1.4: Programmatically Create Control Panel and Components (`uipanel`, `uibutton`, `uislider`, `uicheckbox`).

### Phase 2: Implementing Core Functionality
- [x] Task 2.1: Implement Image Loading Callback (`loadImageCallback`).
- [x] Task 2.2: Implement the Processing Logic (`processImage`).
- [x] Task 2.3 & 2.4: Create and Link the Main Update Callback (`updateView` linked to all controls).

### Phase 3: Refinement and User Experience
- [x] Task 3.1: Add `uieditfield('numeric')` components and link their callbacks to the sliders for two-way synchronization.
- [x] Task 3.2: Add logic at the start of the main script to check for and load the default endoscopic image (`your_endoscopic_image.jpg`).
- [x] Task 3.3: Add a 'Save Processed Image' button (`uibutton`) and write its associated callback function.
- [x] Task 3.4: Implement `try/catch` blocks within the callbacks for robust error handling.
- [x] Task 3.5: Update `README.md` and `DEVELOPMENT_PLAN.md` to reflect the new architecture.

### Phase 4: Visual Hue Remapping
- [x] Task 4.1: Replace "Hue Center" and "Hue Width" sliders with two `uiaxes` for visual range selection.
- [x] Task 4.2: Generate and display the hue spectrum on the new axes.
- [x] Task 4.3: Implement draggable markers (`imline`) for defining input and output hue ranges.
- [x] Task 4.4: Rewrite `processImage` to use marker positions for hue selection and remapping, including handling of circular hue space.
- [x] Task 4.5: Connect marker callbacks to `updateView` for real-time updates.
- [x] Task 4.6: Remove the "Shift Output Spectrum" checkbox and associated logic.
- [x] Task 4.7: Update documentation (`README.md`, `DEVELOPMENT_PLAN.md`) to reflect the new feature.

### Phase 5: Interactive Hue Histograms
- [x] Task 5.1: Revise control panel layout to replace static spectra with three new axes for histograms and a reference spectrum.
- [x] Task 5.2: Implement a helper function to calculate hue histograms from an RGB image.
- [x] Task 5.3: Implement a static hue histogram for the original image, which updates when a new image is loaded.
- [x] Task 5.4: Implement a dynamic hue histogram for the processed image, which updates in real-time.
- [x] Task 5.5: Add a static reference hue spectrum for user orientation.
- [x] Task 5.6: Ensure draggable range markers are correctly overlaid and functional on the new histogram axes.
- [x] Task 5.7: Update project documentation to reflect the new histogram-based interface.