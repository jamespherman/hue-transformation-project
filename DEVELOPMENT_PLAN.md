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
