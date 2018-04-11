function [ID] = getPatientID(path)
%GETPATIENT Takes patient ID from rtstruct file.
%  It won't find it unless rtstruct with usual name is present
returnPath=pwd;
cd(path);
info = dicominfo("RTstruct.dcm");
ID=info.PatientID;
cd(returnPath);

end

