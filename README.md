# Hue-Expansion Interactive Tool

## Synopsis

This tool is a MATLAB application for visualizing hue expansion transformations on images, designed for research and educational purposes in fields like medical imaging and visual neuroscience.

## Core Features

* Load standard image formats (JPG, PNG, etc.).
* Real-time preview of a processed image alongside the original.
* Interactive histogram controls for hue remapping. The interface displays two histograms for the hue distributions of the original and processed images, allowing users to drag markers to define the input and output ranges directly on the data. A static reference spectrum is also provided.
* Sliders for adjusting saturation and value thresholds.
* Ability to save the processed image.
* Automatically loads `your_endoscopic_image.jpg` if present in the directory on startup.

## Technology

This application is built using MATLAB, with a programmatically generated user interface.

## How to Run

To run the application, open MATLAB, navigate to the project directory, and run the `runHueExpansionApp.m` script from the command window or editor.