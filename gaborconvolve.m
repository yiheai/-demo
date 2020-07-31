% gaborconvolve - function for convolving each row of an image with 1D
% log-Gabor filters������һάGabor�˲�����ͼ����д���
%
% Usage: 
% [template, mask] = createiristemplate(eyeimage_filename)
%
% Arguments:
%   im              - the image to convolve Ҫ�����ͼ��
%   nscale          - number of filters to use Ҫʹ�õĹ�������
%   minWaveLength   - wavelength of the basis filter �����˲����Ĳ���
%   mult            - multiplicative factor between each filter
%                       ÿ��������֮������ϵ��
%   sigmaOnf        - Ratio of the standard deviation of the Gaussian describing
%                     the log Gabor filter's transfer function in the frequency
%                     domain to the filter center frequency.
%                     ��������Gabor�˲�����Ƶ���еĴ��ݺ����ĸ�˹��׼ƫ�����˲�������Ƶ�ʵı��ʡ�
% Output:
%   E0              - a 1D cell array of complex valued comvolution results
%                     ������ֵ��������һά����
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
%ͨ����������cell����ʱ���ʵ�����cell��Ԫ,ͨ��{}����cell����ʱ���ʵ�����cell��Ԫ���������		

ndata = cols;
if mod(ndata,2) == 1             % If there is an odd No of data points ��������������ݵ�
    ndata = ndata-1;               % throw away the last one. �ӵ����һ��
end

logGabor  = zeros(1,ndata);
result = zeros(rows,ndata);
filtersum = logGabor;

radius =  [0:fix(ndata/2)]/fix(ndata/2)/2;  % Frequency valuesƵ��ֵ 0 - 0.5
radius(1) = 1;

wavelength = minWaveLength;        % Initialize filter wavelength.��ʼ���˲�������


for s = 1:nscale,                  % For each scale.ÿһ���˲�������  
    
    % Construct the filter - first calculate the radial filter component.
    % �����˲��������ȼ��㴹ֱ�˲�������
    fo = 1.0/wavelength;                  % Centre frequency of filter. �˲�������Ƶ��
    rfo = fo/0.5;                         % Normalised radius from centre of frequency plane  ����Ƶ�����ĵĹ�һ���뾶
    % corresponding to fo. ��Ӧ��fo
    logGabor(1:ndata/2+1) = exp((-(log(radius/fo)).^2) / (2 * log(sigmaOnf)^2));  
    logGabor(1) = 0;  
    
    filter = logGabor;
    
    filtersum = filtersum+filter;
    
    % for each row of the input image, do the convolution, back transform
    % ��������ͼ���ÿһ�У����о��������任
    for r = 1:rows	% For each row ��ÿһ��
        
        signal = im(r,1:ndata);
        
        
        imagefft = fft( signal );%��ɢ����Ҷ�任
        
        
        result(r,:) = ifft(imagefft .* filter); %����Ҷ���任
        
    end
    
    % save the ouput for each scale ����ÿһ�����
    EO{s} = result;
    
    wavelength = wavelength * mult;       % Finally calculate Wavelength of next filter
end                                     % ... and process the next scale

filtersum = fftshift(filtersum); %����Ƶ���Ƶ�Ƶ�׵��м