function new_image = nucleiAnalysis(in_image_name)          

%reading the image into a variable
in_image = imread(in_image_name);          

%                                                         IMAGE ENHANCEMENT

%step 1 - extracting the green channel
green_image = in_image(:,:,2);            

%step 2 - brightening the image by a factor of 0.3
image_brightened = imlocalbrighten(green_image, 0.3);        

%step 3 - clearing the border of incomplete objects
remove_border = imclearborder(image_brightened);

%step 4 - applying the median filter to reduce noise
reduce_noise = medfilt2(remove_border, [5 5]);

%step 5 - sharpening the image using the laplacian filter

%first, obtain the image's edges
laplacian_filter = fspecial('laplacian');
image_edge = imfilter(reduce_noise, laplacian_filter);

% second, subtract the edges from the image
sharpened_image = reduce_noise - image_edge;

%step 6 - applying the median filter again to remove remaining noise
noise_free_image = medfilt2(sharpened_image, [5 5]);


%                                                    NUCLEI CELLS SEGMENTATION

% creating a disk shaped structuring element with a radius of 1
SE = strel('disk', 1);

%step 1 - detecing edges using the Canny method
image_edge = edge(noise_free_image, 'canny');

%step 2 - dilating the image to connect edges
dilated_image = imdilate(image_edge, SE);

%step 3 - filling the holes in the image
filled_image = imfill(dilated_image, 'holes');

%creating another disk shaped sturctuing element but with a radius of 2
SE2 = strel('disk', 2);

%step 4 - opening the image to get rid of unneccessary edges
%and small holes
remove = imopen(filled_image, SE2);

%step 5 - removing remaining small particles
eroded_image = imerode(remove, SE);

%step 6 - removing particles less than 35 pixels 
new_image = bwareaopen(eroded_image, 35);

%applying the watershed transform

%calculating the distance transform for the complement of the image
D = bwdist(~new_image);

%negating the distance transform
D = -D;

%imposing a minima with a mask to avoid oversegmentaion
mask = imextendedmin(D, 1);
D2 = imimposemin(D, mask);

%applying the watershed function
L = watershed(D2);

%separating objects in the binary image
new_image(L == 0) = 0;

% counting the nuclei in the image
nuclei_count = bwconncomp(new_image);
number_of_nuclei = num2str(nuclei_count.NumObjects);


%                                                         DISPLAYING RESULTS

%finding out the perimeter of the nuclei detected in the image
%to overlay it 
nuclei_perimeters = bwperim(new_image);

%overlaying the nuclei detected on the input image
highlight_nuclei = imoverlay(in_image, nuclei_perimeters);

%displaying the original input image
figure
imshow(in_image)
title('Original Image')

%highlighting the nuclei detected in the original image
figure
imshow(highlight_nuclei)
title('Nuclei Detected Highlighted in Original Image')

%dispaying the binary image along with the number of nuclei detected
figure
imshow(new_image)

%formatting the title of the binary image 
[HeightA,~,~] = size(new_image);
top_title = title('Binary Image');
top_title_position = round(get(top_title, 'Position'));

%the bottom title displays the number of nuclei counted
bottom_title = text(top_title_position(1), top_title_position(2) + HeightA+50, ...
    {"Total Number of Nuclei Detected: " + number_of_nuclei}, 'HorizontalAlignment', 'center');


%                                                              ANALYSIS

%creating a decimal variable for rounding
decimal = 2;

%                                       distribution of nuclei sizes by area and diameter

%finding the areas and diameters of nuclei using regionprops
areas_and_diameters = regionprops(new_image, 'Area', 'EquivDiameter');

%saving the diameters and areas into variables
diameters = [areas_and_diameters.EquivDiameter];
areas = [areas_and_diameters.Area];

%calculating the mean and standard deviation of the areas
mean_area = mean(areas);
std_area = std(areas);

%rounding off the mean and standard deviation to 2 decimal places
mean_area = round(10^decimal*mean_area)/10^decimal;
std_area = round(10^decimal*std_area)/10^decimal;

%calculating the mean and standard deviation of the diameters
mean_diameters = mean(diameters);
std_diameters = std(diameters);

%rounding off the mean and standard deviation to 2 decimal places
mean_diameters = round(10^decimal*mean_diameters)/10^decimal;
std_diameters = round(10^decimal*std_diameters)/10^decimal;

%plotting the histograms of the area and diameter distributions
figure, subplot(2,2,1)
histogram(diameters);
xlabel('Diameters of Nuclei')
ylabel('Number of Nuclei Cells')
title({'Distribution of Nuclei Sizes By Diameters', "Mean: " + mean_diameters, "Standard Deviation: " + std_diameters})

