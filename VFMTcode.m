%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vanderbilt Face Matching Test
% 01/2015 by Mackenzie Sunday
% Set the Screen to 1024x768 resolution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','MATLAB:dispatcher:InexactMatch');  
 
clear all; clear mex;
Screen('Preference', 'SkipSyncTests',1);             % Add this line to run on laptop
 
% setting up keyboards
devices = PsychHID('Devices'); 
kbs = find([devices(:).usageValue] == 6); 
usethiskeyboard = kbs(end);

try
    commandwindow;  
    
    key1 = KbName('1!'); key2 = KbName('2@'); key3 = KbName('3#');
    key4 = KbName('4$'); key5 = KbName('5%'); key6 = KbName('6^');
    key7 = KbName('7&'); key8 = KbName('8*'); key9 = KbName('9(');
    spaceBar = KbName('space');
    
    wrongkey=MakeBeep(700,0.1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    imfolder = 'VFMTimages';
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % numtrials = 68;  66 trials + 2 catch trials 
    studytime = 4;  %max resp time of 4s
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get subject information.
    repeat=1;
    while (repeat)
        prompt= {'Subject number','Subject Initials','Age','Sex (m/f)', 'Handedness (r/l/a)'};
        defaultAnswer={'99', 'aaa', '26', 'f', 'r'};
        answer=inputdlg(prompt,'Subject information',1, defaultAnswer);
        [subjno,subjini,age,sex,hand]=deal(answer{:});
        if isempty(str2num(subjno)) || ~isreal(str2num(subjno))
            h=errordlg('Subject Number must be an integers','Input Error');
            repeat=1;
            uiwait(h);
        else
            outf=['VFMT_Data/VFMT_',subjno,'_',subjini,'.txt'];	
            if exist(outf)~=0
                button=questdlg(['Overwrite VFMT_',subjno,'_',subjini,'.txt?']);
                if strcmp(button,'Yes'); repeat=0; end
            else
                repeat=0;
            end
        end
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Open Screens.
    bcolor=0;    
    AssertOpenGL;
    ScreenNumber=max(Screen('Screens'));
    [w, ScreenRect]=Screen('OpenWindow',ScreenNumber, bcolor, [], 32, 2);
    white=WhiteIndex(w); %get white value
    midWidth=round(RectWidth(ScreenRect)/2);   
    midLength=round(RectHeight(ScreenRect)/2);
    Screen('FillRect', w, [255 255 255]); % set scrren to white
    Screen('Flip',w);
    Priority(MaxPriority(w));
    
    Screen_X = RectWidth(ScreenRect); 
    Screen_Y = RectHeight(ScreenRect); 
    cx = round(Screen_X/2);
    cy = round(Screen_Y/2);
    
    ScreenBlank = Screen(w, 'OpenOffScreenWindow', white, ScreenRect);
    [oldFontName, oldFontNumber] = Screen(w, 'TextFont', 'Helvetica' ); %set font
    [oldFontName, oldFontNumber] = Screen(ScreenBlank, 'TextFont', 'Helvetica' );
    oldFontSize=Screen(w,'TextSize',[40]); %set text size
  
    %Open data file.
    fileName = sprintf('outf_VFMT_%s.txt', subjno); %create filename string with subj num
    dataFile=fopen(fileName,'w');
    fprintf(dataFile, '%20s\t%20s\n','time',mat2str(fix(clock)));
    fprintf(dataFile,'\nsubjno\tsubjini\tage\tsex\thand');
    fprintf(dataFile, '\n%s\t%s\t%s\t%s\t%s',subjno,subjini,age,sex,hand);
    
    ListenChar(2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(dataFile, ['\nsubjno\tsubjini\ttrialnum\tstudydisp\trespdisp\ttarloc\tresp\tac\trt']); %prints headers
    
    startexpt = GetSecs; %get time of the start of the experiment
        
    fixation = uint8(ones(7)*255);
    fixation(4,:) = 0;
    fixation(:,4) = 0;
    
    %read in the trial info from the text file
    [trialnum studydisp respdisp tarloc]=...
        textread('VFMT.txt','%s %s %s %u');
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Prepare & give instructions. Both matlab text and image texts can be
    %used
    
%     not0 = 'TASK INSTRUCTIONS:'; % not for test trials
%     
%     not1 = 'This task will test your face recognition ability.';
%     not2 = 'On each trial, you will see 2 faces to study for 4 seconds.';
%     not3 = 'When it says STUDY, try to memorize both faces.';
%     not4 = 'Next, you will see 3 new faces. One of the faces will show one of the same people as in the study';
%     not4b= 'one of the same people as in the study, but a different image.';
%     not5 = 'The target face may occur in any position.';
%     not6 = '         Press "1" if the target appears on the LEFT.';
%     not7 = '         Press "2" if the target appears in the CENTER.';
%     not8= '         Press "3" if the target appears on the RIGHT.';
%     not9= 'There will be 68 trials';
%     not10= '      ';
%     not11= 'Let''s practice with 3 practice trails with cartoon characters';
%     not12= 'Press the space bar to begin a few practice trials.';
%     not13= 'Take your time and be as ACCURATE as possible. Good Luck!';
%  
%     not14 = 'Practice trials are now over.';
%     not15 = 'Press the space bar to begin the actual experiment.';
%     not16 = 'You will get feedback on the first 3 trials and no feedback after that'    
    notEnd = 'Thank you for your participation! Please get the experimenter';   
%     Screen(w, 'TextSize', 24);
%     Screen('DrawText', w, not0, 100, 100, [0 0 0]);
%     Screen('DrawText', w, not1, 100, 150, [0 0 0]);
%     Screen('DrawText', w, not2, 100, 190, [0 0 0]);
%     Screen('DrawText', w, not3, 100, 230, [0 0 0]);
%     Screen('DrawText', w, not4, 100, 270, [0 0 0]);
%     Screen('DrawText', w, not4b, 100, 310, [0 0 0]);
%     Screen('DrawText', w, not5, 100, 350, [0 0 0]);
%     Screen('DrawText', w, not6, 100, 390, [0 0 0]);
%     Screen('DrawText', w, not7, 100, 430, [0 0 0]);
%     Screen('DrawText', w, not8, 100, 470, [0 0 0]);
%     Screen('DrawText', w, not9, 100, 580, [0 0 0]);
%     Screen('DrawText', w, not10, 100, 620, [0 0 0]);
%     Screen('DrawText', w, not11, 100, 660, [0 0 0]);
%     Screen('DrawText', w, not12, 100, 700, [0 0 0]);
%     Screen('DrawText', w, not13, 100, 740, [0 0 0]);

%read in instruction images
instruct1=imread('instruct1.jpg'); instruct2=imread('instruct2.jpg');
instruct3=imread('instruct3.jpg'); instruct4=imread('instruct4.jpg');

Screen('PutImage', w, instruct1);
Screen('Flip', w);
WaitSecs(.5);
touch=0;
while touch==0
    [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
    if keyCode(spaceBar); break; else touch=0; end
end; while KbCheck; end

Screen('PutImage', w, instruct2);
Screen('Flip', w);
WaitSecs(.5);
touch=0;
while touch==0
    [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
    if keyCode(spaceBar); break; else touch=0; end
end; while KbCheck; end

Screen('PutImage', w, instruct3);
Screen('Flip', w);
WaitSecs(.5);
touch=0;
while touch==0
    [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
    if keyCode(spaceBar); break; else touch=0; end
end; while KbCheck; end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Practice trails
    prac1study=imread('trial_4_isi-1000_limit-4000.jpg'); prac1resp=imread('trial_5_sections-3_correct-2.jpg');
    prac2study=imread('trial_6_isi-1000_limit-4000.jpg'); prac2resp=imread('trial_7_sections-3_correct-3.jpg');
    prac3study=imread('trial_8_isi-1000_limit-4000.jpg'); prac3resp=imread('trial_9_sections-3_correct-2.jpg');
    
    %first practice trial
    Screen('FillRect', w, white);
    Screen('PutImage', w, prac1study);
    Screen('Flip', w); WaitSecs(studytime);
    Screen('PutImage', w, prac1resp);
    Screen('Flip', w);
    
    tstart=GetSecs;
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key2); resp = 2;
                ac=1; fdbkmsg= 'CORRECT';
            elseif keyCode(key3); resp = 3;
                ac=0; fdbkmsg= 'INCORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'0','prac1','prac1',2,resp,ac,rt);
    
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center'); %centers and draws feedback message
    Screen('Flip', w); WaitSecs(2);
    
    %second practice trial
    Screen('FillRect', w, white);
    Screen('PutImage', w, prac2study);
    Screen('Flip', w); WaitSecs(studytime);
    Screen('PutImage', w, prac2resp);
    Screen('Flip', w);
    
    tstart=GetSecs;
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key2); resp = 2;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key3); resp = 3;
                ac=1; fdbkmsg= 'CORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'0','prac2','prac2',3,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center');
    Screen('Flip', w); WaitSecs(2);
    
    %third practice trial
     Screen('FillRect', w, white);
    Screen('PutImage', w, prac3study);
    Screen('Flip', w); WaitSecs(studytime);
    Screen('PutImage', w, prac3resp);
    Screen('Flip', w);
    
    tstart=GetSecs;
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key2); resp = 2;
                ac=1; fdbkmsg= 'CORRECT';
            elseif keyCode(key3); resp = 3;
                ac=0; fdbkmsg= 'INCORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'0','prac3','prac3',2,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center');
    Screen('Flip', w); WaitSecs(2);
    
    %screen to start experiment
    Screen('PutImage', w, instruct4);
    Screen('Flip', w);
    WaitSecs(.5);
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Experimental trials
      % first 3 trials with feedback
      trial1study=imread('trial_11_isi-1000_limit-4000.jpg'); trial1resp=imread('trial_12_sections-3_correct-2.jpg');
      trial2study=imread('trial_13_isi-1000_limit-4000.jpg'); trial2resp=imread('trial_14_sections-3_correct-1.jpg');
      trial3study=imread('trial_15_isi-1000_limit-4000.jpg'); trial3resp=imread('trial_16_sections-3_correct-3.jpg');
      
      trialstart = GetSecs;
      %first feedback trial
      Screen('FillRect', w, white);
      Screen('PutImage', w, trial1study);
      Screen('Flip', w); WaitSecs(studytime);
      Screen('PutImage', w, trial1resp);
      Screen('Flip', w);
      
    tstart=GetSecs; %get the time the response screen is displayed for RT
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key2); resp = 2;
                ac=1; fdbkmsg= 'CORRECT';
            elseif keyCode(key3); resp = 3;
                ac=0; fdbkmsg= 'INCORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'1','trial1','trial1',2,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center');
    Screen('Flip', w); WaitSecs(2);
    
    %second feedback trial
    Screen('FillRect', w, white);
    Screen('PutImage', w, trial2study);
    Screen('Flip', w); WaitSecs(studytime);
    Screen('PutImage', w, trial2resp);
    Screen('Flip', w);
    
    tstart=GetSecs;
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=1; fdbkmsg= 'CORRECT';
            elseif keyCode(key2); resp = 2;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key3); resp = 3;
                ac=0; fdbkmsg= 'INCORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'2','trial2','trial2',1,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center');
    Screen('Flip', w); WaitSecs(2);
    
    %third feedback trial
     Screen('FillRect', w, white);
    Screen('PutImage', w, trial3study);
    Screen('Flip', w); WaitSecs(studytime);
    Screen('PutImage', w, trial3resp);
    Screen('Flip', w);
    
    tstart= GetSecs;
    touch=0; noresponse=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        rt=(tpress-tstart)*1000;
        if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
        else
            if touch; end;
            touch=0;
        end
    end
    
    FlushEvents('keyDown');
    Screen('FillRect', w, white);
    Screen('Flip', w); WaitSecs(.5);
    
   if ~noresponse  
            if keyCode(key1); resp = 1;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key2); resp = 2;
                ac=0; fdbkmsg= 'INCORRECT';
            elseif keyCode(key3); resp = 3;
                ac=1; fdbkmsg= 'CORRECT!';
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,'3','trial3','trial3',3,resp,ac,rt);
    
    [nx, ny, bbox] = DrawFormattedText(w, fdbkmsg, 'center', 'center');
    Screen('Flip', w); WaitSecs(2);
    
    % trials without feedback
    for m = 1:numel(studydisp)
        %Beginning of a trial.
        study = imread([studydisp{m}], 'jpg');
        Screen('FillRect', w, white); Screen('Flip', w); WaitSecs(.2);
        Screen('PutImage', w, study);
        Screen('Flip', w);
        WaitSecs(studytime);
        
        % Response 
        respscreen = imread([respdisp{m}], 'jpg');
        Screen('PutImage', w, respscreen);
        Screen('Flip', w);
        
        tstart=GetSecs;
        touch=0; noresponse=0;
        while touch==0
            [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
            rt(m)=(tpress-tstart)*1000;		
            if  keyCode(key1)||keyCode(key2)||keyCode(key3); break;
            else if touch; end; touch=0; end
            touch=0;
        end
        
        if ~noresponse  
            if keyCode(key1); resp = 1;
                if tarloc(m)==1; ac(m)=1;
                else ac(m)=0; end
            elseif keyCode(key2); resp = 2;
                if tarloc(m)==2; ac(m)=1;
                else ac(m)=0; end
            elseif keyCode(key3); resp = 3;
                if tarloc(m)==3; ac(m)=1;
                else ac(m)=0; end
            end     
        else  
            resp='nil'; ac(m)=-1; rt(m)=-1;
        end
        
        fprintf(dataFile, ('\n%s\t%s\t%s\t%s\t%s\t%d\t%d\t%d\t%f'),...
            subjno,subjini,trialnum{m},studydisp{m},respdisp{m},tarloc(m),resp,ac(m),rt(m));
        
        FlushEvents('keyDown');
        touch=0;
        
    end    
    
    ListenChar(0);
    
    fclose('all');
    
   [nx, ny, bbox] = DrawFormattedText(w, notEnd, 'center', 'center'); %draws end note to get experimenter
    Screen('Flip', w);
    WaitSecs(.2);
    
    %press the spacebar to end
    FlushEvents('keyDown');
    touch=0;
    while touch==0
        [touch,tpress,keyCode]=PsychHID('KbCheck',usethiskeyboard);
        if keyCode(spaceBar); break; else touch=0; end
    end; while KbCheck; end
    
    totalExptTime = (GetSecs - startexpt)/60;
    ACmean = mean(ac);
    RTmean = mean(rt);
    
    %prints to command window
    fprintf('\nExperiment time:\t%4f\t minutes',totalExptTime);
    fprintf('\nAverage accuracy:\t%4f',ACmean);
    fprintf('\nAverage response time:\t%4f\n',RTmean);

    
    Screen('CloseAll'); 
    ShowCursor; ListenChar;
    Priority(0);   
    
    
    tVFMT = totalExptTime;
    
catch
    ListenChar(0);
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterror);
end