# iCRAQ
ImageJ macro developed to analyse chromocenters in plant nucleus

This macros rely on **ActionBar** plugin which can be download here: https://figshare.com/articles/Custom_toolbars_and_mini_applications_with_Action_Bar/3397603/3

And also use **ImageScience** pluging and **SCF MPI CBG** plugin which can be added through their update site in ImageJ (https://sites.imagej.net/ImageScience/ and https://sites.imagej.net/SCF-MPI-CBG/ respectively).

To run iCRAQ place *iCRAQ_main.txt* in a folder named "iCRAQ" inside macros folder of ImageJ, launch ImageJ then go into *Plugins>>Macros>>Run...* and choose the *iCRAQ_main.txt* file.

![iCRAQ launch](iCRAQ_001.png)

Then **drag and drop** one (or more) *.tif* (or *.lif*) files of microscopy z-stack on the iCRAQ buttons menu, the macro will open the first file (or the first serie of the first *.lif* file). Tune the options via the **Option** button if needed (see the *options.txt* for more details) then proceed with the nucleus detection by clicking on **Detect Nucleus**.

![iCRAQ nucleus](iCRAQ_002.png)

Missed nuclei can be added (one at a time) by clicking on the **Manualy Add Nucleus** button and then using the *freehand* tool (or any other ROI drawing tools). Conversly, unwanted nuclei ROIs can also be removed (one at a time) with the **Remove Nucleus** button and then choosing the ROI og the unwanted nucleus in the *Roi manager*. The **Fuse Nucleus** button is mainly used to fuse elongated nuclei that have been cut by the nucleus detection process or to group nuclei to be removed.

![iCRAQ fuse1](iCRAQ_003.png)
![iCRAQ fuse2](iCRAQ_004.png)

Proceed with the chromocenter detection hitting the **Detect Chromocenter** button. Each detected nuclei will be analysed separatedly. A first dialog panel allows to skip the chromocenter detection of the current nucleus by answering *Yes*, otherwise you will be asked to adjust the slider of the *H-watershed* to get a good segmentation of the chromocenters. The *View image* in the *H-watershed* plugin menu allow to choose between the chromocenter *features* (corresponding to the projection of the first eigenvalue of the structure tensor) or the projection of the original stack. Then export the chromocenters mask via the *H-watershed* plugin menu and click *Ok* to proceed to the next nucleus. Note that the *H-watershed* plugin run in a java window that cannot be closed easily via ImageJ macro language.

![iCRAQ chromocenter1](iCRAQ_005.png)
![iCRAQ chromocenter2](iCRAQ_006.png)

As for nuclei, missed chromocenter can be added manualy with the **Manualy add Chromocenter** button and first selecting the nucleus from which the missed chromocenter belong to and then drawing it manualy. Chromocenters can also be removed with the **Remove Chromocenter** button and clicking the ROI of the unwanted chromocenter. Quality of the segmentation can be shown on the 2D projection via the **Show On Projection** button before performing the quantification (close the projection before running the quantification).

![iCRAQ projection](iCRAQ_007.png)

The segmentation can then be saved using **Save annotations** which will first ask the name of the annotation image, then the folder and will save a *.tif* image with 2 or 3 gray levels: 0 for background, 128 for nuclei (if chromocenters are presents, 255 otherwise) and 255 for chromocenter.

![iCRAQ annotation](iCRAQ_008.png)

Finaly, the **Analyse Selections (2D)** will ask for a result file name, perform the quantification of different ROI parameter and save the informations in 2 *.txt* files one with nuclei informations (including the number of chromocenter then contains and the RHF, RAF...) and another one with each chromocenter informations. Note that the data from different images corresponding to the same serie can be appended in one unique file by providing the same result file name and not checking the *Delete if exit* option.

![iCRAQ quantification](iCRAQ_009.png)

This macro was developed during an internship in IBENS under the supervision of Fredy Barneche and Clara Bourbousse.
