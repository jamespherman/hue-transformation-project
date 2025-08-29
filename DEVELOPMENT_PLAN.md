# Development Plan: Programmatic GUI

This document outlines the development tasks for creating the Hue-Expansion Tool with a programmatic MATLAB GUI.

## Phase 1: Programmatic UI Generation

- [ ] **Task 1.1: Create Main App File and Figure**
  - Create a new MATLAB script named `runHueExpansionApp.m`.
  - The main function will create the UI.
  - Create the main figure window using `uifigure` with the title 'Hue Expansion Tool'.

- [ ] **Task 1.2: Set Up the Layout Manager**
  - Create a `uigridlayout` in the main figure.
  - Configure the grid to have 2 columns.
  - Set `ColumnWidth` to `{250, '1x'}`.

- [ ] **Task 1.3: Programmatically Create Image Axes**
  - Create a nested `uigridlayout` in the right column of the main grid.
  - The nested grid should have 2 rows.
  - Add a `uiaxes` in the top row for the original image.
  - Add a `uiaxes` in the bottom row for the processed image.
  - Set titles and disable ticks for both axes.

- [ ] **Task 1.4: Programmatically Create Control Panel and Components**
  - Create a `uipanel` titled 'Controls' in the left column.
  - Inside the panel, create all UI components (`uibutton`, `uislider`, `uicheckbox`, `uilabel`).
  - Set their default properties (text, range, initial values).
  - Store component handles in a structured variable.

## Phase 2: Implementing Core Functionality

- [ ] **Task 2.1: Implement Image Loading Callback**
  - Write a local function `loadImageCallback`.
  - The function will handle opening a file dialog and displaying the selected image.
  - Assign its handle (`@loadImageCallback`) to the 'Load Image' button's `ButtonPushedFcn`.

- [ ] **Task 2.2: Implement the Processing Logic**
  - Write a local function `processImage`.
  - This function will contain the core hue expansion logic.
  - It should read current values from the UI components.

- [ ] **Task 2.3 & 2.4: Create and Link the Main Update Callback**
  - Write a central callback function `updateView`.
  - This function will call `processImage` and update the processed image axes.
  - Assign its handle (`@updateView`) to the `ValueChangedFcn` of all sliders and the checkbox.

## Phase 3: Refinement and User Experience

- [ ] **Task 3.1: Add Numeric Edit Fields**
  - Add `uieditfield('numeric')` components for each slider.
  - Link their callbacks to the sliders.

- [ ] **Task 3.2: Default Image Loading**
  - Add logic at the start of the script to check for and load a default endoscopic image.

- [ ] **Task 3.3: Save Image Functionality**
  - Add a 'Save Processed Image' `uibutton`.
  - Write the associated callback function to save the processed image.

- [ ] **Task 3.4: Error Handling**
  - Implement `try/catch` blocks within callbacks for robust error handling.
