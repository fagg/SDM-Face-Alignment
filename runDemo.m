clear all, close all;

addpath(genpath('lib'));

load('300w.mat');

im = imread('test1.jpg');
%im = imread('test2.jpg');
%im = imread('test3.png');

imGray = rgb2gray(im);

% Run face detector and initialize
bbox = runFaceDet(imGray);
iPts = initPts(model, bbox, 0.75);

pts = SDMApply(imGray, iPts, model);

figure(1), 

subplot(1,2,1), imshow(im), hold on;
rectangle('Position', bbox, 'EdgeColor', 'r'), hold on;
plot(iPts(:,1), iPts(:,2), 'r.', 'MarkerSize', 12);
title('Initialization');

subplot(1,2,2), imshow(im), hold on;
plot(pts(:,1), pts(:,2), 'g.', 'MarkerSize', 12);
title('Registration');

