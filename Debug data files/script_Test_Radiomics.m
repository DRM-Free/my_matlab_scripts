
%This script is intended for automated ROIs verifications. It has worked so
%far, good to run this before launching features processing.


clear,fprintf('\n'), warning off, pathWORK = pwd;
if isempty(mfilename) % That means we are running the script from the command line using the following format (mandatory): matlab -nodisplay -nodesktop -nosplash -singleCompThread < script_ComputeRadiomics.m >& script_ComputeRadiomics.log &
    [scriptFileName,logFileName] = scriptCommandLine_FindNames(pathWORK);
else
    scriptFileName = [mfilename,'.m'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          PARAMETER OPTIONS                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Change parameters where you see the word "OPTION" in the comment.
% NOTES: - All scale parameters below have the following format: [Xin,Yin,Zslice], where Xin and Yin are the X (left to right) and Y (bottom to top) IN-PLANE resolutions, and Zslice is the slice spacing, NO MATTER THE ORIENTATION OF THE VOLUME (i.e. axial , sagittal, coronal).   
%        - If interpolation in the slice direction (no matter the orientation) is not wanted (i.e. 2D case), please used vectors with only two entries [Xin,Yin] for the scale parameters below (e.g. scale = [2,2]).
%        - If no interpolation at all is wanted, use 0 as the scale parameter (e.g. scale = 0). It will be recorded as such in the final radiomics structure for differentiation purposes.

% RADIOMIC PARAMETERS OPTIONS ---------------------------------------------

% 1. MRI PARAMETERS
imParamMR.interp.scaleNonText = [3,3,3]; % OPTION: Resolution in mm for the computation of non-texture features. Here, given the large difference between commonly seen in-plane resolution (~ 1 mm) and slice thickness (~ 5 mm), we take some middle point.
imParamMR.interp.scaleText = {[1,1,1],[2,2,2],[3,3,3],[4,4,4]}; % OPTION: Different resolutions in mm tested for the computation of texture features. Each cell entry is a [X,Y,Z] resolution in MATLAB world coordinate.
imParamMR.interp.volInterp = 'linear'; % OPTION: Using linear interpolation for imaging intensities. Conservative choice to prevent interpolation craziness.
imParamMR.interp.glRound = []; % OPTION: No grey-level rounding
imParamMR.interp.roiInterp = 'linear'; % OPTION: Using linear interpolation for ROI mask. Conservative choice to prevent interpolation craziness.
imParamMR.interp.roiPV = 0.5; % OPTION: After interpolation, a value >=0.5 is assigned to a 1, and <0.5 to a 0.
imParamMR.reSeg.range = []; % OPTION: No range re-segmentation is performed for MR.
imParamMR.reSeg.outliers = 'Collewet'; % OPTION: Using Collewet normalization to remove outliers for MRI.
imParamMR.discretisation.IH.type = 'FBN'; % OPTION: Using fixed bin number for intensity-histogram features.
imParamMR.discretisation.IH.val = 64; % OPTION: Using 64 grey-levels for intensity-histogram features.
imParamMR.discretisation.IVH.type = 'FBN'; % OPTION: Using fixed bin number for intensity-volume histogram features.
imParamMR.discretisation.IVH.val = 1000; % OPTION: Using 1000 grey-levels for intensity-volume histogram features.
imParamMR.discretisation.texture.type = {'FBN','FBNequal'}; % OPTION: Using two different types of quantization algorithms (always fixed bin number for MR for now). If "FBS" or "FBSequal" is used, the minimum value of the ROI will be used in FBS discretisation since the lower bound of the re-segmentation range cannot be defined for arbitrary MRI intensity units (not recommended to use "FBS" or "FBSequal").
imParamMR.discretisation.texture.val = {[8,16,32,64],[8,16,32,64]}; % OPTION: Gray-levels to test for each algorithm on the above line (definition depends on the algorithm). The total number must be the same in each cell entry.
imParamMR.type = 'MRscan';
imParamMR.intensity = 'arbitrary'; % OPTION: MRI is arbitrary intensity units. Use 'arbitrary' to not compute some features that depends on absolute intensity values. Use 'definite' to compute them all anyway.
imParams.MRscan.image = imParamMR;

% 2. CT PARAMETERS
imParamCT.interp.scaleNonText = [2,2,2]; % OPTION: Resolution in mm for the computation of non-texture features. Here, given the difference between commonly seen in-plane resolution (~ 1 mm) and slice thickness (~ 3 mm), we take some middle point.
imParamCT.interp.scaleText = {[1,1,1],[2,2,2],[3,3,3],[4,4,4]}; % OPTION: Different resolutions in mm tested for the computation of texture features. Each cell entry is a [X,Y,Z] resolution in MATLAB world coordinate.
imParamCT.interp.volInterp = 'linear'; % OPTION: Using cubic interpolation for imaging intensities. Conservative choice to prevent interpolation craziness.
imParamCT.interp.glRound = 1; % OPTION: Grey-level rounding to 1 HU.
imParamCT.interp.roiInterp = 'linear'; % OPTION: Using cubic interpolation for ROI mask. Conservative choice to prevent interpolation craziness.
imParamCT.interp.roiPV = 0.5; % OPTION: After interpolation, a value >=0.5 is assigned to a 1, and <0.5 to a 0.
imParamCT.reSeg.range = [-500,400]; % OPTION: Voxels within the ROI with HU outside that range are discarded. This can be adjusted depending on tumour type. For now, it covers a range of HU going from lungs to dense soft-tissues. If you are only working with soft-tissue sarcomas for example, perhaps a range of [-100,400] would be more meaningful. The minimal value is also of special importance for FBS discretisation. If the lower bound of the re-segmentation range is not defined, the minimum value of the ROI will be used in FBS discretisation (not recommended). 
imParamCT.reSeg.outliers = ''; % OPTION: Not using outlier removal for CT (for now).
imParamCT.discretisation.IH.type = 'FBN'; % OPTION: Using fixed bin number for intensity-histogram features.
imParamCT.discretisation.IH.val = 64; % OPTION: Using 64 grey-levels for intensity-histogram features.
imParamCT.discretisation.IVH = []; % OPTION: No need to discretise for CT, natural integer discretisation due to HU. Using "[]" is similar to FBS with a bin width of 1, but without a minimum value set up like in the case of PET (SUV = 0). But shall we also use a set minimal value (e.g. -500 HU as defined in imParam.reSgeg.range(1)) for CT for IVH features as well? If yes, use the two lines below instead (commented for now).
imParamCT.discretisation.texture.type = {'FBN','FBNequal','FBS','FBSequal'}; % OPTION: Using four different types of quantization algorithms. If "FBS" or "FBSequal" is used, imParam.reSeg.range must be defined, as userSetMinVal will be assigned to imParam.reSeg.range(1).
imParamCT.discretisation.texture.val = {[8,16,32,64],[8,16,32,64],[12.5,25,50,100],[12.5,25,50,100]}; % OPTION: Gray-levels to test for each algorithm on the above line (definition depends on the algorithm). The total number must be the same in each cell entry. For the FBS algorithm, we assume values are in units of HU.
imParamCT.type = 'CTscan';
imParamCT.intensity = 'definite'; % OPTION: Definite intensity units (HU). 
imParams.CTscan.image = imParamCT;

% 3. PET PARAMETERS (assuming we always analyze SUV maps)
imParamPET.interp.scaleNonText = [4,4,4]; % OPTION: Resolution in mm for the computation of non-texture features. Common PET resolution is close to that.
imParamPET.interp.scaleText = {[1,1,1],[2,2,2],[3,3,3],[4,4,4]}; % OPTION: Different resolutions in mm tested for the computation of texture features. Each cell entry is a [X,Y,Z] resolution in MATLAB world coordinate.
imParamPET.interp.volInterp = 'linear'; % OPTION: Using cubic interpolation for imaging intensities. Conservative choice to prevent interpolation craziness.
imParamPET.interp.glRound = []; % OPTION: No grey-level rounding, as everything is computed from continuous SUV maps.
imParamPET.interp.roiInterp = 'linear'; % OPTION: Using cubic interpolation for ROI mask. Conservative choice to prevent interpolation craziness.
imParamPET.interp.roiPV = 0.5; % OPTION: After interpolation, a value >=0.5 is assigned to a 1, and <0.5 to a 0.
imParamPET.reSeg.range = [0,inf]; % OPTION: We are working with SUV maps, going from 0 to infinity. The minimal value is of special importance for FBS discretisation. If the lower bound of the re-segmentation range is not defined, the minimum value of the ROI will be used in FBS discretisation (not recommended).
imParamPET.reSeg.outliers = ''; % OPTION: Not using outlier removal for PET (for now).
imParamPET.discretisation.IH.type = 'FBN'; % OPTION: Using fixed bin number for intensity-histogram features.
imParamPET.discretisation.IH.val = 64; % OPTION: Using 64 grey-levels for intensity-histogram features.
imParamPET.discretisation.IVH.type = 'FBS'; % OPTION: Using fixed bin size for intensity-volume histogram features with PET. imParam.reSeg.range must be defined, as userSetMinVal will be assigned to imParam.reSeg.range(1).
imParamPET.discretisation.IVH.val = 0.1; % OPTION: Using 0.1 SUV bin width for intensity-histogram features.
imParamPET.discretisation.texture.type = {'FBN','FBNequal','FBS','FBSequal'}; % OPTION: Using four different types of quantization algorithms. If "FBS" or "FBSequal" is used, imParam.reSeg.range must be defined, as userSetMinVal will be assigned to imParam.reSeg.range(1).
imParamPET.discretisation.texture.val = {[8,16,32,64],[8,16,32,64],[0.25,0.5,1,2],[0.25,0.5,1,2]}; % OPTION: Gray-levels to test for each algorithm on the above line (definition depends on the algorithm). The total number must be the same in each cell entry. For the FBS algorithm, we assume values are in units of SUV.
imParamPET.type = 'PTscan';
imParamPET.intensity = 'definite'; % OPTION: Definite intensity units (SUV).
imParams.PTscan.image = imParamPET;

% FILTER PARAMETERS (considered as arbitrary intensities). No FBS algorithm should ever be used at the moment, or otherwise the code will fail (TO SOLVE TO ALLOW THE USE OF THE MINIMUM VALUE OF THE ROI?).
imParamFilter.discretisation.IH.type = 'FBN'; % Using fixed bin number for intensity-histogram features.
imParamFilter.discretisation.IH.val = 64; % OPTION: Using 64 grey-levels for intensity-histogram features.
imParamFilter.discretisation.IVH.type = 'FBN'; % Using fixed bin number for intensity-volume histogram features.
imParamFilter.discretisation.IVH.val = 1000; % OPTION: Using 1000 grey-levels for intensity-volume histogram features.
imParamFilter.discretisation.texture.type = {'FBN','FBNequal'}; % Using two different types of quantization algorithms (always fixed bin number for MR for now).
imParamFilter.discretisation.texture.val = {[8,16,32,64],[8,16,32,64]}; % OPTION: Gray-levels to test for each algorithm on the above line (definition depends on the algorithm). The total number must be the same in each cell entry.
imParamFilter.type = 'filter';
imParamFilter.intensity = 'filter'; % OPTION: Arbitrary intensity units. Use 'filter' to not compute some features that depends on absolute intensity values. Use 'definite' to compute them all anyway.

% -------------------------------------------------------------------------

% ROI OPTIONS
roiTypes = {'auto(AB)','auto(DR)','auto(JB)','auto(LB)','auto(RW)',...
            'vis(AB)','vis(DR)','vis(JB)','vis(LB)','vis(RW)'}; % Name of radiomics csv config files.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    RADIOMIC FEATURE COMPUTATION CODE                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathDATA = fullfile(pathWORK,'DATA'); pathCSV = fullfile(pathWORK,'CSV');

% 2. Testing for ROIs
test_compute_radiomics(pathDATA,pathCSV,imParams,roiTypes);
