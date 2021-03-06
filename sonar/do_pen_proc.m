function ncp = do_pen_proc(settings, fname, mk_plots, img_nums)
% DO_PEN_PROC - Processes Imagenex pencil sonar data from the raw netCDF file.
%   this program uses code from Imagenex to convert the raw data into an
%   image approximating the
% usage:  ncp = do_fan_rots('836procpmeta', '855tst_raw.cdf', [1:10])
%   where:  procmeta is the name of your structure containing metadata
%                     expects to be called from a script that sets them up.
%                     procMeta.SonartoAnimate='pen';
%                     procMeta.adcp3val=0.0;
%                     procMeta.fanadcp_off=0;
%                     procMeta.Pencil_tilt=0.0;
%                     procMeta.dxy=0.005;
%
%           fname is the netcdf file containing the raw data.  The
%                     rootname will be used to create the name of the
%                     processed file
%           mk_plots is a char, indicating whether to plot or not ('y' or 'n')
%           img_nums is the array of image indices to process
%                     can use [1 10 25] or [132:181],
%                     default is to process all
%              ** nb: if you choose discontinuous elements, they will be
%                     put into sequential elements in the output file, so
%                     the timebase is likely to be irregular.
%           ncp is the processed output netcdf object
%
% USGS Woods Hole Field Center
% emontgomery@usgs.gov
%
% Dependencies:
%   USGS NetCDF Toolbox (C. Denham)
%   -dap enabled mexnc doesn't work! ==> mexnc_win_2006a\mexnc.mexw32 works
%   showpen09.m (E. Montgomery)
%   definepenprocnc.m  (E. Montgomery)
%
% 3/25/08 at CRS request, splitting procsonar into two parts: 1) make the
%         raw.cdf file and 2) apply rotations and what-have-you
%
close all
more off
warning off

% get the current SVN version- the value is automatically obtained in svn
% is the file's svn.keywords is set to "Revision"
rev_info= 'SVN $Revision: $';

%displaying the plots is nice but makes a slow process even slower
% this makes the default 'n' for no entry on the command line
if nargin==2
    mk_plots='n';
end

oldversion=0; %comment out the following section
if oldversion
    % Check for metadata file
    metaPath = pwd;
    meta = dir([metaFile,'.txt']);
    if isempty(meta)
        fprintf('\n')
        fprintf('The metadata file %s.txt does not exist in this directory\n',metaFile)
        metaPath = input('Please enter the full path to the directory with your metadata file:  ','s');
        meta = dir(fullfile(metaPath,[metaFile,'.txt']));
        if isempty(meta)
            error(['Still cannot find this metadata file ', fullfile(metaPath,[metaFile,'.txt'])])
        end
    end
    metaFile = fullfile(metaPath,meta.name);
    
    % Get user's metadata structure
    settings = readSonarMeta(metaFile);
