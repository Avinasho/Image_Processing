% The final code used to create a pipeline to read in hundreds of image
% files,  process and segment them, and create a 3D matrix.
% Final version completed in Summer 2015
% Written by Avinash  Soor
% Git: Avinasho
% Written for my contribution during a Summer internship

tic
close all; clear; clc;

addpath('A:\Summer Work\Original Slices');

s = {343};
arr = zeros(276, 326); % 434, 434, 343 Matrix of cropped, downsampled original slices
newseg = zeros(276, 326, 257); % Matrix of cropped, downsampled analysed slices

total_count = 1; % So there aren't any blank slices

av = fspecial('average', 3);
so_x = fspecial('sobel');
so_y = so_x';
% Creation of filters to be applied

NHOOD1 = strel('arbitrary', 5, 5);
NHOOD2 = strel('disk', 2, 0);
NHOOD3 = strel('disk', 1, 4);
% Creating the neighborhoods for erosion and dilation, to be used after
% filtering

%% Downsampling Process:
% every third slice taken -> data set reduced from 1027 slices to 343
% Every third point taken in x(651) and y directions 

for i = 1:4:1027 % Downsample in Z by 2 instead of 3 -> 1027->> 514
    %% Loads the data
    
    if( i < 301 )
        s_curr = imread( [ 'slice_0' num2str( 699 + i ) '.tif' ] );
        name = ['New_Slice_V29_0' num2str( 699 + i ) '.tif' ];
    else
        s_curr = imread( [ 'slice_' num2str( 699 + i ) '.tif' ] );
        name = ['New_Slice_V29_' num2str( 699 + i ) '.tif' ];
    end
    % Loads the images in 
    
%     %% Removes arbitrary data
%     
%     if( i >= 450 ) %375, 400
% 
%         if( i >= 450 && i <= 485 ) %% (1)
%             thresh = 1000; %1162
%         elseif( i >= 485 && i < 577 ) %% (2)
%             thresh = 980; % 962, 1000
%         elseif( i >= 577 && i < 683 ) %% (3)
%             thresh = 1010; % 1096
%         elseif( i >= 683 && i < 775 ) %% (4)
%             thresh = 1010; %
%         elseif( i >= 775 ) %% (5) % 746
%             thresh = 800; % 956, 1050
%         end
% 
%         for u = 1:2000
%             
%             for v = thresh:1999
% 
%                 s_curr(u, v) = 0;
% 
%             end
% 
%         end
% 
%     end
%     
    %% Removes dead space in the image
        
    s_curr = s_curr(250:1550, 300:1400); %Dimensions: 1301, 1101;

    %% Downsample X & Y for original images
    
    s_curr_arr = zeros(276, 326);
    
    x_count = 1;
    
    y_count = 1;
    
    for o = 1:4:1301
        
        for p = 1:4:1101
       
            s_curr_arr(x_count, y_count) = s_curr(o, p);
            
            x_count = 1 + x_count;
            
        end
        
        y_count = 1 + y_count;
        
        x_count = 1;
        
    end
    
    %% Creating the arr matrix
    
    arr(:, :, total_count) = s_curr_arr;
    
    %% imfill & imclose
    
    s_curr = imfill( s_curr );
    
    s_curr = imclose( s_curr, NHOOD1);
    
    %% Creates a copy to separate incomplete data for separate filtering
    
    s_curr_copy = s_curr; %300:1225, 1:325 %%% 900:1225, 75:325
 
    %% Applies filters
    %% Thresholding  values below a tolerance to zero
    
    if( i > 0 && i <= 458 )
        s_curr( s_curr <= 153 ) = 0;
    elseif( i > 458 && i <= 548 )
        s_curr( s_curr <= 143 ) = 0;
    elseif( i > 548 && i <= 711 )
        s_curr( s_curr <=133 ) = 0;
    elseif( i > 711 && i <= 780 )
        s_curr( s_curr <= 125 ) = 0;
    elseif( i > 780 && i <= 811 )
        s_curr( s_curr <= 110 ) = 0;
    elseif( i > 811 && i <= 891 )
        s_curr( s_curr <= 120 ) = 0;
    elseif( i > 891 && i <= 930 )
        s_curr( s_curr <= 97 ) = 0;
    elseif( i > 930 )
        s_curr( s_curr <=80 ) = 0;
    end
        
    %% Thresholding to one (not necessary due to imfill)
    %% Apply Filters
    %% Replaces incomplete data with (hopefully) complete data from the separate filtering
    % Currently does not work
    if( i >= 144 && i <= 714 )

        if( i >=144 && i <=290 )
            s_curr_copy_local = s_curr_copy( 860:1138, 876:1062 );
        elseif( i >= 291 && i <= 505 )
            s_curr_copy_local = s_curr_copy( 854:1260, 730:1028 );
        elseif( i >= 506 && i <= 714 )
            s_curr_copy_local = s_curr_copy( 860:1210, 376:1020 );
        end

        s_curr_copy_local( s_curr_copy_local <= 140 ) = 0; %120, 130
        % Separate thresholding of this section
        
        s_curr_copy_local = imdilate(s_curr_copy_local, NHOOD3);

        s_curr_copy_local = imdilate(s_curr_copy_local, NHOOD3);

        s_curr_copy_local = imclose(s_curr_copy_local, NHOOD3);

        if( i >=144 && i <=290 )
            s_curr( 860:1138, 876:1062 ) = s_curr_copy_local;
        elseif( i >= 291 && i <= 505 )
            s_curr( 854:1260, 730:1028 ) = s_curr_copy_local;
        elseif( i >= 506 && i <= 714 )
            s_curr( 860:1210, 376:1020 ) = s_curr_copy_local;
        end
        
    end
    
    %% Sobel Filtering
    
    s_curr_x = imfilter(s_curr, so_x);
    
    s_curr_y = imfilter(s_curr, so_y);
    
    s_curr = s_curr_x + s_curr_y;   
    
    s_curr = imfilter(s_curr, av);
    
    %% Erosion and Dilation
     
    s_curr = imerode(s_curr, NHOOD3);
    
    s_curr = imerode(s_curr, NHOOD3);
    
    s_curr = imerode(s_curr, NHOOD3);
    
    s_curr = imdilate(s_curr, NHOOD2);
    
    s_curr = imdilate(s_curr, NHOOD3);
    
    s_curr = imdilate(s_curr, NHOOD3);

    %% Downsample X & Y for Filtered images
    
    s_curr_newseg = zeros(276, 326);
    
    i_count = 1;
    
    j_count = 1;
    
    for u = 1:4:1301
        
        for v = 1:4:1101
       
            s_curr_newseg(i_count, j_count) = s_curr(u, v);
            
            i_count = 1 + i_count;
            
        end
        
        j_count = 1 + j_count;
        
        i_count = 1;
        
    end
    
    %% Saves the data
    
    s{i} = s_curr_newseg;
    
    newseg(:, :, total_count) = s_curr_newseg;
    
    total_count = 1 + total_count;
    
    imwrite( s{i}, name ); 

end

% mywritevtkfun2fil2(arr, 'V29_Slices');
%  
% rho = 'rho';
% sigma = 'sigma';
% mult = 'mult';
% vec = 'vec';
% 
% r = 12;
% s = 10;
% M = 10;
% Vec = 0;
% 
% Options = struct(sigma, s, rho, r, mult, M, vec, Vec);
% 
% [ eig1, ang, angstats ] = mySTanalysis( arr, newseg, Options, 'V29' );

x = toc;
 
% time taken without writing .vtks: ~2 minutes on average

% time taken writing .vtks: ~9 minutes