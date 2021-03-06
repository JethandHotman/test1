% scriptexample - for the demo data


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

 
% --------- set up the information needed by the programs
%
% metadata for mooring 9991
settings.numRawFile = 1; % number of raw binary ADCP files (*.000 or *.PD0), max = 2
settings.rawdata1 = '9991wh000.000'; % raw file #1
settings.rawdata2 = ''; % raw file #2, if any
settings.rawcdf = '9991wh.cdf'; % output file name for the raw data in netCDF format
settings.theFilledFile = '9991whF.cdf'; % the name of the fill file
settings.theMaskFile = '9991wh.msk'; % the name of the mask file
settings.theNewADCPFile = '9991whM.cdf'; % the name of the new file with the mask applied
settings.trimFile = '9991whT.cdf'; % the name of the file trimmed by time out of water and by bin
settings.rdi2cdf.run = 1; % force runadcp to run rdi2cdf (future implementation)
settings.rdi2cdf.Mooring_number = '9991'; % mooring number (USGS) or other identifier
settings.rdi2cdf.Deployment_date = '19-may-2004';  % date the ADCP entered the water
settings.rdi2cdf.Recovery_date = '24-may-2004'; % date the ADCP exited the water
settings.water_depth = 31.7; % in meters
settings.rdi2cdf.ADCP_serial_number = 473; 
settings.rdi2cdf.xducer_offset = 3.3; % ADCP transducer offset from the sea bed
settings.rdi2cdf.pred_accuracy = 0.35; % from TRDI PLAN in cm/s
settings.rdi2cdf.slow_by = 0; % clock drift
settings.rdi2cdf.magnetic = -15.63; % declination in degrees, west is negative
settings.fixens.run = 1; % force runadcp to run fixens (future implementation)
settings.runmask.noninteractive = 1; % don't bring up starbare in runmask 
settings.trimbins.numRawFile = settings.numRawFile; % leave this alone
settings.trimbins.rawdata1 = settings.rawdata1; % leave this alone
settings.trimbins.rawdata2 = settings.rawdata2; % leave this alone
settings.trimbins.trimFile = settings.trimFile; % leave this alone
% method to remove bins above the surface (see trimbins documentation
settings.trimbins.method = 'RDI Surface Program';
% percent of water column to make sure is preserved when trimming (1 = 100%)
settings.trimbins.percentwc = 1.12; % to capture full range of tide
settings.trimbins.ADCP_offset = settings.rdi2cdf.xducer_offset; % leave this alone
% path to the TRDI surface program, if you are on a PC
% we have permission to distribute TRDI's surface.exe with the toolbox
% so this should be your toolbox path, Demo directory
settings.trimbins.progPath = 'C:\mfiles\m_cmg\adcp_tbx\trunk\AddOns'; % or ''
settings.adcp2ep.epDataFile = '9991wh.nc'; % final output file name
settings.adcp2ep.experiment = 'Demonstration'; % your metadata
settings.adcp2ep.project = 'The most important science'; % your metadata
settings.adcp2ep.descript = 'Will solve everything'; % your metadata, station or site number, for example
settings.adcp2ep.SciPi = 'Einstein'; % your metadata, principal investigator
settings.adcp2ep.cmnt = 'barnacles were found on the transducers';  % your metadata
settings.adcp2ep.water_mass = ' '; % an EPIC requirement
settings.adcp2ep.long = 70.784908; % always positive degrees
settings.adcp2ep.lonUnits = 'degrees_west';
settings.adcp2ep.latit = 42.378043; % always positive degrees
settings.adcp2ep.latUnits = 'degrees_north';
% the dialog file for your ADCP, there is one in the Demo directory.
% the toolbox use the instrument elevation and azimuth specific to each ADCP
settings.adcp2ep.dlgFile = 'wh999.dlg'; % generated by the ADCP using the PS3 command
settings.adcp2ep.ADCPtype = 'WH'; % workhorse or BB for broadband

% --------------------- run the programs
%
% turn each step "on" and "off" by setting "if 0" to "if 1"
% steps must be run in sequence

diary(sprintf('run%s',datestr(now, 30)))

if 1, % translate to netcdf, mask for basic errors and trim the data
    runadcp(settings)
end

if 1, % apply a mask that tracks the surface - if you wish to
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
