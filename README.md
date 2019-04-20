# Phobos

Phobos Version 1.0 – April 19, 2019
Distributed by Felippe E. Amorim, Thiago C. Moulin and Olavo B. Amaral.
====================================================================

This pdf file describes how to use Phobos

====================================================================
WHAT IS PHOBOS?
Phobos is a software for the automated analysis of freezing behavior in rodents. Unlike other programs, it uses manual quantification of a short video to calibrate parameters for optimal freezing detection. Phobos works with 3 user interfaces (UIs) for this purpose. The main user UI is where the user loads videos for quantification, defines an output folder and creates the .xls file with the results. The Video Parameters UI, is where the user defines the beginning and end times for freezing detection in the videos and crops the image to restrict the analysis to a specific area. Finally, the Manual Quantification UI is used to manually quantify freezing in a video, which will then be used as a reference for the calibration process.

PURPOSE OF THIS MANUAL
This manual is meant to help you to get started with Phobos. The software was designed to be simple and straightforward to use. However, some instructions are necessary for the user to understand how the system works. These instructions are also conveyed by the message boxes that appear during the process described below.

QUANTIFYING FREEZING IN A LIST OF VIDEOS

STEP 1) STARTING THE PROGRAM: 
- Operational system required: Windows
- For the software compiled version, open the Phobos.exe file. Note that this requires previous installation of Matlab Runtime Compiler 9.4 (R2018a), available for download at  http://www.mathworks.com/products/compiler/mcr/index.html
- For the Matlab code, run the Phobos_UI_V2.m file.

STEP 2) SETTING UP A VIDEO LIST
- A summarized version of these instructions is displayed on the right side of the main UI. Below is a more detailed version of the instructions displayed in the software.

2.1) DEFINING AN OUTPUT FOLDER:
- Click on the "Output Folder" button to choose the folder where output files will be saved. It is not possible to load videos without performing this step. To select a folder, click on the desired folder without open. After you start the step 2.2, do not change the folder path.
- This process is going to create four folders within the desired output folder. The “Videolist_files” folder contains the parameters selected during the ‘Load Video’ step (e.g. start, finish and crop coordinates for each video). The second folder, called “Manual_Quantification_files”, contains the user quantification files generated during the manual quantification step. The “Calibration_files” folder contains files generated during the calibration step, which will be used as a reference for automatic analysis of freezing behavior. Finally, the “Results_files” folder is the destination for the results of automatic quantification by the software.

2.2) LOAD VIDEO STEP
- For each video, the user must set the start and finish times for analysis and crop the area to be analyzed in the Video Parameters UI (see 2.3 and 2.4). Alternatively, the user can set these parameters for the first video only and use them the whole video list. To use the same start and finish time and/or the same crop for all videos that are going to be loaded, check the options "Same start and finish for the videos" and/or "Same crop for the videos" before you press the "Load Videos" button.
- After making this choice, press the “Load Videos” button and choose the video(s) to be analyzed automatically. To load multiple videos, left-click while holding Ctrl or use the arrow key while holding Shift. The videos must be in the same folder to be selected. The Video Parameters UI will open for the user to define the time and crop area in each video. 
- If one of the above mentioned checkboxes was checked before loading the videos, the software will use the same parameters used in the first loaded video. In this case, the user needs to set start and finish time and/or crop area only once. Please note that these options must be checked before loading videos: after videos have been loaded, the checkboxes will only work for the next ‘Load Video’ step.

2.3) CHOOSING START AND FINISH TIMES FOR ANALYSIS 
- After loading videos, the “Video parameters UI” appears. In this window, the slider on the top displays the video timeline. To define a start or finish point, the user can either use the slider or play the video using the "Play" and “Stop” buttons. 
- To set the timepoint for automatic quantification to start, move the cursor or play the video until the desired timepoint and press "SET START" button. The button then changes to "SET FINISH". If needed, press the "Back" button to set the start time again.
- After this, the user must define the finish time in the timeline in the same manner. If needed, press the "Return" button to set the finish time again. After you press "Set Crop", it is not possible to redefine the start and finish time.

2.4) CROPPING THE AREA OF ANALYSIS
- The last step in this window is to crop the area of analysis. This step is important to improve the signal-to-noise ratio. To do this, the user should restrict the analysis to the area in which the animal is going to move throughout the video, removing unnecessary areas. After pressing “Set Crop”, wait for the mouse pointer to become a cross and draw a rectangle over the portion of the image that you want to crop. With this area selected, double-click on the area to finish the process.

2.5) REMOVING OR ADDING MORE VIDEOS
- After returning to the main window, if you want to remove any video from the list, just click on it and press the "Remove Video" button.
- To load more videos, just press "Load Video" button. The start/finish/crop UI will appear again for the user to define the time and crop area in each selected video. As described in step 2.2, if one of the checkboxes was checked before loading the videos, the software will use the same parameters chosen for the first loaded video.

2.6) CALIBRATE PARAMETERS
- To calibrate parameters through manual quantification, press the "Calibrate the parameters" button. This will open the Manual Quantification UI with new instructions. If you already have a calibration file (e.g. from a previously performed manual quantification), press the "Run with Calibration File" button instead and skip Step 3.

