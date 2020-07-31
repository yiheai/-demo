function [result,time_total,time_createtemplate,time_rebuiltDataBase] = main(testimage,InputPath)
%result:ƥ����
%time_total:�ܺ�ʱ
%time_createtemplate:����һ����Ĥ�����������ʱ
%time_rebuiltDataBase:
t0 = clock;
hmthresh = 0.3;
write = 1; %�Ƿ�����м���̲�����ͼ��
%InputPath='D:\Users\15002\Desktop\�ȸ�����\CASIA-IrisV4(JPG)\CASIA-Iris-Syn\000\';
savefile = [InputPath,'template.mat'];
t1 = clock;
[templatetest, masktest] = createiristemplate(testimage,write);
time_createtemplate = etime(clock, t1);
%�������������Ĥ������
[stae,mess]=fileattrib(savefile);
FileName=dir(strcat(InputPath,'*.jpg'));
NumFile=length(FileName);
if stae
    load(savefile);
    if NumFile == size(template,3)
        rebuilt = 0;
        time_rebuiltDataBase = 0;
    else
        rebuilt = 1;
    end
else
    rebuilt = 1;
end
if rebuilt
    t2 = clock;
    FileName=dir(strcat(InputPath,'*.jpg'));
    NumFile=length(FileName);
    [row,clo] = size(templatetest);
    template = zeros(row,clo,NumFile);
    mask = zeros(row,clo,NumFile);
    for i=1:NumFile
        tempFileName=FileName(i).name;
        ImPath=strcat(InputPath,tempFileName);
        [template_temp, mask_temp] = createiristemplate(ImPath,write);
        template(:,:,i) = template_temp;
        mask(:,:,i) = mask_temp;
    end
    save(savefile,'template','mask','FileName');
    time_rebuiltDataBase = etime(clock, t2);
end
%������������
NumFile = length(template);
for i=1:NumFile
    hd(i) = gethammingdistance(templatetest, masktest, template(:,:,i), mask(:,:,i), 4);
    if hd(i) < hmthresh
        result =FileName(i).name;
        break;
    end
end

if i== NumFile
    k = find(hd==min(hd));
    result = FileName(k).name;
end
time_total = etime(clock, t0);