% encode - generates a biometric template from the normalised iris region,
% also generates corresponding noise mask（对经过归一化的图像进行特征提取并编码）
%
% Usage: 
% [template, mask] = encode(polar_array,noise_array, nscales,...
% minWaveLength, mult, sigmaOnf)
%
% Arguments:
% polar_array       - normalised iris region 归一化的虹膜区
% noise_array       - corresponding normalised noise region map 对应的归一化噪声区域图
% nscales           - number of filters to use in encoding 编码中使用的过滤器数量
% minWaveLength     - base wavelength 基本波长
% mult              - multicative factor between each filter 每个过滤器之间的乘积因子
% sigmaOnf          - bandwidth parameter 带宽参数
%
% Output:
% template          - the binary iris biometric template 二进制虹膜生物识别模板 
% mask              - the binary iris noise mask 二进制虹膜噪声掩码
%
% Author: 
% Libor Masek
% masekl01@csse.uwa.edu.au
% School of Computer Science & Software Engineering
% The University of Western Australia
% November 2003

% function [template, mask] = encode(polar_array,noise_array, nscales, minWaveLength, mult, sigmaOnf)
function [template, mask] = encode(polar_array,noise_array, nscales, minWaveLength, mult, sigmaOnf,eyeimage_filename)
% convolve normalised region with Gabor filters
[E0 filtersum] = gaborconvolve(polar_array, nscales, minWaveLength, mult, sigmaOnf);
global DIAGPATH
testpath = [DIAGPATH , '\testDIA'];
length = size(polar_array,2)*2*nscales;

template = zeros(size(polar_array,1), length);

length2 = size(polar_array,2);
h = 1:size(polar_array,1);

%create the iris template 创建虹膜模板

mask = zeros(size(template));

for k=1:nscales
    
    E1 = E0{k};
    
%     
%     % WRITE NORMALISED PATTERN, AND NOISE PATTERN
%     w = cd;
%     cd(testpath);
%     imwrite(E1,[eyeimage_filename,'-gabor_normal.jpg'],'jpg');
%     %imwrite(noise_array,[eyeimage_filename,'-polarnoise.jpg'],'jpg');
%     cd(w);
    
    %Phase quantisation ： gabor过的图象被二值化
    H1 = real(E1) > 0;%返回复数矩阵每个元素的实数部。
    H2 = imag(E1) > 0;
    
    % if amplitude is close to zero then 如果幅度接近零，则相位数据无效，因此在噪声遮罩中标记
    % phase data is not useful, so mark off
    % in the noise mask
    H3 = abs(E1) < 0.0001;%abs取绝对值的函数
    
    
    for i=0:(length2-1)
                
        ja = double(2*nscales*(i));
        %construct the biometric template
        template(h,ja+(2*k)-1) = H1(h, i+1);
        template(h,ja+(2*k)) = H2(h,i+1);
        
        %create noise mask
        mask(h,ja+(2*k)-1) = noise_array(h, i+1) | H3(h, i+1);
        mask(h,ja+(2*k)) =   noise_array(h, i+1) | H3(h, i+1);
        
    end
    
end 