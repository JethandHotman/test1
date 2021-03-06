function [LAM,THETA,PPP, Xm, Ym, mnLM, mnTHE, mnP]=find_ripple_1030(fname,range)
% FIND_RIPPLE_1030 uses 2D FFT to estimate wavelength and direction of ripples from the USGS sonar image.
%
%
% em 10/30/09
%
% Inputs
%         fname: filename of mat file with the X,Y,Z of the image (raw
%                file)
%         range  : sample scans to treat (default if not given = all)
% Outputs
%         LAM   : Wave length of ripple (in m)
%         THETA : Angle of ripple crest-line from North
%         PPP   : Spectral Power value
%         Xm   : Xm matrix of all 8 Spectra frequency X
%         Ym   : Ym matrix os all 8Spectra frequency Y
%         mnLM : mean Lambda for all 8 boxes
%         mnTHE : mean theta for all 8 boxes
%         mnP : mean spectrum for all 8 boxes
%
% The program does all 8 Squares(=8) squares and the mean. Square size is
% Sm x Sm (4m in here) that are offset by 360degs/Squares from each other.
% the 2D FFT is applied on each square and the results are averaged to a
% single ppwer spectrum and a filter is applied to smooth the results.
% The area around the center is set to zeros to avoid problems with DC
% levels. Finaly the peak value is estimated and the Lx and Ly are
% estimated. Those are used to estimate L and Angle.
%
% THe approach here is not to do any selection here, just to get all 8
% wavelengths and directions then decide which should be used later.

% If you want to visually see the results set variable plotme to 1.
%
% uses ndetrend.m, spectrum2d.m find_good_squares.m
%
% G. Voulgaris, April 27, 2007
%  Changed April 30, 2007
% Modifed by T. Nelson, September 6, 2007
% -----  USER DEFINED PARAMETERS FOR ANALYSIS   ----
plotme=1;
%plotme=1;  % set to 1 to see plots and 0, if not
%                be set to avoid an infinite loop.
Rsq=5;         % Image range (m)
z = 0.65;      % Sonar head height above bed (m)
dx=0.01;       % x resolution of interpolated image
dy=0.01;       % y resolution of interpolated image
m=128;          % points of fft transform in the x direction
n=128;          % points of fft transform in the y direction
Squares=8;     % No of sub-sampled domains to be analyzed
Sm = .75*max(m*dx,n*dy); % Side of each sub-domain (Square) in meters
%
WLim=3.0;         % Max Wave number limit (avoids the highs around the DC level)l(['load ',fname])
%
warning off all

miss_rng=0;
if nargin ==0
    help fmilename; return;
elseif nargin < 2
    miss_rng=1;
end

% this program does all 8 boxes and does no elimination at this step
% Open the file
proc=netcdf(fname);

% default is to treat all images
if miss_rng
    range=[1:1:length(proc{'time'}(:))];
end
%total=length([range(1):1:range(end)]);
total=length(range);
LAM=NaN(total,Squares);
THETA=NaN(total,Squares);
PPP=NaN(total,Squares);
Xm=NaN(total,Squares);
Ym=NaN(total,Squares);

%x is a coordinate variable so doesn't change, so can be outside the loop
% x and y are the same, so can duplicate- if different, should read from 'y'
X_vect=proc{'x'}(:);
X=repmat(X_vect,1,length(X_vect));
Y=X';        % y and x are the same in the sonar images, otherwise should use
%  same syntax as reading X_vect

