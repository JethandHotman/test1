% process_all_example - example file for running the ADCP toolbox in automated mode
%  programs from the adcp toolbox are required prior to running this!

%%% START USGS BOILERPLATE -------------%
% Use of this program is described in:
%
% Acoustic Doppler Current Profiler Data Processing System Manual 
% Jessica M. C�t�, Frances A. Hotchkiss, Marinna Martini, Charles R. Denham
% Revisions by: Andr�e L. Ramsey, Stephen Ruane
% U.S. Geological Survey Open File Report 00-458 
% Check for later versions of this Open-File, it is a living document.
%
% Program written in Matlab v7.1.0 SP3
% Program updated in Matlab 7.2.0.232 (R2006a)
% Program ran on PC with Windows XP Professional OS.
%
% "Although this program has been used by the USGS, no warranty, 
% expressed or implied, is made by the USGS or the United States 
% Government as to the accuracy and functioning of the program 
% and related program material nor shall the fact of distribution 
% constitute any such warranty, and no responsibility is assumed 
% by the USGS in connection therewith."
%
%%% END USGS BOILERPLATE --------------

% 9/15/07 etm
% modified to use the universal metadata file
gatt=read_globalatts('\home\data\processing\adcp\8181wh\nyb07_meta.txt');
% change the line below to fit your syetem path for the location of m_cmg
mfRoot='C:\home\ellyn\mtl\';
 
% --------- set up the information needed by the programs
%
% assign the rootName based on the Mooring #
rootName=[gatt.MOORING '1'];
settings.numRawFile = 1; % number of raw binary ADCP files (*.000 or *.PD0), max = 2
settings.rawdata1 = [rootName 'wall.000']; % raw file #1
settings.rawdata2 = ''; % raw file #2, if any
settings.rawcdf = [rootName 'wh-n.cdf']; % output file name for the raw data in netCDF format
settings.theFilledFile = [rootName 'whF-n.cdf']; % the name of the fill file
settings.theMaskFile = [rootName 'wh.msk-n']; % the name of the mask file
settings.theNewADCPFile = [rootName 'whM-n.cdf']; % the name of the new file with the mask applied
settings.trimFile = [rootName 'whT-n.cdf']; % the name of the file trimmed by time out of water and by bin
settings.rdi2cdf.run = 1; % force runadcp to run rdi2cdf (future implementation)
settings.rdi2cdf.Mooring_number = gatt.MOORING; %four digit NNNL, NNN mooring + L logger
settings.rdi2cdf.Deployment_date = gatt.Deployment_date; % the in water time
settings.rdi2cdf.Recovery_date = gatt.Recovery_date; % the out of water time
settings.rdi2cdf.lon = gatt.longitude; % decimal degrees, West = negative
settings.rdi2cdf.lat = gatt.latitude; % decimal degrees, South = negative
settings.rdi2cdf.declination = gatt.magnetic_variation; % degrees west is negative
settings.rdi2cdf.water_depth = gatt.WATER_DEPTH; % m (DO NOT OMIT!)
settings.rdi2cdf.origin = gatt.DATA_ORIGIN; % with collaborator's data, could be USC, etc.
settings.rdi2cdf.experiment = gatt.EXPERIMENT; 
settings.rdi2cdf.description = gatt.DESCRIPTION; 
settings.rdi2cdf.conventions = gatt.Conventions; 
settings.rdi2cdf.project = gatt.PROJECT; % might also use OFA funding agency, such as MWRA, EPA, WCMG
settings.rdi2cdf.whichscheme = 1; % which sampling scheme to read out

