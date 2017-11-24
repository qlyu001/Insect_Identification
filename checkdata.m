%Threshold is 250 
function checkdata(srcFolder,desFolder,nSubRows,nSubCols,random)
    writeID = fopen('check_count.txt','a+');
    
    
 
    files = dir(fullfile(srcFolder, '*.csv'));
    nFiles = length(files);
    perm = 1:nFiles;
  
    
    mel_number = 0;
    suz_number = 0;
    
    for number = 1:nFiles
        fileID = fopen(fullfile(srcFolder,files(perm(number)).name));
        fs = 8000;
        length_each_file=1024;
        tmp=textscan(fileID,'%s\n',length_each_file);
        fclose(fileID);
        tmp=tmp{1};
        s=cellfun(@str2num,tmp(1:length_each_file));
        s=s-mean(s);
        s=s/max(abs(s));
        spect = time2spect(s);
        interval=fs/2/(length(spect)-1);
        spect = time2spect(s);
        startidx=floor(0/interval)+1;
        endidx=floor(2500/interval)+1;
        range=startidx:endidx;
        mainfreq=getMainFreq(spect,fs);
         if mainfreq>230
             mel_number = mel_number + 1;
             %fprintf(writeID,'%d ',mainfreq);
             %fprintf(writeID,'%d ',number);
             %fprintf(writeID,'suz\n');
         else
             suz_number = suz_number + 1;
             %fprintf(writeID,'%d ',mainfreq);
             %fprintf(writeID,'%d ',number);
             %fprintf(writeID,'mel\n');
         end
    end
    fprintf(writeID,'%s ',srcFolder);
    fprintf(writeID,'%d ',suz_number);
    fprintf(writeID,'%d\n',mel_number);
end


function mainfreq=getMainFreq(spect,fs)
    interval=fs/2/(length(spect)-1);
    starting=100;
    startidx=floor(starting/interval);
    bandwidthidx=floor(100/interval);
    bwidx=floor(75/interval);
    [maxpow, maxidx]=max(spect(startidx:end));
    maxidx=startidx+maxidx-1;
    maxfreq=(maxidx-1)*interval;
    mainfreq=maxfreq;
    if mainfreq>200
        %spect(maxidx-bandwidthidx:maxidx+bandwidthidx)=0;
        spect(maxidx-bandwidthidx:end)=0;
        halfmid=floor(maxidx/2);
        [secondmaxpow,secondmaxidx]=max(spect(startidx:end));
        secondmaxidx=startidx+secondmaxidx-1;
        front=halfmid-bwidx;
        back=halfmid+bwidx;  
        
        if secondmaxidx>front && secondmaxidx < back && secondmaxpow>max(spect(front),spect(back))*1.5 
            idx=[floor(maxidx/2) ceil(maxidx/2)];
            half_freq_pow=max(spect(idx));
            if half_freq_pow>=maxpow/10
                mainfreq=maxfreq/2;
            end
        end
    end
end


function spect = time2spect(s)
% convert a time-domain signal s to power spectrum using fft
    n=length(s);
    NFFT = 2^nextpow2(n)*4;
    spect = fft(s,NFFT);
    spect = abs(spect(1:NFFT/2+1)).^2;
    spect(2:end-1)=spect(2:end-1)*2;
    %spect = spect/sum(spect);
    spect = spect/NFFT;
    spect = smooth(spect,10);
    %spect = reshape(spect,1,[]);
end
