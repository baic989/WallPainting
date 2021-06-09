# Naive wall painting 1.0

## About
Wall painting poses a difficult problem in terms of plane segmentation and edge detection.

This version of the app implements the "naive" approach using Apples's own ARKit vertical plane detection.
As can be seen, it is far from perfect.

Using LIDAR vastly improves vertical plane detection, but it also doesn't take occluding objects into consideration.
For current version of the app, LIDAR wasn't implemented because of my testing limitations.

## Installing and testing

Development and testing done on iPhone 11 running iOS 13.7; Xcode 12.4.
The best experience would be using 13 < iOS < 14.
The lowest supported version is iOS 13.

To run the project clone or download the code. To run on device you must change the bundle identifier and select a team (doesn't have to be paid, just an AppleID user will be fine). If you are testing on device that has a different AppleID than Xcode, you may need to trust the computer when connecting the iPhone and under iPhone Settings > General > Device management select *"Apple development: [your apple ID]"* to trust the developer.

## Known issues

Testing on iOS 14, it turns out that hit test has been deprecated, but not only deprecated, it doesn't work at all with SceneKit so for that I used ray tracing instead. Doing so, retrieving the node from the traced anchor has some sort of issue that causes the node to lose the geometry (shape, position. color etc.).

Reconstructing the node causes the colors flickering and shades being off (pale).

## Future work

Future experimental versions will utilize OpenCV for segmentation, tracking and coloring.