% this just works with the indices presented, and stuffs them into array
% elements 1-length(range)
for ia=1:length(range)
    Z=proc{'sonar_image'}(range(ia),1,:,:);
    % because Z has coordinate system defined as (time, sweep, y,x), we
    % transpose it here, to make the gridding lines clearer.  So now references
    % to x adn y are in axis space (x is horizontal, y is vertical)
    % It's very confusing if Y is being found in XX, so I flipped the data to
    % simplify following the code.  etm 10/30/09
    Z=Z';
    
    % this part is independent of the iamge data
    % these squares start x=0, y=+ (12:00), and progress CW around main image
    % box 8 is now the one with the bland area at fan -180.
    for k=1:Squares
        Dsq=((k-1)*360/Squares)*pi/180;
        Rcent=sqrt(Rsq.^2-z^2);              % Apply pythagorean
        Yc(k)=Rcent*cos(Dsq)/2;
        Xc(k)=Rcent*sin(Dsq)/2;
        XX(k,1:2)=[Xc(k)-2*Sm/2 Xc(k)+2*Sm/2];
        YY(k,1:2)=[Yc(k)-2*Sm/2 Yc(k)+2*Sm/2];
    end
    
    %now here's where the boxes get overlaid on the data
    io=1;     PXY=zeros(m,n);
    while io<Squares+1
        %this works for Z=proc{'sonar_image'}(ia,1,:,:)';  !! Transposed !!
        [Isq]=find( (X>=XX(io,1) & X<=XX(io,2))& (Y>=YY(io,1) & Y<=YY(io,2)) );
        [XI,YI] = meshgrid([XX(io,1):dx:XX(io,2)], [YY(io,1):dx:YY(io,2)]);
        % order here is Y, X because that's how sonar_image is defined in
        % the cdf file.
        [XI,YI,ZI] = griddata(X(Isq),Y(Isq),Z(Isq),XI,YI,'cubic');
        IJ = find(isnan(ZI)==1);
        ZI(IJ) = zeros(size(IJ));
        XI=XI(2:end-1,2:end-1);
        YI=YI(2:end-1,2:end-1);
        ZI=ZI(2:end-1,2:end-1);
        if plotme
            figure
            pcolor(XI,YI,ZI);shading flat
            title(['box ' num2str(io) ' using pcolor(XI,YI,ZI)'])
            %both work the same- ws used for debugging
            %figure
            %imagesc(XI(1,:),YI(:,1),ZI)
            %set(gca, 'ydir', 'normal')
            %title(['box ' num2str(io) ' using imagesc(XI,YI,ZI)'])
        end
        %run anaylysis analysis script on the current box
        [kx,ky,Pxy]=spectrum2d(ZI,m,n,dx,dy);
        % stuff the result into an array
        Pxy_array(io,:,:)=Pxy;
        PXY=PXY+Pxy;    % add the new spectrum to the sum
        io=io+1;
    end
    mean_PXY=PXY/Squares;
    
    % first treat the mean case
    [KX,KY]=meshgrid(kx,ky); %Make frequency Grid
    ib=find(abs(KX)<=1.1*WLim & abs(KY)<=1.1*WLim);
    mean_PXY(ib)=mean_PXY(ib)*0;
    %    PXY  = conv2(PPxy,F,'same') ;
    
    % these don't change, so no need to save separately
    gkx=repmat(kx,128,1);
    gky=repmat(ky,128,1)';
    
    % compute the x and y locations of the peak in the frequency spectrum
    [Xm,Ym,Zm]=max2d(gkx,gky,mean_PXY,1);
    % need to repeat for the individual boxes
    KXX=Xm
    KYY=Ym
    mnLM(ia)=2.*pi./sqrt(KXX.^2+KYY.^2);
    
    if(KXX>=0) && (KYY>0)
        Angle=90-atand(abs(KXX/KYY));
    elseif(KXX<0) && (KYY>0)
        Angle=90+atand(abs(KXX/KYY));
    elseif(KXX>0) && (KYY<0)
        Angle=90-atand(abs(KXX/KYY));
    elseif(KXX<0) && (KYY<0)
        Angle=90+atand(abs(KXX/KYY));
    elseif(KXX>0) && (KYY==0)
        Angle=0;
    elseif(KXX<0) && (KYY==0)
        Angle=180;
    end
    mnTHE(ia)=Angle;
    mnP(ia)=Zm;
    
    % now repeat for each box
    for kk=1:Squares
        [Xm,Ym,Zm]=max2d(gkx,gky,squeeze(Pxy_array(kk,:,:)),0);
        % need to repeat for the individual boxes
        KXX=Xm; KYY=Ym;
        % save the evidence so LAM and THETA may be recomputed
        Xm(ia,kk)=Xm;
        Ym(ia,kk)=Ym;
        LAM(ia,kk)=2.*pi./sqrt(KXX.^2+KYY.^2);
        
        if(KXX>=0) && (KYY>0)
            Angle=90-atand(abs(KXX/KYY));
        elseif(KXX<0) && (KYY>0)
            Angle=90+atand(abs(KXX/KYY));
        elseif(KXX>0) && (KYY<0)
            Angle=90-atand(abs(KXX/KYY));
        elseif(KXX<0) && (KYY<0)
            Angle=90+atand(abs(KXX/KYY));
        elseif(KXX>0) && (KYY==0)
            Angle=0;
        elseif(KXX<0) && (KYY==0)
            Angle=180;
        end
        
        THETA(ia,kk)=Angle;
        PPP(ia,kk)=Zm;
    end
        PXY=zeros(m,n);  % zero out the accumulation variable
        clear mean_PXY
    %close all
end
close(proc)
warning on all