subplot(2,2,2)
histogram(areas);
xlabel('Areas of Nuclei')
ylabel('Number of Nuclei Cells')
title({'Distribution of Nuclei Sizes By Area', "Mean: " + mean_area, "Standard Deviation: " + std_area})

%                                                distribution of the mean intensities

%finding the mean intensities in the binary image compared to
%the grayscale image
mean_intensities = regionprops(new_image, green_image, 'MeanIntensity');

%saving the intensities into a variable
intensities = [mean_intensities.MeanIntensity];

%calculating the mean and standard deviation of the intensities
mean_intensity = mean(intensities);
std_intensity = std(intensities);

%round off the mean and standard deviation to 2 decimal places
mean_intensity = round(10^decimal*mean_intensity)/10^decimal;
std_intensity = round(10^decimal*std_intensity)/10^decimal;

%plotting the histogram of the mean intensity distribution
subplot(2,2,3)
histogram(intensities);
xlabel('Intensities')
ylabel('Number of Nuclei Cells')
title({'Distribution of the Nuclei Mean Intensities', "Mean: " + mean_intensity, "Standard Deviation: " + std_intensity})

%                                                        distribution of nuclei shapes

%labelling the nuclei in the image
[label_image, nuclei_total] = bwlabel(new_image);

%finding the perimeters, areas and centroids of the nuclei using regioprops
nuclei_measurements = regionprops(label_image,'Perimeter','Area', 'Centroid'); 

%using the circularity metric Perimeter^2 / (4*pi*Area) metric 
%to deternine the roundness of the nuclei
roundness_metric = [nuclei_measurements.Perimeter].^2 ./ (4 * pi * [nuclei_measurements.Area]);

%calculating the mean and standard deviation of the roundness of nuclei
mean_circularity = mean(roundness_metric);
std_circularity = std(roundness_metric);

%rounding off the mean and standard deviation to 2 decimal places
mean_circularity = round(10^decimal*mean_circularity)/10^decimal;
std_circularity = round(10^decimal*std_circularity)/10^decimal;

%plotting the histogram of the roundness distribution
subplot(2,2,4)
histogram(roundness_metric)
xlabel('Roundness of Nuclei')
ylabel('Number of Nuclei Cells')
title({'Distribution of Nuclei Roundness', "Mean: " + mean_circularity, "Standard Deviation: " + std_circularity})

%showing the input image
figure,
imshow(in_image)

%creating variables to store the number of nuclei of each shape
perfect_circle = 0;
rectangles = 0;
circles = 0;
irregular_shape = 0;

%marking the nuclei on the input image according to their shape and
%counting the number of nuclei of certain shapes

% a perfect circle has a roundness ratio of exactly 1 and is marked with a *
% a cricle has a roundness ratio of  < 1.20 and is marked with an O
% a rectangle has a roundness ratio between 1.20 and 1.55 and is marked with a
%square
% finally, any other shapes with a ratio > 1.55 are irregular and are
% marked with an X

%the marks are plotted on the image at the centroid of each nuclei

hold on;
for nuclei = 1 : nuclei_total
   if roundness_metric(nuclei) == 1
      plot(nuclei_measurements(nuclei).Centroid(1),nuclei_measurements(nuclei).Centroid(2),'w*');
      perfect_circle = perfect_circle + 1;
  elseif roundness_metric(nuclei) < 1.20
    plot(nuclei_measurements(nuclei).Centroid(1),nuclei_measurements(nuclei).Centroid(2),'wO');
    circles = circles + 1;
  elseif roundness_metric(nuclei) < 1.55
    plot(nuclei_measurements(nuclei).Centroid(1),nuclei_measurements(nuclei).Centroid(2),'wS');
    rectangles = rectangles + 1;
   else
    plot(nuclei_measurements(nuclei).Centroid(1),nuclei_measurements(nuclei).Centroid(2),'wX');
    irregular_shape = irregular_shape + 1;
  end
end

%formatting the title of the image where the shapes are marked
[HeightA,~,~] = size(in_image);
title_top = title('Nuclei Shapes');
title_top_position = round(get(title_top, 'Position'));

%the bottom title displays the number of nuclei of each shape as well as
%what the marks represent
title_bottom = text(title_top_position(1), title_top_position(2) + HeightA+50, ...
    {"Perfect Circles (*): " + perfect_circle + "; Circles (O): " + circles + "; Rectangles: " + rectangles + "; Irregular Shapes (X): " + irregular_shape}, 'HorizontalAlignment', 'center');












