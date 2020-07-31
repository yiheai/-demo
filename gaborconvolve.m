% gaborconvolve - function for convolving each row of an image with 1D
% log-Gabor filters（利用一维Gabor滤波器对图像进行处理）
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%   im              - the image to convolve 要卷积的图像
%   nscale          - number of filters to use 要使用的过滤器数
%   minWaveLength   - wavelength of the basis filter 基本滤波器的波长
%   mult            - multiplicative factor between each filter
%                       每个过滤器之间的相乘系数
%   sigmaOnf        - Ratio of the standard deviation of the Gaussian describing
%                     the log Gabor filter's transfer function in the frequency
%                     domain to the filter center frequency.
%                     描述对数Gabor滤波器在频域中的传递函数的高斯标准偏差与滤波器中心频率的比率。
% Output:
%   E0              - a 1D cell array of complex valued comvolution results
%                     复杂数值卷积结果的一维数组
%           
% Author: 
% Original 'gaborconvolve' by Peter Kovesi, 2001
% Heavily modified by Libor Masek, 2003
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003


function [EO, filtersum] = gaborconvolve(im, nscale, minWaveLength, mult, ...
    sigmaOnf)

[rows cols] = size(im);
%filtersum = zeros(1,size(im,2));

EO = cell(1, nscale);          % Pre-allocate cell array 
%通过（）访问cell数组时访问到的是cell单元,通过{}访问cell数组时访问到的是cell单元储存的内容		

ndata = cols;
if mod(ndata,2) == 1             % If there is an odd No of data points 如果有奇数个数据点
    ndata = ndata-1;               % throw away the last one. 扔掉最后一个
end

logGabor  = zeros(1,ndata);
result = zeros(rows,ndata);
filtersum = logGabor;

radius =  [0:fix(ndata/2)]/fix(ndata/2)/2;  % Frequency values频率值 0 - 0.5
radius(1) = 1;

wavelength = minWaveLength;        % Initialize filter wavelength.初始化滤波器波长


for s = 1:nscale,                  % For each scale.每一个滤波器次数  
    
    % Construct the filter - first calculate the radial filter component.
    % 构造滤波器，首先计算垂直滤波器分量
    fo = 1.0/wavelength;                  % Centre frequency of filter. 滤波器中心频率
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane  距离频率中心的归一化半径
    % corresponding to fo. 对应于fo
    logGabor(1:ndata/2+1) = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor(1) = 0;  
    
    filter = logGabor;
    
    filtersum = filtersum+filter;
    
    % for each row of the input image, do the convolution, back transform
    % 对于输入图像的每一行，进行卷积，反向变换
    for r = 1:rows	% For each row 对每一行
        
        signal = im(r,1:ndata);
        
        
        imagefft = fft( signal );%离散傅立叶变换
        
        
        result(r,:) = ifft(imagefft .* filter); %傅里叶反变换
        
    end
    
    % save the ouput for each scale 保存每一次输出
    EO{s} = result;
    
    wavelength = wavelength * mult;       % Finally calculate Wavelength of next filter
end                                     % ... and process the next scale

filtersum = fftshift(filtersum); %将零频点移到频谱的中间