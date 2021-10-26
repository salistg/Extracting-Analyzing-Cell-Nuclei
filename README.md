# Extracting and Analyzing Cell Nuclei
A project that uses image processing to extract and analyze cell nuclei in plant stems.


TO RUN THE nucleiAnalysis FUNCTION:

SETTING UP:

1- Unzip the 'COMP2032-ELSAID-20050927' ZIP file to get the 'COMP2032-ELSAID-20050927' folder.

The folder extracted from the ZIP file should contain 4 items:
   1. Matlab Codes folder
   2. COMP2032-REPORT-20050927 file (academic report)
   3. COMP2032-VIDEO-20050927 file (demonstration video)
   4. README.txt file

2- Open the 'Matlab Codes' folder in Matlab by pasting the address of the folder in Matlab's
address bar or by navigating to the folder.

This should show the following 5 files in the 'Current Folder' pane on the left side:
   1. main.m
   2. nucleiAnalysis.m
   3. StackNinja1.bmp
   4. StackNinja2.bmp
   5. StackNinja3.bmp


RUNNING THE FUNCTION:

1- Open the main.m file by double clicking on it from the 'Current Folder' pane on the left.

2- To run the function with your image:
      a- Make sure the image is at the same location as the main.m and nucleiAnalysis.m files.
      b- Insert the image file name into the nucleiAnalysis function between the brackets.
         For example, if your image's name is 'Image1.bmp' then it will be: nucleiAnalysis('Image.bmp');
      c- Press the Run button or type 'run main.m' (without quotes) in the command window

If you would like to run the function on any of the StackNinja.bmp images, without having to manually
input the image file name, you can uncomment one of the 'input_image = 'StackNinjaX.bmp' lines and
comment the others.

For example, for stackNinja1.bmp:

input_image = 'StackNinja1.bmp';
%input_image = 'StackNinja2.bmp';
%input_image = 'StackNinja3.bmp';

for StackNinja2.bmp:

%input_image = 'StackNinja1.bmp';
input_image = 'StackNinja2.bmp';
%input_image = 'StackNinja3.bmp';

and for StackNinja3.bmp:

%input_image = 'StackNinja1.bmp';
%input_image = 'StackNinja2.bmp';
input_image = 'StackNinja3.bmp';

Then press the Run button or type in 'run main.m' in the command window.
