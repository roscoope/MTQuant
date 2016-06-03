%%% getBackground.m
%%% Ask user for the background intensity of the image
%%%
%%% Input arugments
%%% imIn = input image
%%% bbox (optional) = bounding box from which to calculate the average intensity
%%%      = [y1 y2 x1 x2]
%%% overrideInputs (optional) = if true, just use the input bbox
%%%
%%% Output arguments
%%% background = average value of pixels in imIn inside bboxOut
%%% bboxOut = bounding box used to calculate the background = [y1 y2 x1 x2]

function [background,bboxOut] = getBackground(imIn,bbox,overrideInputs)

if ~exist('overrideInputs','var')
    overrideInputs = false;
end

if overrideInputs
    if ~isempty(bbox)
        y1 = bbox(1);
        y2 = bbox(2);
        x1 = bbox(3);
        x2 = bbox(4);
        bboxOut = bbox;
    else
        goodRect = false;
        while ~goodRect
            figure(1);
            title('Please click on two opposite corners of the box you want to average for the background');
            display('Please click on two opposite corners of the box you want to average for the background');
            imshow(linRescale(imIn)*16);
            [x,y] = ginput(2);
            hold on;
            rectangle('Position',[min(x) min(y) max(x)-min(x) max(y)-min(y)],'EdgeColor','r');
            
            s = input('Are you happy with the location of this rectangle? (type lowercase "y" for yes) ','s');
            if s~='n'
                goodRect = true;
            end
        end
        y1 = round(min(y));
        y2 = round(max(y));
        x1 = round(min(x));
        x2 = round(max(x));
        bboxOut = [y1, y2, x1, x2];
    end
    try
        backgroundBox = imIn(y1:y2,x1:x2);
    catch err
        display('The box you selected is not in the image!  Try again.');
    end
    
    background = mean(backgroundBox(:));
    
    display(horzcat('background = ',num2str(background)));
else
    s = input('Do you already know the background? (type lowercase "y" for yes) ','s');
    if s=='y'
        background = input('Please enter the background value: ');
        bboxOut = [];
    else
        if exist('bbox','var') && ~isempty(bbox)
            s = input('Do you want to use the green box? (type lowercase "y" for yes) ','s');
        else
            s = 'n';
        end
        if s=='y'
            y1 = bbox(1);
            y2 = bbox(2);
            x1 = bbox(3);
            x2 = bbox(4);
            bboxOut = bbox;
        else
            goodRect = false;
            while ~goodRect
                figure(1);
                title('Please click on two opposite corners of the box you want to average for the background');
                display('Please click on two opposite corners of the box you want to average for the background');
                imshow(linRescale(imIn)*16);
                [x,y] = ginput(2);
                hold on;
                rectangle('Position',[min(x) min(y) max(x)-min(x) max(y)-min(y)],'EdgeColor','r');
                
                s = input('Are you happy with the location of this rectangle? (type lowercase "y" for yes) ','s');
                if s~='n'
                    goodRect = true;
                end
            end
            y1 = round(min(y));
            y2 = round(max(y));
            x1 = round(min(x));
            x2 = round(max(x));
            bboxOut = [y1, y2, x1, x2];
        end
        
        try
            backgroundBox = imIn(y1:y2,x1:x2);
        catch err
            display('The box you selected is not in the image!  Try again.');
        end
        
        background = mean(backgroundBox(:));
        
        display(horzcat('background = ',num2str(background)));
    end
end