STEP 3) MANUAL QUANTIFICATION
Follow the instructions displayed on the right side of the software to load your video list or read the following steps:
3.1) LOAD VIDEO STEP
- Press the "Load Videos" button and choose the video(s) that you want to quantify manually for calibration. For proper calibration, you should choose a video that was selected in the main UI video list or one recorded under the same conditions.
- Choose start and finish times as performed in step 2.3. This will choose the portion of the video that will be manually quantified and used for calibration. We recommend the use of an excerpt of at least 2 minutes containing both freezing and non-freezing periods for adequate calibration. You will not need to crop the image in this step.
It is possible to quantify more than one video in this step, but this is usually necessary only if the first video fails to yield accurate calibration (see step 3.3) It is also possible to remove videos from the list: just select the video that you want to delete in the list and click in the "Remove Video". This can be useful if the first video does not meet criteria for valid calibration (see below).

3.2) MANUALLY QUANTIFY THE SELECTED VIDEO(S) FOR CALIBRATION
Please read all the instructions in this step before starting quantification.
- Press the "Start manual scoring" button. This will start the manual quantification step for each video included in the video list. A chronometer will appear displaying the amount of freezing counted by the user.
- Press the "Freezing” button to quantify freezing behavior. When the freezing button is green and displaying “Freezing on”, the program is counting time as freezing behavior. When it is red and displaying “Freezing off”, the program is considering the animal to be moving.  
- To pause the video in the middle of the process, click the "Pause" button. To continue the process, click the "Play" button.
- If you want to stop the manual quantification process for some reason, press the "Stop Quantification" button. This process will abort the whole quantification. 
- After manual quantification is finished, Phobos will create a file with the suffix "output.mat" for each manually quantified video. If the total freezing time is less than 10 s or more than 90% of the video, we recommend using another video for the calibration process, as this is likely to yield faulty calibration. In this case, go back to the previous screen and remove the video from the list before loading a new one.

3.3) CALIBRATION
The calibration step compares the freezing value of each 20-second time bin obtained by manual quantification with the corresponding value obtained by automatic quantification using different parameters. The step aims to find the parameter combination with the best correlation with manual quantification, as measured by linear fitting. The r value and slope obtained in calibration can also be used to evaluate whether the obtained calibration is likely to generate reliable freezing assessment.
- Press the "Calibrate" button. The software will automatically load the file(s) created during the manual quantification process. One must keep the video(s) to be used for calibration in the list before doing this, as removing them will cause the software not to recognize the filename.
- Crop the image following the instructions displayed on the message box, as performed in step 2.4.
- The calibration step generates a file with the prefix "Calibration_using_". A message box will appear displaying the r value and slope for the calibration. If these values are below 0.963 for r or below 0.84 for slope, we do not recommend the use of the obtained calibration, based on tests on previous datasets, and this will be informed by the software. In this case, we recommend choosing a new video for calibration. For this, remove the poor quality video from the manual quantification list, load another video and repeat the manual quantification and calibration steps. If the obtained values meet the above-mentioned criteria, the software will display the values for r and slope with the message “Calibration Done! Close the manual quantification player to continue the process”.
- After calibration is finished, just close the manual quantification window to go on to the automatic quantification process for the remaining videos.

STEP 4) AUTOMATIC QUANTIFICATION
- Press the "Run with Calibration File" button and choose the calibration file that you want to use to quantify your video list – usually the one you have just generated by manual quantification. The calibration file is located in the “Calibration_files” folder located in the current folder that the program is running, and has the preffix "Calibration_using_").
- When quantification is started, the program will run the selected video(s) in the main UI as a black and white video and a progress box will appear showing the progress of quantification for the current video. Wait for the program to quantify all the videos in the list – which will take a variable amount of time depending on the hardware in which the program is running. For each video, a separate output file containing freezing epochs over time will be generated under the name “video name”_freezing_results_data.mat. 
ATTENTION: Do not close the program or the progress bar while automatic quantification is under way. This will interrupt the process. However, it is possible to minimize the software and progress bar while automatic quantification is running.

STEP 5) EXPORTING RESULTS TO A XLS FILE
This step uses the .mat file with the results to generate an MS-Excel file (.xls) displaying the total freezing time of each video, as well as for specific time bins with a length defined by the user. The default for the program is 20 s.
- If you want to export your data in the .mat file to a .xls file, fill in the desired time bin duration for freezing to be measured in the “Time Bin (s)” field. After this, click the "Generate .xls file" button and choose the output .mat file(s) to be used for this purpose.  These are saved under the filename: “video name”_freezing_results_data.mat in the Results_files folder. It is possible to select more than one file by using Ctrl+left click or shift+arrow key.
- The program will then ask for a destination folder and file name to save the .xls file. Once it is complete, a confirmation window will appear with this information. The .xls file will have the total freezing time for the video, as well as the freezing time for the selected time bins from all the results files selected (with the specific time bin for each video specified in the first line of the table).