settings.rdi2cdf.ADCP_serial_number = 2054; 
settings.rdi2cdf.xducer_offset = 1.235; % ADCP transducer offset from the sea bed
settings.rdi2cdf.pred_accuracy = 0.79; % from TRDI PLAN in cm/s
settings.rdi2cdf.slow_by = 3*60+9; % clock drift
settings.rdi2cdf.magnetic = 12.9; % declination in degrees, west is negative
settings.fixens.run = 1; % force runadcp to run fixens (future implementation)
settings.runmask.noninteractive = 1; % don't bring up starbare in runmask 
% use this to override goodends' search for tripod tilt, etc.
% use it if you are really running in batch and don't want goodends to prompt you
settings.goodends.stop_date = settings.rdi2cdf.Recovery_date; % set to [] to disable
settings.trimbins.numRawFile = settings.numRawFile; % leave this alone
settings.trimbins.rawdata1 = settings.rawdata1; % leave this alone
settings.trimbins.rawdata2 = settings.rawdata2; % leave this alone
settings.trimbins.trimFile = settings.trimFile; % leave this alone
% method to remove bins above the surface (see trimbins documentation
settings.trimbins.method = 'RDI Surface Program'; %'RDI Surface Program' | 'User Input' | 'Pressure Sensor'
% percent of water column to make sure is preserved when trimming (1 = 100%)
settings.trimbins.percentwc = 1.12; % to capture full range of tide
settings.trimbins.ADCP_offset = settings.rdi2cdf.xducer_offset; % leave this alone
% path to the TRDI surface program, if you are on a PC
% we have permission to distribute TRDI's surface.exe with the toolbox
% so this should be your toolbox path, Demo directory
settings.trimbins.progPath = [mfRoot 'm_cmg\trunk\adcp_tbx\AddOns\']; % or ''
settings.adcp2ep.epDataFile = [rootName 'wh-n.nc']; % final output file name
settings.adcp2ep.long = gatt.longitude; % decimal degrees, West = negative
settings.adcp2ep.latit = gatt.latitude; % decimal degrees, South = negative
settings.adcp2ep.lonUnits = 'degrees_west';
settings.adcp2ep.latUnits = 'degrees_north';
settings.adcp2ep.declination = gatt.magnetic_variation; % degrees west is negative
settings.adcp2ep.water_depth = gatt.WATER_DEPTH; % m (DO NOT OMIT!)
settings.adcp2ep.origin = gatt.DATA_ORIGIN; % with collaborator's data, could be USC, etc.
settings.adcp2ep.experiment = gatt.EXPERIMENT; 
settings.adcp2ep.descript = gatt.DESCRIPTION; 
settings.adcp2ep.conventions = gatt.Conventions; 
settings.adcp2ep.project = gatt.PROJECT; % might also use OFA funding agency, such as MWRA, EPA, WCMG
settings.adcp2ep.SciPi = gatt.SciPi; % your metadata, principal investigator
settings.adcp2ep.cmnt = ' ';  % your metadata
settings.adcp2ep.water_mass = ' '; % an EPIC requirement

% the dialog file for your ADCP, there is one in the Demo directory.
% the toolbox use the instrument elevation and azimuth specific to each ADCP
settings.adcp2ep.dlgFile = '822wh.dlg'; % generated by the ADCP using the PS3 command
settings.adcp2ep.ADCPtype = 'WH'; % workhorse or BB for broadband

% --------------------- run the programs
%
% turn each step "on" and "off" by setting "if 0" to "if 1"
% steps must be run in sequence

diary(sprintf('run%s',datestr(now, 30)))

% sometimes ADCPs don't know which way they were really facing.
% only for deployments that need orientation fixed, implement the following:
if 0, % run rdi2cdf separately to fix the orientation
    rdi2cdf(settings.rawdata1,settings.rawcdf,[],[],...
        settings.rdi2cdf); % user's provideing metadata
    orientation = 'UP'; % 'UP' or 'DOWN'
    fixorientation(settings.rawcdf,orientation);
    % when rdi2cdf is run the second time via runadcp (below) 
    % the file converted here will not be overwritten
end

if 0, % translate to netcdf, mask for basic errors and trim the data
    runadcp(settings)
end
%
if 0, % apply a mask that tracks the surface - if you wish to
    [path, name, ext] = fileparts(settings.trimFile);
    theMaskFile = fullfile(path,[name, '.msk']);
    theNewADCPFile = fullfile(path,[name, 'P.cdf']);
    [theNewADCPFile, theMaskFile] = pressuremask (settings.trimFile,...
        theMaskFile,theNewADCPFile)
end

if 1, % rotate from beam to earth coordinates, translate raw netCDF to EPIC
    [path, name, ext] = fileparts(settings.trimFile);
    theNewADCPFile = fullfile(path,[name, 'P.cdf']);
    if exist(theNewADCPFile,'file'),
        settings.trimFile = theNewADCPFile;
        disp(['Using ',settings.trimFile,' for adcp2ep'])
    end
    adcp2ep(settings.trimFile, settings.adcp2ep.epDataFile, ...
        settings.adcp2ep.ADCPtype, settings.adcp2ep.dlgFile, settings.adcp2ep)
end

diary off
