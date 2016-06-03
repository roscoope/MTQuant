%%% fitSpline.m
%%% Fit a spline to the set of points t,x,y
%%%
%%% Input arguments
%%% t = parameter argument to the spline
%%% x = x position at time t
%%% y = y position at time t
%%%
%%% Output arguments
%%% ps = spline generated using MATLAB's csaps functin
%%% psPrime = derivative of the spline

function [ps, psPrime] = fitSpline(t,x,y)

w = warning('off','all');
tToFit = t(x ~= 0 | y ~= 0);
xToFit = x(x ~= 0 | y ~= 0);
yToFit = y(x ~= 0 | y ~= 0);

ps = csaps(tToFit,[xToFit;yToFit]);

psPrime = fnder(ps);
warning(w);