end
% Check that the metadata contains required fields.
reqFields = {'SonartoAnimate','sweep'};
for f = 1:length(reqFields)
    if ~isfield(settings,reqFields{f})
        disp(['The field ''',reqFields{f},''' is not specified in settings'])
        missingFields(f) = 1;
    else
        missingFields(f) = 0;
    end
end
%If a required field is missing, ask the user for it.
if any(missingFields)
    disp('Required fields missing from the metadata');
    settings.fanpen_off = 0;
    settings.sweep = 1;
    settings.dxy = 0.02;    % Key setting...determines image resolution at cost of
    % speed (reasonable range 0.02 to 0.005)
end
clear reqFields missingFields

clear PenTime
Penidx = 1;

save settings settings;
% open existing cdf file of raw pen data
ncr=netcdf(fname);
% set up output file name
if isfield(settings,'onameRoot')
    ofproc=[settings.onameRoot '_proc.cdf'];
else
    uidx=strfind(fname,'_');
    outFileRoot=fname(1:uidx-1);
    ofproc=[outFileRoot '_proc.cdf'];
end

% set up how many images to process
if nargin > 3
    nimg_nums=img_nums;
else
    nimg_nums=1:1:length(ncr{'time'});
end


% xx & yy are the arrays used for pencil image interpolation in showpen,
%  To be sure we all agree what they are, passing them as arguments.
xx=-3.16:.0125:3.16;
yy=(.2:.0025:1.4)';
dim_nc.x=length(xx);
dim_nc.y=length(yy);
dim_nc.sweep=settings.sweep;
inp.x=xx;
inp.y=yy;
inp.tilt=settings.Pencil_tilt;
inp.mkplt=mk_plots;
% run showpen once to get the dimension of the other data
rtndat=showpen09(ncr,nimg_nums(1),inp);

% instantiate the output ncfile
ncp = definepenprocnc(ofproc, settings, dim_nc);

% copy attributes from raw file
rawAtts=ncnames(att(ncr));
for ik=1:length(rawAtts)
    eval(['ncp.' char(rawAtts(ik)) '= ncr.' char(rawAtts(ik)) '(:);'])
end
% if there's information in settings, replace the ncp attributes
% with the values in settings
nn=fieldnames(settings);
for ik = 1:length(nn)
    eval(['ncp.' nn{ik} '(:)=settings.' nn{ik} ';'])
end
% since StepSize is wrong in header, add degreesPerStep here
ncp.DegPerStep=ncr.StepSize(:);
ncp.DegPerStep(:)= ncr{'headangle'}(5)-ncr{'headangle'}(4);
%reset creation date to now
ncp.CREATION_DATE = ncchar(datestr(now));
% do the right number of time elements
ncp{'time'}(1:length(nimg_nums))=ncr{'time'}(nimg_nums);
ncp{'time2'}(1:length(nimg_nums))=ncr{'time2'}(nimg_nums);
% put the outputs into processed netcdf file
for kj=1:settings.sweep
    ncp{'sweep'}(kj)=kj;
end

for jj=(nimg_nums(1):nimg_nums(end))
    % process the images and put into output netcdf file
    if jj > 1
        tic
        rtndat=showpen09(ncr,jj,inp);
        toc
    end
    % and put what's returned in the output file and object
    if Penidx==1
        ncp{'x'}(1:length(xx))=xx;
        ncp{'y'}(1:length(yy))=yy;
    end
    
    % Zs is float- needs to be multiplied by 10000 to store as short
    for kk=1:settings.sweep
        % images may have nan's or small negative values
        tmp1=rtndat(kk).proc_im;
        ltz= tmp1 <0;
        tmp1(ltz)=ncp{'sonar_image'}.FillValue_(:);
        % next multiply by the scale factor
        tmp1=tmp1*1000;
        % now replace Nan's
        lnan= isnan(tmp1);
        tmp1(lnan)=ncp{'sonar_image'}.FillValue_(:);
        %have to force it to uint16 since sonar_image is nc_short
        tmp1=uint16(tmp1);
        ncp{'sonar_image'}(Penidx,kk,1:length(yy),1:length(xx))=tmp1;
        clear tmp1 ltx lnan
    end
    % save the data to the nc file every 5th sample
    if (mod(jj,5)==0)
        close(ncp)
        ncp=netcdf(ofproc,'write');
    end
    
    Penidx=Penidx+1;
    disp(['Pencil sample ' num2str(Penidx-1) ' completed'])
end
ncp{'sonar_image'}.scale_factor(:)=10000;

% this is the last we need ncr...
close(ncr);

% add to history & make some notes to the netcdf file
hist = ncp.history(:);
hist_new = ['Sonar processed with ' ,mfilename, ', ', rev_info, ', using Matlab ' ,...
    version, '; ',hist];
ncp.history = hist_new;
ncp.Pencil_tilt=settings.Pencil_tilt;

ncp.NOTE =['angular data interpolated onto x-y grid to make image;',...
    'image oriented so that +y is up'];
ncp.NOTE1 = ['To view images in Matlab type the following at the command ',...
    'prompt:  nc=netdcf(''sonarxxx.nc'');',...
    'imagesc(nc{''x''}(:),nc{''y''}(:),squeeze(nc{''sonar_image''}(n,p,:,:)));',...
    'set(gca,''ydir'',''normal''); **where n & p are the time and sweep indexes'];

% this is where the summary metadata is saved
%  writing to netCDF doesn't work, but you get a .mat file for each pen and
%  Pencil run
if strcmpi(settings.SonartoAnimate,'pen'),
    t_all= double(ncp{'time'}(:))+(double(ncp{'time2'}(:))./86400000);
    ncp.start_time = datestr(gregorian(t_all(1)));
    if length(t_all)==1
        ncp.stop_time = ncp.start_time;
    else
        ncp.stop_time = datestr(gregorian(t_all(end)));
    end
    % if time data is evenly spaced
    if length(t_all) > 1 & isempty(find(diff(diff(t_all))) ~= 0)
        ncp.DELTA_T = [num2str(gmean(diff(t_all))*24*60),' sec'];
        % time and time2 are EVEN by default
    else
        ncp{'time'}.type(:)='UNEVEN';
        ncp{'time2'}.type(:)='UNEVEN';
        ncp.DELTA_T = ('? sec');
    end
    % close the writeable version
    close(ncp);
    ncclose;
    % re-open it read-only to return to matlab
    eval(['ncp=netcdf(''' ofproc ''');'])
end

% ---------------- Subfunction: readSonarMeta.m ------------------------- %
function userMeta = readSonarMeta(metaFile)
[atts, defs] = textread(metaFile,'%s %63c','commentstyle','shell');
defs = cellstr(defs);
for i = 1:length(atts)
    theAtt = atts{i}(:)';
    theDef = defs{i}(:)';
    % deblank removes trailing whitespace
    theAtt = deblank(theAtt);
    theDef = deblank(theDef);
    % check for and replace spaces in
    % the attributes with underscores
    f1 = find(isspace(theAtt));
    f2 = strfind(theAtt,'-');
    f = union(f1,f2);
    if ~isempty(f)
        theAtt(f) = '_';
    end
    % attribute definitions read in as characters; convert to
    % numbers where appropriate
    theDefNum = str2double(theDef);
    if ~isnan(theDefNum)
        theDef = theDefNum;
    end
    eval(['userMeta.',theAtt,'= theDef;'])
end


