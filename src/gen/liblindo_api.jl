# Julia wrapper for header: lindo.h
# Automatically generated using Clang.jl

function check_error(pEnv, ErrorCode)
    if ErrorCode != 0
        pachMessage = Vector{UInt8}(undef,1024)
        LSgetErrorMessage(pEnv, ErrorCode, pachMessage)
        cast_pachMessage = unsafe_string(pointer(pachMessage))
        error("Error --> $(cast_pachMessage)")
    else
        nothing
    end
    return
end

function addToUdata(key::Union{pLSmodel, pLSenv})
    if isUdata(key) == false
        udata_Dict[key] = jlLindoData_t()
    end
end

function isUdata(key::Union{pLSmodel, pLSenv})
    ret = getkey(udata_Dict, key, -1)
    if ret == -1
        return false
    else
        return true
    end
end

function LScreateEnv(pnErrorcode, pszPassword)
    ccall((:LScreateEnv, liblindo), pLSenv, (Ptr{Cint}, Ptr{Cchar}), pnErrorcode, pszPassword)
end

function LScreateModel(pEnv, pnErrorcode)
    ccall((:LScreateModel, liblindo), pLSmodel, (pLSenv, Ptr{Cint}), pEnv, pnErrorcode)
end

function LSdeleteEnv(pEnv)
    ccall((:LSdeleteEnv, liblindo), Cint, (Ref{pLSenv},), pEnv)
end

function LSdeleteModel(pModel)
    ccall((:LSdeleteModel, liblindo), Cint, (Ref{pLSmodel},), pModel)
end

function LSloadLicenseString(pszFname, pachLicense)
    ccall((:LSloadLicenseString, liblindo), Cint, (Ptr{Cchar}, Ptr{Cchar}), pszFname, pachLicense)
end

function LSgetVersionInfo(pachVernum, pachBuildDate)
    ccall((:LSgetVersionInfo, liblindo), Cvoid, (Ptr{Cchar}, Ptr{Cchar}), pachVernum, pachBuildDate)
end

function LScopyParam(sourceModel, targetModel, mSolverType)
    ccall((:LScopyParam, liblindo), Cint, (pLSmodel, pLSmodel, Cint), sourceModel, targetModel, mSolverType)
end

function LSsetXSolverLibrary(pEnv, mVendorId, szLibrary)
    ccall((:LSsetXSolverLibrary, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, mVendorId, szLibrary)
end

function LSgetXSolverLibrary(pEnv, mVendorId, szLibrary)
    ccall((:LSgetXSolverLibrary, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, mVendorId, szLibrary)
end

function LSreadMPSFile(pModel, pszFname, nFormat)
    ccall((:LSreadMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSwriteMPSFile(pModel, pszFname, nFormat)
    ccall((:LSwriteMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSreadLINDOFile(pModel, pszFname)
    ccall((:LSreadLINDOFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteLINDOFile(pModel, pszFname)
    ccall((:LSwriteLINDOFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadLINDOStream(pModel, pszStream, nStreamLen)
    ccall((:LSreadLINDOStream, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszStream, nStreamLen)
end

function LSwriteLINGOFile(pModel, pszFname)
    ccall((:LSwriteLINGOFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteDualMPSFile(pModel, pszFname, nFormat, nObjSense)
    ccall((:LSwriteDualMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint, Cint), pModel, pszFname, nFormat, nObjSense)
end

function LSwriteDualLINDOFile(pModel, pszFname, nObjSense)
    ccall((:LSwriteDualLINDOFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nObjSense)
end

function LSwriteSolution(pModel, pszFname)
    ccall((:LSwriteSolution, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteNLSolution(pModel, pszFname)
    ccall((:LSwriteNLSolution, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteSolutionOfType(pModel, pszFname, nFormat)
    ccall((:LSwriteSolutionOfType, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSwriteIIS(pModel, pszFname)
    ccall((:LSwriteIIS, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteIUS(pModel, pszFname)
    ccall((:LSwriteIUS, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadMPIFile(pModel, pszFname)
    ccall((:LSreadMPIFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteMPIFile(pModel, pszFname)
    ccall((:LSwriteMPIFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteMPXFile(pModel, pszFname, mMask)
    ccall((:LSwriteMPXFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, mMask)
end

function LSwriteWithSetsAndSC(pModel, pszFname, nFormat)
    ccall((:LSwriteWithSetsAndSC, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSreadBasis(pModel, pszFname, nFormat)
    ccall((:LSreadBasis, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSwriteBasis(pModel, pszFname, nFormat)
    ccall((:LSwriteBasis, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nFormat)
end

function LSwriteVarPriorities(pModel, pszFname, nMode)
    ccall((:LSwriteVarPriorities, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFname, nMode)
end

function LSreadLPFile(pModel, pszFname)
    ccall((:LSreadLPFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadLPStream(pModel, pszStream, nStreamLen)
    ccall((:LSreadLPStream, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszStream, nStreamLen)
end

function LSreadSDPAFile(pModel, pszFname)
    ccall((:LSreadSDPAFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadCBFFile(pModel, pszFname)
    ccall((:LSreadCBFFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadMPXFile(pModel, pszFname)
    ccall((:LSreadMPXFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadMPXStream(pModel, pszStream, nStreamLen)
    ccall((:LSreadMPXStream, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszStream, nStreamLen)
end

function LSreadNLFile(pModel, pszFname)
    ccall((:LSreadNLFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSgetErrorMessage(pEnv, nErrorcode, pachMessage)
    ccall((:LSgetErrorMessage, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, nErrorcode, pachMessage)
end

function LSgetFileError(pModel, pnLinenum, pachLinetxt)
    ccall((:LSgetFileError, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cchar}), pModel, pnLinenum, pachLinetxt)
end

function LSgetErrorRowIndex(pModel, piRow)
    ccall((:LSgetErrorRowIndex, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, piRow)
end

function LSgetDataType(pEnv, nDataMacro)
    ccall((:LSgetDataType, liblindo), Cint, (pLSenv, Cint), pEnv, nDataMacro)
end

function LSsetModelParameter(pModel, nParameter, pvValue)
    ccall((:LSsetModelParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nParameter, pvValue)
end

function LSgetModelParameter(pModel, nParameter, pvValue)
    ccall((:LSgetModelParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nParameter, pvValue)
end

function LSsetEnvParameter(pEnv, nParameter, pvValue)
    ccall((:LSsetEnvParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cvoid}), pEnv, nParameter, pvValue)
end

function LSgetEnvParameter(pEnv, nParameter, pvValue)
    ccall((:LSgetEnvParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cvoid}), pEnv, nParameter, pvValue)
end

function LSsetModelDouParameter(pModel, nParameter, dVal)
    ccall((:LSsetModelDouParameter, liblindo), Cint, (pLSmodel, Cint, Cdouble), pModel, nParameter, dVal)
end

function LSgetModelDouParameter(pModel, nParameter, pdVal)
    ccall((:LSgetModelDouParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, nParameter, pdVal)
end

function LSsetModelIntParameter(pModel, nParameter, nVal)
    ccall((:LSsetModelIntParameter, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, nParameter, nVal)
end

function LSgetModelIntParameter(pModel, nParameter, pnVal)
    ccall((:LSgetModelIntParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nParameter, pnVal)
end

function LSsetEnvDouParameter(pEnv, nParameter, dVal)
    ccall((:LSsetEnvDouParameter, liblindo), Cint, (pLSenv, Cint, Cdouble), pEnv, nParameter, dVal)
end

function LSgetEnvDouParameter(pEnv, nParameter, pdVal)
    ccall((:LSgetEnvDouParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cdouble}), pEnv, nParameter, pdVal)
end

function LSsetEnvIntParameter(pEnv, nParameter, nVal)
    ccall((:LSsetEnvIntParameter, liblindo), Cint, (pLSenv, Cint, Cint), pEnv, nParameter, nVal)
end

function LSgetEnvIntParameter(pEnv, nParameter, pnVal)
    ccall((:LSgetEnvIntParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cint}), pEnv, nParameter, pnVal)
end

function LSreadModelParameter(pModel, pszFname)
    ccall((:LSreadModelParameter, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSreadEnvParameter(pEnv, pszFname)
    ccall((:LSreadEnvParameter, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, pszFname)
end

function LSwriteModelParameter(pModel, pszFname)
    ccall((:LSwriteModelParameter, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSwriteEnvParameter(pEnv, pszFname)
    ccall((:LSwriteEnvParameter, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, pszFname)
end

function LSwriteParameterAsciiDoc(pEnv, pszFileName)
    ccall((:LSwriteParameterAsciiDoc, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, pszFileName)
end

function LSgetIntParameterRange(pModel, nParameter, pnValMIN, pnValMAX)
    ccall((:LSgetIntParameterRange, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, nParameter, pnValMIN, pnValMAX)
end

function LSgetDouParameterRange(pModel, nParameter, pdValMIN, pdValMAX)
    ccall((:LSgetDouParameterRange, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nParameter, pdValMIN, pdValMAX)
end

function LSgetParamShortDesc(pEnv, nParam, pachDescription)
    ccall((:LSgetParamShortDesc, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, nParam, pachDescription)
end

function LSgetParamLongDesc(pEnv, nParam, pachDescription)
    ccall((:LSgetParamLongDesc, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, nParam, pachDescription)
end

function LSgetParamMacroName(pEnv, nParam, pachParam)
    ccall((:LSgetParamMacroName, liblindo), Cint, (pLSenv, Cint, Ptr{Cchar}), pEnv, nParam, pachParam)
end

function LSgetParamMacroID(pEnv, szParam, pnParamType, pnParam)
    ccall((:LSgetParamMacroID, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}), pEnv, szParam, pnParamType, pnParam)
end

function LSgetQCEigs(pModel, iRow, pachWhich, padEigval, padEigvec, nEigval, ncv, dTol, nMaxIter)
    ccall((:LSgetQCEigs, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Ptr{Cdouble}}, Cint, Cint, Cdouble, Cint), pModel, iRow, pachWhich, padEigval, padEigvec, nEigval, ncv, dTol, nMaxIter)
end

function LSgetEigs(nDim, chUL, padA, padD, padV, pnInfo)
    ccall((:LSgetEigs, liblindo), Cint, (Cint, UInt8, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nDim, chUL, padA, padD, padV, pnInfo)
end

function LSgetEigg(nDim, chJOBV, padA, padWR, padWI, padVRR, padVRI, padVLR, padVLI, pnInfo)
    ccall((:LSgetEigg, liblindo), Cint, (Cint, UInt8, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nDim, chJOBV, padA, padWR, padWI, padVRR, padVRI, padVLR, padVLI, pnInfo)
end

function LSgetMatrixTranspose(nRows, nCols, padA, padAT)
    ccall((:LSgetMatrixTranspose, liblindo), Cint, (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}), nRows, nCols, padA, padAT)
end

function LSgetMatrixInverse(nRows, padA, padAinv, pnInfo)
    ccall((:LSgetMatrixInverse, liblindo), Cint, (Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, padA, padAinv, pnInfo)
end

function LSgetMatrixInverseSY(nRows, chUpLo, padA, padAinv, pnInfo)
    ccall((:LSgetMatrixInverseSY, liblindo), Cint, (Cint, UInt8, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, chUpLo, padA, padAinv, pnInfo)
end

function LSgetMatrixLUFactor(nRows, nCols, padA, panP, padL, padU, pnInfo)
    ccall((:LSgetMatrixLUFactor, liblindo), Cint, (Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, nCols, padA, panP, padL, padU, pnInfo)
end

function LSgetMatrixQRFactor(nRows, nCols, padA, padQ, padR, pnInfo)
    ccall((:LSgetMatrixQRFactor, liblindo), Cint, (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, nCols, padA, padQ, padR, pnInfo)
end

function LSgetMatrixDeterminant(nRows, padA, padDet, pnInfo)
    ccall((:LSgetMatrixDeterminant, liblindo), Cint, (Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, padA, padDet, pnInfo)
end

function LSgetMatrixCholFactor(nRows, chUpLo, padA, padUL, pnInfo)
    ccall((:LSgetMatrixCholFactor, liblindo), Cint, (Cint, UInt8, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, chUpLo, padA, padUL, pnInfo)
end

function LSgetMatrixSVDFactor(nRows, nCols, padA, padU, padS, padVT, pnInfo)
    ccall((:LSgetMatrixSVDFactor, liblindo), Cint, (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), nRows, nCols, padA, padU, padS, padVT, pnInfo)
end

function LSgetMatrixFSolve(szuplo, sztrans, szdiag, nRows, dAlpha, padA, padB, padX)
    ccall((:LSgetMatrixFSolve, liblindo), Cint, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), szuplo, sztrans, szdiag, nRows, dAlpha, padA, padB, padX)
end

function LSgetMatrixBSolve(szuplo, sztrans, szdiag, nRows, dAlpha, padA, padB, padX)
    ccall((:LSgetMatrixBSolve, liblindo), Cint, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), szuplo, sztrans, szdiag, nRows, dAlpha, padA, padB, padX)
end

function LSgetMatrixSolve(szside, szuplo, sztrans, szdiag, nRows, nRHS, dAlpha, padA, nLDA, padB, nLDB, padX)
    ccall((:LSgetMatrixSolve, liblindo), Cint, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Cint, Cint, Cdouble, Ptr{Cdouble}, Cint, Ptr{Cdouble}, Cint, Ptr{Cdouble}), szside, szuplo, sztrans, szdiag, nRows, nRHS, dAlpha, padA, nLDA, padB, nLDB, padX)
end

function LSloadLPData(pModel, nCons, nVars, dObjSense, dObjConst, padC, padB, pszConTypes, nAnnz, paiAcols, panAcols, padAcoef, paiArows, padL, padU)
    ccall((:LSloadLPData, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cchar}, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nCons, nVars, dObjSense, dObjConst, padC, padB, pszConTypes, nAnnz, paiAcols, panAcols, padAcoef, paiArows, padL, padU)
end

function LSloadQCData(pModel, nQCnnz, paiQCrows, paiQCcols1, paiQCcols2, padQCcoef)
    ccall((:LSloadQCData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, nQCnnz, paiQCrows, paiQCcols1, paiQCcols2, padQCcoef)
end

function LSloadConeData(pModel, nCone, pszConeTypes, padConeAlpha, paiConebegcone, paiConecols)
    ccall((:LSloadConeData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}), pModel, nCone, pszConeTypes, padConeAlpha, paiConebegcone, paiConecols)
end

function LSloadPOSDData(pModel, nPOSD, paiPOSDdim, paiPOSDbeg, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
    ccall((:LSloadPOSDData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nPOSD, paiPOSDdim, paiPOSDbeg, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
end

function LSloadALLDIFFData(pModel, nALLDIFF, paiAlldiffDim, paiAlldiffL, paiAlldiffU, paiAlldiffBeg, paiAlldiffVar)
    ccall((:LSloadALLDIFFData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nALLDIFF, paiAlldiffDim, paiAlldiffL, paiAlldiffU, paiAlldiffBeg, paiAlldiffVar)
end

function LSloadSETSData(pModel, nSETS, pszSETStype, paiCARDnum, paiSETSbegcol, paiSETScols)
    ccall((:LSloadSETSData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nSETS, pszSETStype, paiCARDnum, paiSETSbegcol, paiSETScols)
end

function LSloadSemiContData(pModel, nSCVars, paiVars, padL, padU)
    ccall((:LSloadSemiContData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nSCVars, paiVars, padL, padU)
end

function LSloadVarType(pModel, pszVarTypes)
    ccall((:LSloadVarType, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszVarTypes)
end

function LSloadNameData(pModel, pszTitle, pszObjName, pszRhsName, pszRngName, pszBndname, paszConNames, paszVarNames, paszConeNames)
    ccall((:LSloadNameData, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}), pModel, pszTitle, pszObjName, pszRhsName, pszRngName, pszBndname, paszConNames, paszVarNames, paszConeNames)
end

function LSloadNLPData(pModel, paiNLPcols, panNLPcols, padNLPcoef, paiNLProws, nNLPobj, paiNLPobj, padNLPobj)
    ccall((:LSloadNLPData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, paiNLPcols, panNLPcols, padNLPcoef, paiNLProws, nNLPobj, paiNLPobj, padNLPobj)
end

function LSloadNLPDense(pModel, nCons, nVars, dObjSense, pszConTypes, pszVarTypes, padX0, padL, padU)
    ccall((:LSloadNLPDense, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nCons, nVars, dObjSense, pszConTypes, pszVarTypes, padX0, padL, padU)
end

function LSloadInstruct(pModel, nCons, nObjs, nVars, nNumbers, panObjSense, pszConType, pszVarType, panInstruct, nInstruct, paiVars, padNumVal, padVarVal, paiObjBeg, panObjLen, paiConBeg, panConLen, padLB, padUB)
    ccall((:LSloadInstruct, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nCons, nObjs, nVars, nNumbers, panObjSense, pszConType, pszVarType, panInstruct, nInstruct, paiVars, padNumVal, padVarVal, paiObjBeg, panObjLen, paiConBeg, panConLen, padLB, padUB)
end

function LSaddInstruct(pModel, nCons, nObjs, nVars, nNumbers, panObjSense, pszConType, pszVarType, panInstruct, nInstruct, paiCons, padNumVal, padVarVal, paiObjBeg, panObjLen, paiConBeg, panConLen, padLB, padUB)
    ccall((:LSaddInstruct, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cint}, Cint, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nCons, nObjs, nVars, nNumbers, panObjSense, pszConType, pszVarType, panInstruct, nInstruct, paiCons, padNumVal, padVarVal, paiObjBeg, panObjLen, paiConBeg, panConLen, padLB, padUB)
end

function LSloadStringData(pModel, nStrings, paszStringData)
    ccall((:LSloadStringData, liblindo), Cint, (pLSmodel, Cint, Ptr{Ptr{Cchar}}), pModel, nStrings, paszStringData)
end

function LSloadString(pModel, pszString)
    ccall((:LSloadString, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszString)
end

function LSbuildStringData(pModel)
    ccall((:LSbuildStringData, liblindo), Cint, (pLSmodel,), pModel)
end

function LSdeleteStringData(pModel)
    ccall((:LSdeleteStringData, liblindo), Cint, (pLSmodel,), pModel)
end

function LSdeleteString(pModel)
    ccall((:LSdeleteString, liblindo), Cint, (pLSmodel,), pModel)
end

function LSgetStringValue(pModel, iString, pdValue)
    ccall((:LSgetStringValue, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, iString, pdValue)
end

function LSgetConstraintProperty(pModel, ndxCons, pnConptype)
    ccall((:LSgetConstraintProperty, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, ndxCons, pnConptype)
end

function LSsetConstraintProperty(pModel, ndxCons, nConptype)
    ccall((:LSsetConstraintProperty, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, ndxCons, nConptype)
end

function LSgetGOPVariablePriority(pModel, ndxVar, pnPriority)
    ccall((:LSgetGOPVariablePriority, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, ndxVar, pnPriority)
end

function LSsetGOPVariablePriority(pModel, ndxVar, nPriority)
    ccall((:LSsetGOPVariablePriority, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, ndxVar, nPriority)
end

function LSloadMultiStartSolution(pModel, nIndex)
    ccall((:LSloadMultiStartSolution, liblindo), Cint, (pLSmodel, Cint), pModel, nIndex)
end

function LSloadGASolution(pModel, nIndex)
    ccall((:LSloadGASolution, liblindo), Cint, (pLSmodel, Cint), pModel, nIndex)
end

function LSaddQCShift(pModel, iRow, dShift)
    ccall((:LSaddQCShift, liblindo), Cint, (pLSmodel, Cint, Cdouble), pModel, iRow, dShift)
end

function LSgetQCShift(pModel, iRow, pdShift)
    ccall((:LSgetQCShift, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, iRow, pdShift)
end

function LSresetQCShift(pModel, iRow)
    ccall((:LSresetQCShift, liblindo), Cint, (pLSmodel, Cint), pModel, iRow)
end

function LSaddObjPool(pModel, padC, mObjSense, mRank, dRelOptTol)
    ccall((:LSaddObjPool, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Cint, Cint, Cdouble), pModel, padC, mObjSense, mRank, dRelOptTol)
end

function LSremObjPool(pModel, nObjIndex)
    ccall((:LSremObjPool, liblindo), Cint, (pLSmodel, Cint), pModel, nObjIndex)
end

function LSfreeObjPool(pModel)
    ccall((:LSfreeObjPool, liblindo), Cint, (pLSmodel,), pModel)
end

function LSsetObjPoolParam(pModel, nObjIndex, mParam, dValue)
    ccall((:LSsetObjPoolParam, liblindo), Cint, (pLSmodel, Cint, Cint, Cdouble), pModel, nObjIndex, mParam, dValue)
end

function LSgetObjPoolParam(pModel, nObjIndex, mParam, pdValue)
    ccall((:LSgetObjPoolParam, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}), pModel, nObjIndex, mParam, pdValue)
end

function LSgetObjPoolNumSol(pModel, nObjIndex, pNumSol)
    ccall((:LSgetObjPoolNumSol, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nObjIndex, pNumSol)
end

function LSsetObjPoolName(pModel, nObjIndex, szObjName)
    ccall((:LSsetObjPoolName, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, nObjIndex, szObjName)
end

function LSloadBasis(pModel, panCstatus, panRstatus)
    ccall((:LSloadBasis, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}), pModel, panCstatus, panRstatus)
end

function LSloadVarPriorities(pModel, panCprior)
    ccall((:LSloadVarPriorities, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panCprior)
end

function LSreadVarPriorities(pModel, pszFname)
    ccall((:LSreadVarPriorities, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSloadVarStartPoint(pModel, padPrimal)
    ccall((:LSloadVarStartPoint, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSloadVarStartPointPartial(pModel, nCols, paiCols, padPrimal)
    ccall((:LSloadVarStartPointPartial, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nCols, paiCols, padPrimal)
end

function LSloadMIPVarStartPoint(pModel, padPrimal)
    ccall((:LSloadMIPVarStartPoint, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSloadMIPVarStartPointPartial(pModel, nCols, paiCols, paiPrimal)
    ccall((:LSloadMIPVarStartPointPartial, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, nCols, paiCols, paiPrimal)
end

function LSreadVarStartPoint(pModel, pszFname)
    ccall((:LSreadVarStartPoint, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSloadPrimalStartPoint(pModel, nCols, paiCols, padPrimal)
    ccall((:LSloadPrimalStartPoint, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nCols, paiCols, padPrimal)
end

function LSloadBlockStructure(pModel, nBlock, panRblock, panCblock, nType)
    ccall((:LSloadBlockStructure, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Cint), pModel, nBlock, panRblock, panCblock, nType)
end

function LSloadIISPriorities(pModel, panRprior, panCprior)
    ccall((:LSloadIISPriorities, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}), pModel, panRprior, panCprior)
end

function LSloadSolutionAt(pModel, nObjIndex, nSolIndex)
    ccall((:LSloadSolutionAt, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, nObjIndex, nSolIndex)
end

function LSoptimize(pModel, nMethod, pnSolStatus)
    ccall((:LSoptimize, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nMethod, pnSolStatus)
end

function LSsolveMIP(pModel, pnMIPSolStatus)
    ccall((:LSsolveMIP, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnMIPSolStatus)
end

function LSsolveGOP(pModel, pnGOPSolStatus)
    ccall((:LSsolveGOP, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnGOPSolStatus)
end

function LSoptimizeQP(pModel, pnQPSolStatus)
    ccall((:LSoptimizeQP, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnQPSolStatus)
end

function LScheckConvexity(pModel)
    ccall((:LScheckConvexity, liblindo), Cint, (pLSmodel,), pModel)
end

function LSsolveSBD(pModel, nStages, panRowStage, panColStage, pnStatus)
    ccall((:LSsolveSBD, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nStages, panRowStage, panColStage, pnStatus)
end

function LSsolveMipBnp(pModel, nBlock, pszFname, pnStatus)
    ccall((:LSsolveMipBnp, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cint}), pModel, nBlock, pszFname, pnStatus)
end

function LSgetInfo(pModel, nQuery, pvResult)
    ccall((:LSgetInfo, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nQuery, pvResult)
end

function LSgetProfilerInfo(pModel, mContext, pnCalls, pdElapsedTime)
    ccall((:LSgetProfilerInfo, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, mContext, pnCalls, pdElapsedTime)
end

function LSgetProfilerContext(pModel, mContext)
    ccall((:LSgetProfilerContext, liblindo), Ptr{Cchar}, (pLSmodel, Cint), pModel, mContext)
end

function LSgetPrimalSolution(pModel, padPrimal)
    ccall((:LSgetPrimalSolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSgetDualSolution(pModel, padDual)
    ccall((:LSgetDualSolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padDual)
end

function LSgetReducedCosts(pModel, padRedcosts)
    ccall((:LSgetReducedCosts, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padRedcosts)
end

function LSgetReducedCostsCone(pModel, padRedcosts)
    ccall((:LSgetReducedCostsCone, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padRedcosts)
end

function LSgetSlacks(pModel, padSlacks)
    ccall((:LSgetSlacks, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padSlacks)
end

function LSgetBasis(pModel, panCstatus, panRstatus)
    ccall((:LSgetBasis, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}), pModel, panCstatus, panRstatus)
end

function LSgetSolution(pModel, nWhich, padVal)
    ccall((:LSgetSolution, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, nWhich, padVal)
end

function LSgetNextBestSol(pModel, pnModStatus)
    ccall((:LSgetNextBestSol, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnModStatus)
end

function LSgetMIPPrimalSolution(pModel, padPrimal)
    ccall((:LSgetMIPPrimalSolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSgetMIPDualSolution(pModel, padDual)
    ccall((:LSgetMIPDualSolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padDual)
end

function LSgetMIPReducedCosts(pModel, padRedcosts)
    ccall((:LSgetMIPReducedCosts, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padRedcosts)
end

function LSgetMIPSlacks(pModel, padSlacks)
    ccall((:LSgetMIPSlacks, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padSlacks)
end

function LSgetMIPBasis(pModel, panCstatus, panRstatus)
    ccall((:LSgetMIPBasis, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}), pModel, panCstatus, panRstatus)
end

function LSgetNextBestMIPSol(pModel, pnIntModStatus)
    ccall((:LSgetNextBestMIPSol, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnIntModStatus)
end

function LSgetKBestMIPSols(pModel, pszFname, pfMIPCallback, pvCbData, nMaxSols)
    ccall((:LSgetKBestMIPSols, liblindo), Cint, (pLSmodel, Ptr{Cchar}, MIP_callback_t, Ptr{Cvoid}, Cint), pModel, pszFname, pfMIPCallback, pvCbData, nMaxSols)
end

function LSgetLPData(pModel, pdObjSense, pdObjConst, padC, padB, pachConTypes, paiAcols, panAcols, padAcoef, paiArows, padL, padU)
    ccall((:LSgetLPData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pdObjSense, pdObjConst, padC, padB, pachConTypes, paiAcols, panAcols, padAcoef, paiArows, padL, padU)
end

function LSgetQCData(pModel, paiQCrows, paiQCcols1, paiQCcols2, padQCcoef)
    ccall((:LSgetQCData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, paiQCrows, paiQCcols1, paiQCcols2, padQCcoef)
end

function LSgetQCDatai(pModel, iCon, pnQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
    ccall((:LSgetQCDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iCon, pnQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
end

function LSgetVarType(pModel, pachVarTypes)
    ccall((:LSgetVarType, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pachVarTypes)
end

function LSgetVarStartPoint(pModel, padPrimal)
    ccall((:LSgetVarStartPoint, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSgetVarStartPointPartial(pModel, pnCols, paiCols, padPrimal)
    ccall((:LSgetVarStartPointPartial, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, pnCols, paiCols, padPrimal)
end

function LSgetMIPVarStartPointPartial(pModel, pnCols, paiCols, paiPrimal)
    ccall((:LSgetMIPVarStartPointPartial, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnCols, paiCols, paiPrimal)
end

function LSgetMIPVarStartPoint(pModel, padPrimal)
    ccall((:LSgetMIPVarStartPoint, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padPrimal)
end

function LSgetSETSData(pModel, piNsets, piNtnz, pachSETtype, paiCardnum, paiNnz, paiBegset, paiVarndx)
    ccall((:LSgetSETSData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, piNsets, piNtnz, pachSETtype, paiCardnum, paiNnz, paiBegset, paiVarndx)
end

function LSgetSETSDatai(pModel, iSet, pachSETType, piCardnum, piNnz, paiVarndx)
    ccall((:LSgetSETSDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, iSet, pachSETType, piCardnum, piNnz, paiVarndx)
end

function LSsetSETSStatei(pModel, iSet, mState)
    ccall((:LSsetSETSStatei, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, iSet, mState)
end

function LSgetSemiContData(pModel, piNs, paiVarndx, padL, padU)
    ccall((:LSgetSemiContData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, piNs, paiVarndx, padL, padU)
end

function LSgetALLDIFFData(pModel, pinALLDIFF, paiAlldiffDim, paiAlldiffL, paiAlldiffU, paiAlldiffBeg, paiAlldiffVar)
    ccall((:LSgetALLDIFFData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pinALLDIFF, paiAlldiffDim, paiAlldiffL, paiAlldiffU, paiAlldiffBeg, paiAlldiffVar)
end

function LSgetALLDIFFDatai(pModel, iALLDIFF, piAlldiffDim, piAlldiffL, piAlldiffU, paiAlldiffVar)
    ccall((:LSgetALLDIFFDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, iALLDIFF, piAlldiffDim, piAlldiffL, piAlldiffU, paiAlldiffVar)
end

function LSgetPOSDData(pModel, pinPOSD, paiPOSDdim, paiPOSDnnz, paiPOSDbeg, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
    ccall((:LSgetPOSDData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pinPOSD, paiPOSDdim, paiPOSDnnz, paiPOSDbeg, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
end

function LSgetPOSDDatai(pModel, iPOSD, piPOSDdim, piPOSDnnz, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
    ccall((:LSgetPOSDDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, iPOSD, piPOSDdim, piPOSDnnz, paiPOSDrowndx, paiPOSDcolndx, paiPOSDndx)
end

function LSgetNameData(pModel, pachTitle, pachObjName, pachRhsName, pachRngName, pachBndname, pachConNames, pachConNameData, pachVarNames, pachVarNameData)
    ccall((:LSgetNameData, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cchar}), pModel, pachTitle, pachObjName, pachRhsName, pachRngName, pachBndname, pachConNames, pachConNameData, pachVarNames, pachVarNameData)
end

function LSgetLPVariableDataj(pModel, iVar, pachVartype, pdC, pdL, pdU, pnAnnz, paiArows, padAcoef)
    ccall((:LSgetLPVariableDataj, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iVar, pachVartype, pdC, pdL, pdU, pnAnnz, paiArows, padAcoef)
end

function LSgetVariableNamej(pModel, iVar, pachVarName)
    ccall((:LSgetVariableNamej, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, iVar, pachVarName)
end

function LSgetVariableIndex(pModel, pszVarName, piVar)
    ccall((:LSgetVariableIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszVarName, piVar)
end

function LSgetConstraintNamei(pModel, iCon, pachConName)
    ccall((:LSgetConstraintNamei, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, iCon, pachConName)
end

function LSgetConstraintIndex(pModel, pszConName, piCon)
    ccall((:LSgetConstraintIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszConName, piCon)
end

function LSgetConstraintDatai(pModel, iCon, pachConType, pachIsNlp, pdB)
    ccall((:LSgetConstraintDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cdouble}), pModel, iCon, pachConType, pachIsNlp, pdB)
end

function LSgetLPConstraintDatai(pModel, iCon, pachConType, pdB, pnNnz, piVar, pdAcoef)
    ccall((:LSgetLPConstraintDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iCon, pachConType, pdB, pnNnz, piVar, pdAcoef)
end

function LSgetConeNamei(pModel, iCone, pachConeName)
    ccall((:LSgetConeNamei, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, iCone, pachConeName)
end

function LSgetConeIndex(pModel, pszConeName, piCone)
    ccall((:LSgetConeIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszConeName, piCone)
end

function LSgetConeDatai(pModel, iCone, pachConeType, pdConeAlpha, piNnz, paiCols)
    ccall((:LSgetConeDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}), pModel, iCone, pachConeType, pdConeAlpha, piNnz, paiCols)
end

function LSgetNLPData(pModel, paiNLPcols, panNLPcols, padNLPcoef, paiNLProws, pnNLPobj, paiNLPobj, padNLPobj, pachNLPConTypes)
    ccall((:LSgetNLPData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cchar}), pModel, paiNLPcols, panNLPcols, padNLPcoef, paiNLProws, pnNLPobj, paiNLPobj, padNLPobj, pachNLPConTypes)
end

function LSgetNLPConstraintDatai(pModel, iCon, pnNnz, paiNLPcols, padNLPcoef)
    ccall((:LSgetNLPConstraintDatai, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iCon, pnNnz, paiNLPcols, padNLPcoef)
end

function LSgetNLPVariableDataj(pModel, iVar, pnNnz, panNLProws, padNLPcoef)
    ccall((:LSgetNLPVariableDataj, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iVar, pnNnz, panNLProws, padNLPcoef)
end

function LSgetNLPObjectiveData(pModel, pnNLPobjnnz, paiNLPobj, padNLPobj)
    ccall((:LSgetNLPObjectiveData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, pnNLPobjnnz, paiNLPobj, padNLPobj)
end

function LSgetDualModel(pModel, pDualModel)
    ccall((:LSgetDualModel, liblindo), Cint, (pLSmodel, pLSmodel), pModel, pDualModel)
end

function LSgetInstruct(pModel, pnObjSense, pachConType, pachVarType, panCode, padNumVal, padVarVal, panObjBeg, panObjLength, panConBeg, panConLength, padLwrBnd, padUprBnd)
    ccall((:LSgetInstruct, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pnObjSense, pachConType, pachVarType, panCode, padNumVal, padVarVal, panObjBeg, panObjLength, panConBeg, panConLength, padLwrBnd, padUprBnd)
end

function LScalinfeasMIPsolution(pModel, pdIntPfeas, pbConsPfeas, padPrimalMipsol)
    ccall((:LScalinfeasMIPsolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pdIntPfeas, pbConsPfeas, padPrimalMipsol)
end

function LSgetRoundMIPsolution(pModel, padPrimal, padPrimalRound, pdObjRound, pdPfeasRound, pnstatus, iUseOpti)
    ccall((:LSgetRoundMIPsolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Cint), pModel, padPrimal, padPrimalRound, pdObjRound, pdPfeasRound, pnstatus, iUseOpti)
end

function LSgetDuplicateColumns(pModel, nCheckVals, pnSets, paiSetsBeg, paiCols)
    ccall((:LSgetDuplicateColumns, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nCheckVals, pnSets, paiSetsBeg, paiCols)
end

function LSgetRangeData(pModel, padR)
    ccall((:LSgetRangeData, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, padR)
end

function LSgetJac(pModel, pnJnonzeros, pnJobjnnz, paiJrows, paiJcols, padJcoef, padX)
    ccall((:LSgetJac, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pnJnonzeros, pnJobjnnz, paiJrows, paiJcols, padJcoef, padX)
end

function LSgetHess(pModel, pnHnonzeros, paiHrows, paiHcol1, paiHcol2, padHcoef, padX)
    ccall((:LSgetHess, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pnHnonzeros, paiHrows, paiHcol1, paiHcol2, padHcoef, padX)
end

function LSaddConstraints(pModel, nNumaddcons, pszConTypes, paszConNames, paiArows, padAcoef, paiAcols, padB)
    ccall((:LSaddConstraints, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}), pModel, nNumaddcons, pszConTypes, paszConNames, paiArows, padAcoef, paiAcols, padB)
end

function LSaddVariables(pModel, nNumadds, pszVarTypes, paszVarNames, paiAcols, panAcols, padAcoef, paiArows, padC, padL, padU)
    ccall((:LSaddVariables, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nNumadds, pszVarTypes, paszVarNames, paiAcols, panAcols, padAcoef, paiArows, padC, padL, padU)
end

function LSaddCones(pModel, nCone, pszConeTypes, padConeAlpha, paszConenames, paiConebegcol, paiConecols)
    ccall((:LSaddCones, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cdouble}, Ptr{Ptr{Cchar}}, Ptr{Cint}, Ptr{Cint}), pModel, nCone, pszConeTypes, padConeAlpha, paszConenames, paiConebegcol, paiConecols)
end

function LSaddSETS(pModel, nSETS, pszSETStype, paiCARDnum, paiSETSbegcol, paiSETScols)
    ccall((:LSaddSETS, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nSETS, pszSETStype, paiCARDnum, paiSETSbegcol, paiSETScols)
end

function LSaddQCterms(pModel, nQCnonzeros, paiQCconndx, paiQCndx1, paiQCndx2, padQCcoef)
    ccall((:LSaddQCterms, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, nQCnonzeros, paiQCconndx, paiQCndx1, paiQCndx2, padQCcoef)
end

function LSdeleteConstraints(pModel, nCons, paiCons)
    ccall((:LSdeleteConstraints, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nCons, paiCons)
end

function LSdeleteCones(pModel, nCones, paiCones)
    ccall((:LSdeleteCones, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nCones, paiCones)
end

function LSdeleteSETS(pModel, nSETS, paiSETS)
    ccall((:LSdeleteSETS, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nSETS, paiSETS)
end

function LSdeleteSemiContVars(pModel, nSCVars, paiSCVars)
    ccall((:LSdeleteSemiContVars, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nSCVars, paiSCVars)
end

function LSdeleteVariables(pModel, nVars, paiVars)
    ccall((:LSdeleteVariables, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nVars, paiVars)
end

function LSdeleteQCterms(pModel, nCons, paiCons)
    ccall((:LSdeleteQCterms, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nCons, paiCons)
end

function LSdeleteAj(pModel, iVar1, nRows, paiRows)
    ccall((:LSdeleteAj, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}), pModel, iVar1, nRows, paiRows)
end

function LSmodifyLowerBounds(pModel, nVars, paiVars, padL)
    ccall((:LSmodifyLowerBounds, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nVars, paiVars, padL)
end

function LSmodifyUpperBounds(pModel, nVars, paiVars, padU)
    ccall((:LSmodifyUpperBounds, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nVars, paiVars, padU)
end

function LSmodifyRHS(pModel, nCons, paiCons, padB)
    ccall((:LSmodifyRHS, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nCons, paiCons, padB)
end

function LSmodifyObjective(pModel, nVars, paiVars, padC)
    ccall((:LSmodifyObjective, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nVars, paiVars, padC)
end

function LSmodifyObjConstant(pModel, dObjConst)
    ccall((:LSmodifyObjConstant, liblindo), Cint, (pLSmodel, Cdouble), pModel, dObjConst)
end

function LSmodifyAj(pModel, iVar1, nRows, paiRows, padAj)
    ccall((:LSmodifyAj, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, iVar1, nRows, paiRows, padAj)
end

function LSmodifyCone(pModel, cConeType, iConeNum, iConeNnz, paiConeCols, dConeAlpha)
    ccall((:LSmodifyCone, liblindo), Cint, (pLSmodel, UInt8, Cint, Cint, Ptr{Cint}, Cdouble), pModel, cConeType, iConeNum, iConeNnz, paiConeCols, dConeAlpha)
end

function LSmodifySET(pModel, cSETtype, iSETnum, iSETnnz, paiSETcols)
    ccall((:LSmodifySET, liblindo), Cint, (pLSmodel, UInt8, Cint, Cint, Ptr{Cint}), pModel, cSETtype, iSETnum, iSETnnz, paiSETcols)
end

function LSmodifySemiContVars(pModel, nSCVars, paiSCVars, padL, padU)
    ccall((:LSmodifySemiContVars, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nSCVars, paiSCVars, padL, padU)
end

function LSmodifyConstraintType(pModel, nCons, paiCons, pszConTypes)
    ccall((:LSmodifyConstraintType, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cchar}), pModel, nCons, paiCons, pszConTypes)
end

function LSmodifyVariableType(pModel, nVars, paiVars, pszVarTypes)
    ccall((:LSmodifyVariableType, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cchar}), pModel, nVars, paiVars, pszVarTypes)
end

function LSaddNLPAj(pModel, iVar1, nRows, paiRows, padAj)
    ccall((:LSaddNLPAj, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, iVar1, nRows, paiRows, padAj)
end

function LSaddNLPobj(pModel, nCols, paiCols, padColj)
    ccall((:LSaddNLPobj, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, nCols, paiCols, padColj)
end

function LSdeleteNLPobj(pModel, nCols, paiCols)
    ccall((:LSdeleteNLPobj, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nCols, paiCols)
end

function LSgetConstraintRanges(pModel, padDec, padInc)
    ccall((:LSgetConstraintRanges, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, padDec, padInc)
end

function LSgetObjectiveRanges(pModel, padDec, padInc)
    ccall((:LSgetObjectiveRanges, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, padDec, padInc)
end

function LSgetBoundRanges(pModel, padDec, padInc)
    ccall((:LSgetBoundRanges, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, padDec, padInc)
end

function LSgetBestBounds(pModel, padBestL, padBestU)
    ccall((:LSgetBestBounds, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, padBestL, padBestU)
end

function LSfindIIS(pModel, nLevel)
    ccall((:LSfindIIS, liblindo), Cint, (pLSmodel, Cint), pModel, nLevel)
end

function LSfindIUS(pModel, nLevel)
    ccall((:LSfindIUS, liblindo), Cint, (pLSmodel, Cint), pModel, nLevel)
end

function LSfindBlockStructure(pModel, nBlock, nType)
    ccall((:LSfindBlockStructure, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, nBlock, nType)
end

function LSdisplayBlockStructure(pModel, pnBlock, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos)
    ccall((:LSdisplayBlockStructure, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnBlock, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos)
end

function LSgetIIS(pModel, pnSuf_r, pnIIS_r, paiCons, pnSuf_c, pnIIS_c, paiVars, panBnds)
    ccall((:LSgetIIS, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnSuf_r, pnIIS_r, paiCons, pnSuf_c, pnIIS_c, paiVars, panBnds)
end

function LSgetIISInts(pModel, pnSuf_xnt, pnIIS_xnt, paiVars)
    ccall((:LSgetIISInts, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnSuf_xnt, pnIIS_xnt, paiVars)
end

function LSgetIISSETs(pModel, pnSuf_set, pnIIS_set, paiSets)
    ccall((:LSgetIISSETs, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnSuf_set, pnIIS_set, paiSets)
end

function LSgetIUS(pModel, pnSuf, pnIUS, paiVars)
    ccall((:LSgetIUS, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnSuf, pnIUS, paiVars)
end

function LSgetBlockStructure(pModel, pnBlock, panRblock, panCblock, pnType)
    ccall((:LSgetBlockStructure, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnBlock, panRblock, panCblock, pnType)
end

function LSfindSymmetry(pModel, pnerrorcode)
    ccall((:LSfindSymmetry, liblindo), Ptr{Cvoid}, (pLSmodel, Ptr{Cint}), pModel, pnerrorcode)
end

function LSdeleteSymmetry(pSymInfo)
    ccall((:LSdeleteSymmetry, liblindo), Cint, (Ptr{Ptr{Cvoid}},), pSymInfo)
end

function LSgetOrbitInfo(pSymInfo, pnNumGenerators, pnNumOfOrbits, panOrbitBeg, panOrbits)
    ccall((:LSgetOrbitInfo, liblindo), Cint, (Ptr{Cvoid}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pSymInfo, pnNumGenerators, pnNumOfOrbits, panOrbitBeg, panOrbits)
end

function LSdoBTRAN(pModel, pcYnz, paiY, padY, pcXnz, paiX, padX)
    ccall((:LSdoBTRAN, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, pcYnz, paiY, padY, pcXnz, paiX, padX)
end

function LSdoFTRAN(pModel, pcYnz, paiY, padY, pcXnz, paiX, padX)
    ccall((:LSdoFTRAN, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, pcYnz, paiY, padY, pcXnz, paiX, padX)
end

function LScalcObjFunc(pModel, padPrimal, pdObjval)
    ccall((:LScalcObjFunc, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, padPrimal, pdObjval)
end

function LScalcConFunc(pModel, iRow, padPrimal, padSlacks)
    ccall((:LScalcConFunc, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Ptr{Cdouble}), pModel, iRow, padPrimal, padSlacks)
end

function LScalcObjGrad(pModel, padPrimal, nParList, paiParList, padParGrad)
    ccall((:LScalcObjGrad, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, padPrimal, nParList, paiParList, padParGrad)
end

function LScalcConGrad(pModel, irow, padPrimal, nParList, paiParList, padParGrad)
    ccall((:LScalcConGrad, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Cint, Ptr{Cint}, Ptr{Cdouble}), pModel, irow, padPrimal, nParList, paiParList, padParGrad)
end

function LScheckQterms(pModel, nCons, paiCons, paiType)
    ccall((:LScheckQterms, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, nCons, paiCons, paiType)
end

function LSrepairQterms(pModel, nCons, paiCons, paiType)
    ccall((:LSrepairQterms, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, nCons, paiCons, paiType)
end

function LScomputeFunction(inst, pdInput, pdOutput)
    ccall((:LScomputeFunction, liblindo), Cint, (Cint, Ptr{Cdouble}, Ptr{Cdouble}), inst, pdInput, pdOutput)
end

function LSfindLtf(pModel, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos)
    ccall((:LSfindLtf, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos)
end

function LSapplyLtf(pModel, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos, nMode)
    ccall((:LSapplyLtf, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint), pModel, panNewColIdx, panNewRowIdx, panNewColPos, panNewRowPos, nMode)
end

function LSsetCallback(pModel, pfCallback, pvCbData)
    ccall((:LSsetCallback, liblindo), Cint, (pLSmodel, cbFunc_t, Ptr{Cvoid}), pModel, pfCallback, pvCbData)
end
##
function relayMIPCallback(pModel, uData, dObj, padPrimal)
    # get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
    end
    uData._cbMIPFunc(pModel, uData._cbData, dObj, jl_padPrimal)
    return Int32(0)
end

function LSsetMIPCallback(pModel, pfMIPCallback, pvCbData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvCbData
    udata_Dict[pModel]._cbMIPFunc = pfMIPCallback
    relayMIPCallback_c = @cfunction(relayMIPCallback, Cint, (pLSmodel, Ref{jlLindoData_t}, Cdouble, Ptr{Cdouble}))
    ccall((:LSsetMIPCallback, liblindo), Cint, (pLSmodel, cbFunc_t, Ref{jlLindoData_t}), pModel, relayMIPCallback_c, udata_Dict[pModel])
end
##
function LSsetMIPCCStrategy(pModel, pfStrategy, nRunId, szParamFile, pvCbData)
    ccall((:LSsetMIPCCStrategy, liblindo), Cint, (pLSmodel, cbStrategy_t, Cint, Ptr{Cchar}, Ptr{Cvoid}), pModel, pfStrategy, nRunId, szParamFile, pvCbData)
end

function LSsetMIPCallbackInsMIPSol(pModel, pfMIPCallback, pvCbData)
    ccall((:LSsetMIPCallbackInsMIPSol, liblindo), Cint, (pLSmodel, MIP_callback_t, Ptr{Cvoid}), pModel, pfMIPCallback, pvCbData)
end

function LSsetMIPCallbackInsMIPObj(pModel, pfMIPCallback, pvCbData)
    ccall((:LSsetMIPCallbackInsMIPObj, liblindo), Cint, (pLSmodel, MIP_callback_MIPobj_t, Ptr{Cvoid}), pModel, pfMIPCallback, pvCbData)
end

function LSgetCallbackInfo(pModel, nLocation, nQuery, pvValue)
    ccall((:LSgetCallbackInfo, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cvoid}), pModel, nLocation, nQuery, pvValue)
end

function LSgetMIPCallbackInfo(pModel, nQuery, pvValue)
    ccall((:LSgetMIPCallbackInfo, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nQuery, pvValue)
end

function LSgetProgressInfo(pModel, nLocation, nQuery, pvValue)
    ccall((:LSgetProgressInfo, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cvoid}), pModel, nLocation, nQuery, pvValue)
end

##

function relayGradcalc(pModel, uData, nRow, padPrimal, lb, ub, isNewPoint, nNPar, pnParList, pdPartial)
# get number of variales

    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    jl_pnParList = Vector{Cint}(undef, nVar[1])
    jl_lb = Vector{Cdouble}(undef, nVar[1])
    jl_ub = Vector{Cdouble}(undef, nVar[1])
    jl_pdPartial = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
        jl_pnParList[i] = unsafe_load(pnParList,i)
        jl_lb[i] = unsafe_load(lb,i)
        jl_ub[i] = unsafe_load(ub,i)
        jl_pdPartial[i] = unsafe_load(pdPartial,i)
    end
    uData._gradCalcFunc(pModel, uData._cbData, nRow, jl_padPrimal, jl_lb, jl_ub, isNewPoint, nNPar, jl_pnParList, jl_pdPartial)
    # marshall data from julia to C
    unsafe_store!(pdPartial, jl_pdPartial[1])

    return Int32(0)
end

function LSsetGradcalc(pModel, pfGrad_func, pvUserData, nLenUseGrad, pnUseGrad)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvUserData
    udata_Dict[pModel]._gradCalcFunc = pfGrad_func
    relayGradcalc_c = @cfunction(relayGradcalc, Cint, (pLSmodel, Ref{jlLindoData_t}, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Cint, Cint, Ptr{Cint}, Ptr{Cdouble}))
    ccall((:LSsetGradcalc, liblindo), Cint, (pLSmodel, Gradcalc_type, Ref{jlLindoData_t}, Cint, Ptr{Cint}), pModel, relayGradcalc_c, udata_Dict[pModel], nLenUseGrad, pnUseGrad)
end

##

function relayFuncalc(pModel, udata, nRow, padPrimal, nJdiff, dxJBase, funcVal, reserved)
    # get number of variales
    nVar = [0]
    LSgetInfo(pModel, LS_IINFO_NUM_VARS, nVar)
    if nVar[1] == 0
        return 0
    end
    # marshall the C data to julia
    jl_funcval = unsafe_load(funcVal)
    jl_padPrimal = Vector{Cdouble}(undef, nVar[1])
    for i in 1:nVar[1]
        jl_padPrimal[i] = unsafe_load(padPrimal,i)
    end
    jl_funcval =  udata._funCalcFunc(pModel, udata._cbData, nRow, jl_padPrimal, nJdiff, dxJBase, funcVal ,  reserved)
    # marshall the julia data to C
    unsafe_store!(funcVal, jl_funcval)
    return Int32(0)
end

function LSsetFuncalc(pModel, pfFunc, pvFData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvFData
    udata_Dict[pModel]._funCalcFunc = pfFunc
    relayFuncalc_c = @cfunction(relayFuncalc, Cint, (pLSmodel,  Ref{jlLindoData_t} ,Cint, Ptr{Cdouble}, Cint, Cdouble, Ptr{Cdouble}, Ptr{Cvoid}))
    ccall((:LSsetFuncalc, liblindo), Cint, (pLSmodel, Funcalc_type, Ref{jlLindoData_t}), pModel, relayFuncalc_c, udata_Dict[pModel])
end

##
function relayEnvLogfunc(pEnv, line, udata)
    jlLine = unsafe_string(line)
    udata._cbEnvLogFunc(pEnv, jlLine, udata._cbData)
    return Int32(0)
end

function LSsetEnvLogfunc(pEnv, pfLocFunc, pvPrData)
    addToUdata(pEnv)
    udata_Dict[pEnv]._cbData = pvPrData
    udata_Dict[pEnv]._cbEnvLogFunc = pfLocFunc
    relayEnvLogfunc_c = @cfunction(relayEnvLogfunc, Cint, (pLSenv, Ptr{Cchar}, Ref{jlLindoData_t}))
    ccall((:LSsetEnvLogfunc, liblindo), Cint, (pLSenv, printEnvLOG_t, Ref{jlLindoData_t}), pEnv, relayEnvLogfunc_c, udata_Dict[pEnv])
end

##

function relayModelLogfunc(pModel, line, udata)
    jlLine = unsafe_string(line)
    udata._cbModelLogFunc(pModel, jlLine, udata._cbData)
    return Int32(0)
end

function LSsetModelLogfunc(pModel, pfLogFunc, pvPrData)
    addToUdata(pModel)
    udata_Dict[pModel]._cbData = pvPrData
    udata_Dict[pModel]._cbModelLogFunc = pfLogFunc
    relayModelLogfunc_c = @cfunction(relayModelLogfunc, Cint, (pLSmodel, Ptr{Cchar}, Ref{jlLindoData_t}))
    ccall((:LSsetModelLogfunc, liblindo),
     Cint, (pLSmodel, printModelLOG_t, Ref{jlLindoData_t}), pModel, relayModelLogfunc_c, udata_Dict[pModel])
end

##

function LSsetUsercalc(pModel, pfUser_func, pvUserData)
    ccall((:LSsetUsercalc, liblindo), Cint, (pLSmodel, user_callback_t, Ptr{Cvoid}), pModel, pfUser_func, pvUserData)
end

function LSsetEnvExitFunc(pEnv, pfExitFunc, pvUserData)
    ccall((:LSsetEnvExitFunc, liblindo), Cint, (pLSenv, LSfuncExit_t, Ptr{Cvoid}), pEnv, pfExitFunc, pvUserData)
end

function LSsetGOPCallback(pModel, pfGOP_caller, pvPrData)
    ccall((:LSsetGOPCallback, liblindo), Cint, (pLSmodel, GOP_callback_t, Ptr{Cvoid}), pModel, pfGOP_caller, pvPrData)
end

function LSfreeSolverMemory(pModel)
    ccall((:LSfreeSolverMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSfreeHashMemory(pModel)
    ccall((:LSfreeHashMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSfreeSolutionMemory(pModel)
    ccall((:LSfreeSolutionMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSfreeMIPSolutionMemory(pModel)
    ccall((:LSfreeMIPSolutionMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSfreeGOPSolutionMemory(pModel)
    ccall((:LSfreeGOPSolutionMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSsetProbAllocSizes(pModel, n_s_alloc, n_cons_alloc, n_QC_alloc, n_Annz_alloc, n_Qnnz_alloc, n_NLPnnz_alloc)
    ccall((:LSsetProbAllocSizes, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cint, Cint, Cint), pModel, n_s_alloc, n_cons_alloc, n_QC_alloc, n_Annz_alloc, n_Qnnz_alloc, n_NLPnnz_alloc)
end

function LSsetProbNameAllocSizes(pModel, n_name_alloc, n_rowname_alloc)
    ccall((:LSsetProbNameAllocSizes, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, n_name_alloc, n_rowname_alloc)
end

function LSaddEmptySpacesAcolumns(pModel, paiColnnz)
    ccall((:LSaddEmptySpacesAcolumns, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, paiColnnz)
end

function LSaddEmptySpacesNLPAcolumns(pModel, paiColnnz)
    ccall((:LSaddEmptySpacesNLPAcolumns, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, paiColnnz)
end

function LSinstalExternalSolver(pEnv, mVendorId, pvSolverEnv, deleteEnv, createModel, deleteModel, loadLPData, modifyLowerBounds, modifyUpperBounds, modifyRHS, modifyAj, deleteAj, modifyObjective, modifyObjConstant, modifyConstraintType, addConstraints, addVariables, deleteConstraints, deleteVariables, loadBasis, setModelIntParameter, setModelDouParameter, optimize, getInfo, getSolution, doBTRAN, doDenseBTRAN, doFTRAN, doDenseFTRAN, setProbAllocSizes, addEmptySpacesAcolnums, setExitFunc, setCallback, setLOGfunc, solveMIP, loadVarType)
    ccall((:LSinstalExternalSolver, liblindo), Cint, (pLSenv, Cint, Ptr{Cvoid}, LSdeleteEnv_solver_callback_t, LScreateModel_solver_callback_t, LSdeleteModel_solver_callback_t, LSloadLPData_solver_callback_t, LSmodifyLowerBounds_solver_callback_t, LSmodifyUpperBounds_solver_callback_t, LSmodifyRHS_solver_callback_t, LSmodifyAj_solver_callback_t, LSdeleteAj_solver_callback_t, LSmodifyObjective_solver_callback_t, LSmodifyObjConstant_solver_callback_t, LSmodifyConstraintType_solver_callback_t, LSaddConstraints_solver_callback_t, LSaddVariables_solver_callback_t, LSdeleteConstraints_solver_callback_t, LSdeleteVariables_solver_callback_t, LSloadBasis_solver_callback_t, LSsetModelIntParameter_solver_callback_t, LSsetModelDouParameter_solver_callback_t, LSoptimize_solver_callback_t, LSgetInfo_solver_callback_t, LSgetSolution_solver_callback_t, LSdoBTRAN_solver_callback_t, LSdoDenseBTRAN_solver_callback_t, LSdoFTRAN_solver_callback_t, LSdoDenseFTRAN_solver_callback_t, LSsetProbAllocSizes_solver_callback_t, LSaddEmptySpacesAcolumns_solver_callback_t, LSsetEnvExitFunc_solver_callback_t, LSsetCallback_solver_callback_t, LSsetLOGfunc_t, LSsolveMIP_solver_callback_t, LSloadVarType_solver_callback_t), pEnv, mVendorId, pvSolverEnv, deleteEnv, createModel, deleteModel, loadLPData, modifyLowerBounds, modifyUpperBounds, modifyRHS, modifyAj, deleteAj, modifyObjective, modifyObjConstant, modifyConstraintType, addConstraints, addVariables, deleteConstraints, deleteVariables, loadBasis, setModelIntParameter, setModelDouParameter, optimize, getInfo, getSolution, doBTRAN, doDenseBTRAN, doFTRAN, doDenseFTRAN, setProbAllocSizes, addEmptySpacesAcolnums, setExitFunc, setCallback, setLOGfunc, solveMIP, loadVarType)
end

function LSdeleteExternalSolver(pEnv)
    ccall((:LSdeleteExternalSolver, liblindo), Cint, (pLSenv,), pEnv)
end

function LSwriteDeteqMPSFile(pModel, pszFilename, nFormat, iType)
    ccall((:LSwriteDeteqMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint, Cint), pModel, pszFilename, nFormat, iType)
end

function LSwriteDeteqLINDOFile(pModel, pszFilename, iType)
    ccall((:LSwriteDeteqLINDOFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Cint), pModel, pszFilename, iType)
end

function LSwriteSMPSFile(pModel, pszCorefile, pszTimefile, pszStocfile, nCoretype)
    ccall((:LSwriteSMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Cint), pModel, pszCorefile, pszTimefile, pszStocfile, nCoretype)
end

function LSreadSMPSFile(pModel, pszCorefile, pszTimefile, pszStocfile, nCoretype)
    ccall((:LSreadSMPSFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Cint), pModel, pszCorefile, pszTimefile, pszStocfile, nCoretype)
end

function LSwriteSMPIFile(pModel, pszCorefile, pszTimefile, pszStocfile)
    ccall((:LSwriteSMPIFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}), pModel, pszCorefile, pszTimefile, pszStocfile)
end

function LSreadSMPIFile(pModel, pszCorefile, pszTimefile, pszStocfile)
    ccall((:LSreadSMPIFile, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}), pModel, pszCorefile, pszTimefile, pszStocfile)
end

function LSwriteScenarioSolutionFile(pModel, jScenario, pszFname)
    ccall((:LSwriteScenarioSolutionFile, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, jScenario, pszFname)
end

function LSwriteNodeSolutionFile(pModel, jScenario, iStage, pszFname)
    ccall((:LSwriteNodeSolutionFile, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cchar}), pModel, jScenario, iStage, pszFname)
end

function LSwriteScenarioMPIFile(pModel, jScenario, pszFname)
    ccall((:LSwriteScenarioMPIFile, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, jScenario, pszFname)
end

function LSwriteScenarioMPSFile(pModel, jScenario, pszFname, nFormat)
    ccall((:LSwriteScenarioMPSFile, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}, Cint), pModel, jScenario, pszFname, nFormat)
end

function LSwriteScenarioLINDOFile(pModel, jScenario, pszFname)
    ccall((:LSwriteScenarioLINDOFile, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, jScenario, pszFname)
end

function LSsetModelStocDouParameter(pModel, iPar, dVal)
    ccall((:LSsetModelStocDouParameter, liblindo), Cint, (pLSmodel, Cint, Cdouble), pModel, iPar, dVal)
end

function LSgetModelStocDouParameter(pModel, iPar, pdVal)
    ccall((:LSgetModelStocDouParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, iPar, pdVal)
end

function LSsetModelStocIntParameter(pModel, iPar, iVal)
    ccall((:LSsetModelStocIntParameter, liblindo), Cint, (pLSmodel, Cint, Cint), pModel, iPar, iVal)
end

function LSgetModelStocIntParameter(pModel, iPar, piVal)
    ccall((:LSgetModelStocIntParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, iPar, piVal)
end

function LSgetScenarioIndex(pModel, pszName, pnIndex)
    ccall((:LSgetScenarioIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszName, pnIndex)
end

function LSgetStageIndex(pModel, pszName, pnIndex)
    ccall((:LSgetStageIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszName, pnIndex)
end

function LSgetStocParIndex(pModel, pszName, pnIndex)
    ccall((:LSgetStocParIndex, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cint}), pModel, pszName, pnIndex)
end

function LSgetStocParName(pModel, nIndex, pachName)
    ccall((:LSgetStocParName, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, nIndex, pachName)
end

function LSgetScenarioName(pModel, nIndex, pachName)
    ccall((:LSgetScenarioName, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, nIndex, pachName)
end

function LSgetStageName(pModel, nIndex, pachName)
    ccall((:LSgetStageName, liblindo), Cint, (pLSmodel, Cint, Ptr{Cchar}), pModel, nIndex, pachName)
end

function LSgetStocInfo(pModel, nQuery, nParam, pvResult)
    ccall((:LSgetStocInfo, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cvoid}), pModel, nQuery, nParam, pvResult)
end

function LSgetStocCCPInfo(pModel, nQuery, nScenarioIndex, nCPPIndex, pvResult)
    ccall((:LSgetStocCCPInfo, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Ptr{Cvoid}), pModel, nQuery, nScenarioIndex, nCPPIndex, pvResult)
end

function LSloadSampleSizes(pModel, panSampleSize)
    ccall((:LSloadSampleSizes, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panSampleSize)
end

function LSloadConstraintStages(pModel, panStage)
    ccall((:LSloadConstraintStages, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panStage)
end

function LSloadVariableStages(pModel, panStage)
    ccall((:LSloadVariableStages, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panStage)
end

function LSloadStageData(pModel, numStages, panRstage, panCstage)
    ccall((:LSloadStageData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, numStages, panRstage, panCstage)
end

function LSloadStocParData(pModel, panSparStage, padSparValue)
    ccall((:LSloadStocParData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cdouble}), pModel, panSparStage, padSparValue)
end

function LSloadStocParNames(pModel, nSs, paszSVarNames)
    ccall((:LSloadStocParNames, liblindo), Cint, (pLSmodel, Cint, Ptr{Ptr{Cchar}}), pModel, nSs, paszSVarNames)
end

function LSgetDeteqModel(pModel, iDeqType, pnErrorCode)
    ccall((:LSgetDeteqModel, liblindo), pLSmodel, (pLSmodel, Cint, Ptr{Cint}), pModel, iDeqType, pnErrorCode)
end

function LSaggregateStages(pModel, panScheme, nLength)
    ccall((:LSaggregateStages, liblindo), Cint, (pLSmodel, Ptr{Cint}, Cint), pModel, panScheme, nLength)
end

function LSgetStageAggScheme(pModel, panScheme, pnLength)
    ccall((:LSgetStageAggScheme, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}), pModel, panScheme, pnLength)
end

function LSdeduceStages(pModel, nMaxStage, panRowStagse, panColStages, panSparStage)
    ccall((:LSdeduceStages, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, nMaxStage, panRowStagse, panColStages, panSparStage)
end

function LSsolveSP(pModel, pnStatus)
    ccall((:LSsolveSP, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnStatus)
end

function LSsolveHS(pModel, nSearchMethod, pnStatus)
    ccall((:LSsolveHS, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, nSearchMethod, pnStatus)
end

function LSgetScenarioObjective(pModel, jScenario, pObj)
    ccall((:LSgetScenarioObjective, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, jScenario, pObj)
end

function LSgetNodePrimalSolution(pModel, jScenario, iStage, padX)
    ccall((:LSgetNodePrimalSolution, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}), pModel, jScenario, iStage, padX)
end

function LSgetNodeDualSolution(pModel, jScenario, iStage, padY)
    ccall((:LSgetNodeDualSolution, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}), pModel, jScenario, iStage, padY)
end

function LSgetNodeReducedCost(pModel, jScenario, iStage, padX)
    ccall((:LSgetNodeReducedCost, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}), pModel, jScenario, iStage, padX)
end

function LSgetNodeSlacks(pModel, jScenario, iStage, padY)
    ccall((:LSgetNodeSlacks, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}), pModel, jScenario, iStage, padY)
end

function LSgetScenarioPrimalSolution(pModel, jScenario, padX, pObj)
    ccall((:LSgetScenarioPrimalSolution, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Ptr{Cdouble}), pModel, jScenario, padX, pObj)
end

function LSgetScenarioReducedCost(pModel, jScenario, padD)
    ccall((:LSgetScenarioReducedCost, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, jScenario, padD)
end

function LSgetScenarioDualSolution(pModel, jScenario, padY)
    ccall((:LSgetScenarioDualSolution, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, jScenario, padY)
end

function LSgetScenarioSlacks(pModel, jScenario, padS)
    ccall((:LSgetScenarioSlacks, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, jScenario, padS)
end

function LSgetNodeListByScenario(pModel, jScenario, paiNodes, pnNodes)
    ccall((:LSgetNodeListByScenario, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}), pModel, jScenario, paiNodes, pnNodes)
end

function LSgetProbabilityByScenario(pModel, jScenario, pdProb)
    ccall((:LSgetProbabilityByScenario, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, jScenario, pdProb)
end

function LSgetProbabilityByNode(pModel, iNode, pdProb)
    ccall((:LSgetProbabilityByNode, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}), pModel, iNode, pdProb)
end

function LSgetStocParData(pModel, paiStages, padVals)
    ccall((:LSgetStocParData, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cdouble}), pModel, paiStages, padVals)
end

function LSaddDiscreteBlocks(pModel, iStage, nRealzBlock, padProb, pakStart, paiRows, paiCols, paiStvs, padVals, nModifyRule)
    ccall((:LSaddDiscreteBlocks, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Cint), pModel, iStage, nRealzBlock, padProb, pakStart, paiRows, paiCols, paiStvs, padVals, nModifyRule)
end

function LSaddScenario(pModel, jScenario, iParentScen, iStage, dProb, nElems, paiRows, paiCols, paiStvs, padVals, nModifyRule)
    ccall((:LSaddScenario, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cdouble, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Cint), pModel, jScenario, iParentScen, iStage, dProb, nElems, paiRows, paiCols, paiStvs, padVals, nModifyRule)
end

function LSaddDiscreteIndep(pModel, iRow, jCol, iStv, nRealizations, padProbs, padVals, nModifyRule)
    ccall((:LSaddDiscreteIndep, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Cint), pModel, iRow, jCol, iStv, nRealizations, padProbs, padVals, nModifyRule)
end

function LSaddParamDistIndep(pModel, iRow, jCol, iStv, nDistType, nParams, padParams, iModifyRule)
    ccall((:LSaddParamDistIndep, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Cint, Cint, Ptr{Cdouble}, Cint), pModel, iRow, jCol, iStv, nDistType, nParams, padParams, iModifyRule)
end

function LSaddUserDist(pModel, iRow, jCol, iStv, pfUserFunc, nSamples, paSamples, pvUserData, iModifyRule)
    ccall((:LSaddUserDist, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, UserPdf_t, Cint, Ptr{pLSsample}, Ptr{Cvoid}, Cint), pModel, iRow, jCol, iStv, pfUserFunc, nSamples, paSamples, pvUserData, iModifyRule)
end

function LSaddChanceConstraint(pModel, iSense, nCons, paiCons, dPrLevel, dObjWeight)
    ccall((:LSaddChanceConstraint, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}, Cdouble, Cdouble), pModel, iSense, nCons, paiCons, dPrLevel, dObjWeight)
end

function LSsetNumStages(pModel, numStages)
    ccall((:LSsetNumStages, liblindo), Cint, (pLSmodel, Cint), pModel, numStages)
end

function LSgetStocParOutcomes(pModel, jScenario, padVals, padProbs)
    ccall((:LSgetStocParOutcomes, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Ptr{Cdouble}), pModel, jScenario, padVals, padProbs)
end

function LSloadCorrelationMatrix(pModel, nDim, nCorrType, nQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
    ccall((:LSloadCorrelationMatrix, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, nDim, nCorrType, nQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
end

function LSgetCorrelationMatrix(pModel, iFlag, nCorrType, pnQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
    ccall((:LSgetCorrelationMatrix, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iFlag, nCorrType, pnQCnnz, paiQCcols1, paiQCcols2, padQCcoef)
end

function LSgetStocParSample(pModel, iStv, iRow, jCol, pnErrorCode)
    ccall((:LSgetStocParSample, liblindo), pLSsample, (pLSmodel, Cint, Cint, Cint, Ptr{Cint}), pModel, iStv, iRow, jCol, pnErrorCode)
end

function LSgetDiscreteBlocks(pModel, iEvent, nDistType, iStage, nRealzBlock, padProbs, iModifyRule)
    ccall((:LSgetDiscreteBlocks, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}), pModel, iEvent, nDistType, iStage, nRealzBlock, padProbs, iModifyRule)
end

function LSgetDiscreteBlockOutcomes(pModel, iEvent, iRealz, nRealz, paiArows, paiAcols, paiStvs, padVals)
    ccall((:LSgetDiscreteBlockOutcomes, liblindo), Cint, (pLSmodel, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), pModel, iEvent, iRealz, nRealz, paiArows, paiAcols, paiStvs, padVals)
end

function LSgetDiscreteIndep(pModel, iEvent, nDistType, iStage, iRow, jCol, iStv, nRealizations, padProbs, padVals, iModifyRule)
    ccall((:LSgetDiscreteIndep, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}), pModel, iEvent, nDistType, iStage, iRow, jCol, iStv, nRealizations, padProbs, padVals, iModifyRule)
end

function LSgetParamDistIndep(pModel, iEvent, nDistType, iStage, iRow, jCol, iStv, nParams, padParams, iModifyRule)
    ccall((:LSgetParamDistIndep, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}), pModel, iEvent, nDistType, iStage, iRow, jCol, iStv, nParams, padParams, iModifyRule)
end

function LSgetScenario(pModel, jScenario, iParentScen, iBranchStage, pdProb, nRealz, paiArows, paiAcols, paiStvs, padVals, iModifyRule)
    ccall((:LSgetScenario, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}), pModel, jScenario, iParentScen, iBranchStage, pdProb, nRealz, paiArows, paiAcols, paiStvs, padVals, iModifyRule)
end

function LSgetChanceConstraint(pModel, iChance, piSense, pnCons, paiCons, pdProb, pdObjWeight)
    ccall((:LSgetChanceConstraint, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, iChance, piSense, pnCons, paiCons, pdProb, pdObjWeight)
end

function LSgetSampleSizes(pModel, panSampleSize)
    ccall((:LSgetSampleSizes, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panSampleSize)
end

function LSgetConstraintStages(pModel, panStage)
    ccall((:LSgetConstraintStages, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panStage)
end

function LSgetVariableStages(pModel, panStage)
    ccall((:LSgetVariableStages, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, panStage)
end

function LSgetStocRowIndices(pModel, paiSrows)
    ccall((:LSgetStocRowIndices, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, paiSrows)
end

function LSsetStocParRG(pModel, iStv, iRow, jCol, pRG)
    ccall((:LSsetStocParRG, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, pLSrandGen), pModel, iStv, iRow, jCol, pRG)
end

function LSgetScenarioModel(pModel, jScenario, pnErrorcode)
    ccall((:LSgetScenarioModel, liblindo), pLSmodel, (pLSmodel, Cint, Ptr{Cint}), pModel, jScenario, pnErrorcode)
end

function LSfreeStocMemory(pModel)
    ccall((:LSfreeStocMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSfreeStocHashMemory(pModel)
    ccall((:LSfreeStocHashMemory, liblindo), Cvoid, (pLSmodel,), pModel)
end

function LSgetModelStocParameter(pModel, nQuery, pvResult)
    ccall((:LSgetModelStocParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nQuery, pvResult)
end

function LSsetModelStocParameter(pModel, nQuery, pvResult)
    ccall((:LSsetModelStocParameter, liblindo), Cint, (pLSmodel, Cint, Ptr{Cvoid}), pModel, nQuery, pvResult)
end

function LSsetEnvStocParameter(pEnv, nParameter, pvValue)
    ccall((:LSsetEnvStocParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cvoid}), pEnv, nParameter, pvValue)
end

function LSgetEnvStocParameter(pEnv, nParameter, pvValue)
    ccall((:LSgetEnvStocParameter, liblindo), Cint, (pLSenv, Cint, Ptr{Cvoid}), pEnv, nParameter, pvValue)
end

function LSsampCreate(pEnv, nDistType, pnErrorCode)
    ccall((:LSsampCreate, liblindo), pLSsample, (pLSenv, Cint, Ptr{Cint}), pEnv, nDistType, pnErrorCode)
end

function LSsampDelete(pSample)
    ccall((:LSsampDelete, liblindo), Cint, (Ptr{pLSsample},), pSample)
end

function LSsampSetUserDistr(pSample, pfUserFunc, pvUserData)
    ccall((:LSsampSetUserDistr, liblindo), Cint, (pLSsample, UserPdf_t, Ptr{Cvoid}), pSample, pfUserFunc, pvUserData)
end

function LSsampSetDistrParam(pSample, nIndex, dValue)
    ccall((:LSsampSetDistrParam, liblindo), Cint, (pLSsample, Cint, Cdouble), pSample, nIndex, dValue)
end

function LSsampGetDistrParam(pSample, nIndex, pdValue)
    ccall((:LSsampGetDistrParam, liblindo), Cint, (pLSsample, Cint, Ptr{Cdouble}), pSample, nIndex, pdValue)
end

function LSsampEvalDistr(pSample, nFuncType, dXval, pdResult)
    ccall((:LSsampEvalDistr, liblindo), Cint, (pLSsample, Cint, Cdouble, Ptr{Cdouble}), pSample, nFuncType, dXval, pdResult)
end

function LSsampEvalDistrLI(pSample, nFuncType, dXval, pdResult)
    ccall((:LSsampEvalDistrLI, liblindo), Cint, (pLSsample, Cint, Cdouble, Ptr{Cdouble}), pSample, nFuncType, dXval, pdResult)
end

function LSsampEvalUserDistr(pSample, nFuncType, padXval, nDim, pdResult)
    ccall((:LSsampEvalUserDistr, liblindo), Cint, (pLSsample, Cint, Ptr{Cdouble}, Cint, Ptr{Cdouble}), pSample, nFuncType, padXval, nDim, pdResult)
end

function LSsampSetRG(pSample, pRG)
    ccall((:LSsampSetRG, liblindo), Cint, (pLSsample, Ptr{Cvoid}), pSample, pRG)
end

function LSsampGenerate(pSample, nMethod, nSize)
    ccall((:LSsampGenerate, liblindo), Cint, (pLSsample, Cint, Cint), pSample, nMethod, nSize)
end

function LSsampGetPointsPtr(pSample, pnSampSize, pdXval)
    ccall((:LSsampGetPointsPtr, liblindo), Cint, (pLSsample, Ptr{Cint}, Ptr{Ptr{Cdouble}}), pSample, pnSampSize, pdXval)
end

function LSsampGetPoints(pSample, pnSampSize, pdXval)
    ccall((:LSsampGetPoints, liblindo), Cint, (pLSsample, Ptr{Cint}, Ptr{Cdouble}), pSample, pnSampSize, pdXval)
end

function LSsampLoadPoints(pSample, nSampSize, pdXval)
    ccall((:LSsampLoadPoints, liblindo), Cint, (pLSsample, Cint, Ptr{Cdouble}), pSample, nSampSize, pdXval)
end

function LSsampGetCIPointsPtr(pSample, pnSampSize, pdXval)
    ccall((:LSsampGetCIPointsPtr, liblindo), Cint, (pLSsample, Ptr{Cint}, Ptr{Ptr{Cdouble}}), pSample, pnSampSize, pdXval)
end

function LSsampGetCIPoints(pSample, pnSampSize, pdXval)
    ccall((:LSsampGetCIPoints, liblindo), Cint, (pLSsample, Ptr{Cint}, Ptr{Cdouble}), pSample, pnSampSize, pdXval)
end

function LSsampInduceCorrelation(paSample, nDim, nCorrType, nQCnonzeros, paiQCndx1, paiQCndx2, padQCcoef)
    ccall((:LSsampInduceCorrelation, liblindo), Cint, (Ptr{pLSsample}, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), paSample, nDim, nCorrType, nQCnonzeros, paiQCndx1, paiQCndx2, padQCcoef)
end

function LSsampGetCorrelationMatrix(paSample, nDim, iFlag, nCorrType, nQCnonzeros, paiQCndx1, paiQCndx2, padQCcoef)
    ccall((:LSsampGetCorrelationMatrix, liblindo), Cint, (Ptr{pLSsample}, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}), paSample, nDim, iFlag, nCorrType, nQCnonzeros, paiQCndx1, paiQCndx2, padQCcoef)
end

function LSsampLoadDiscretePdfTable(pSample, nLen, padProb, padVals)
    ccall((:LSsampLoadDiscretePdfTable, liblindo), Cint, (pLSsample, Cint, Ptr{Cdouble}, Ptr{Cdouble}), pSample, nLen, padProb, padVals)
end

function LSsampGetDiscretePdfTable(pSample, pnLen, padProb, padVals)
    ccall((:LSsampGetDiscretePdfTable, liblindo), Cint, (pLSsample, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}), pSample, pnLen, padProb, padVals)
end

function LSsampGetInfo(pSample, nQuery, pvResult)
    ccall((:LSsampGetInfo, liblindo), Cint, (pLSsample, Cint, Ptr{Cvoid}), pSample, nQuery, pvResult)
end

function LSsampAddUserFuncArg(pSample, pSampleSource)
    ccall((:LSsampAddUserFuncArg, liblindo), Cint, (pLSsample, pLSsample), pSample, pSampleSource)
end

function LSregress(nNdim, nPdim, padU, padX, padB, pdB0, padR, padstats)
    ccall((:LSregress, liblindo), Cint, (Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), nNdim, nPdim, padU, padX, padB, pdB0, padR, padstats)
end

function LScreateRG(pEnv, nMethod)
    ccall((:LScreateRG, liblindo), pLSrandGen, (pLSenv, Cint), pEnv, nMethod)
end

function LScreateRGMT(pEnv, nMethod)
    ccall((:LScreateRGMT, liblindo), pLSrandGen, (pLSenv, Cint), pEnv, nMethod)
end

function LSgetDoubleRV(pRG)
    ccall((:LSgetDoubleRV, liblindo), Cdouble, (pLSrandGen,), pRG)
end

function LSgetInt32RV(pRG, iLow, iHigh)
    ccall((:LSgetInt32RV, liblindo), Cint, (pLSrandGen, Cint, Cint), pRG, iLow, iHigh)
end

function LSsetRGSeed(pRG, nSeed)
    ccall((:LSsetRGSeed, liblindo), Cvoid, (pLSrandGen, Cint), pRG, nSeed)
end

function LSdisposeRG(ppRG)
    ccall((:LSdisposeRG, liblindo), Cvoid, (Ptr{pLSrandGen},), ppRG)
end

function LSsetDistrParamRG(pRG, iParam, dParam)
    ccall((:LSsetDistrParamRG, liblindo), Cint, (pLSrandGen, Cint, Cdouble), pRG, iParam, dParam)
end

function LSsetDistrRG(pRG, nDistType)
    ccall((:LSsetDistrRG, liblindo), Cint, (pLSrandGen, Cint), pRG, nDistType)
end

function LSgetDistrRV(pRG, pvResult)
    ccall((:LSgetDistrRV, liblindo), Cint, (pLSrandGen, Ptr{Cvoid}), pRG, pvResult)
end

function LSgetInitSeed(pRG)
    ccall((:LSgetInitSeed, liblindo), Cint, (pLSrandGen,), pRG)
end

function LSgetRGNumThreads(pRG, pnThreads)
    ccall((:LSgetRGNumThreads, liblindo), Cint, (pLSrandGen, Ptr{Cint}), pRG, pnThreads)
end

function LSfillRGBuffer(pRG)
    ccall((:LSfillRGBuffer, liblindo), Cint, (pLSrandGen,), pRG)
end

function LSgetRGBufferPtr(pRG, pnBufferLen)
    ccall((:LSgetRGBufferPtr, liblindo), Ptr{Cdouble}, (pLSrandGen, Ptr{Cint}), pRG, pnBufferLen)
end

function LSgetJavaHandle(pvOwner, iCastType, iObject, pvjObject)
    ccall((:LSgetJavaHandle, liblindo), Cint, (Ptr{Cvoid}, Cint, Cint, Ptr{Cvoid}), pvOwner, iCastType, iObject, pvjObject)
end

function LSsetJavaHandle(pvOwner, iCastType, iObject, pvjObject)
    ccall((:LSsetJavaHandle, liblindo), Cint, (Ptr{Cvoid}, Cint, Cint, Ptr{Cvoid}), pvOwner, iCastType, iObject, pvjObject)
end

function LSgetObjHandle(pvOwner, iCastType, iObject)
    ccall((:LSgetObjHandle, liblindo), Ptr{Cvoid}, (Ptr{Cvoid}, Cint, Cint), pvOwner, iCastType, iObject)
end

function LSgetHistogram(pModel, nSampSize, padVals, padWeights, dHistLow, dHistHigh, pnBins, panBinCounts, padBinProbs, padBinLow, padBinHigh, padBinLeftEdge, padBinRightEdge)
    ccall((:LSgetHistogram, liblindo), Cint, (pLSmodel, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Cdouble, Cdouble, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, nSampSize, padVals, padWeights, dHistLow, dHistHigh, pnBins, panBinCounts, padBinProbs, padBinLow, padBinHigh, padBinLeftEdge, padBinRightEdge)
end

function LSsampGetCorrDiff(pModel, paSample, nDim, nDiffType, pdNorm1, pdNorm2, pdVecNormInf)
    ccall((:LSsampGetCorrDiff, liblindo), Cint, (pLSmodel, Ptr{pLSsample}, Cint, Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, paSample, nDim, nDiffType, pdNorm1, pdNorm2, pdVecNormInf)
end

function LSgetNnzData(pModel, mStat, panOutput)
    ccall((:LSgetNnzData, liblindo), Cint, (pLSmodel, Cint, Ptr{Cint}), pModel, mStat, panOutput)
end

function LSsolveFileLP(pModel, szFileNameMPS, szFileNameSol, nNoOfColsEvaluatedPerSet, nNoOfColsSelectedPerSet, nTimeLimitSec, pnSolStatusParam, pnNoOfConsMps, pnNoOfColsMps, pnErrorLine)
    ccall((:LSsolveFileLP, liblindo), Cint, (pLSmodel, Ptr{Cchar}, Ptr{Cchar}, Cint, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Clonglong}, Ptr{Clonglong}), pModel, szFileNameMPS, szFileNameSol, nNoOfColsEvaluatedPerSet, nNoOfColsSelectedPerSet, nTimeLimitSec, pnSolStatusParam, pnNoOfConsMps, pnNoOfColsMps, pnErrorLine)
end

function LSreadSolutionFileLP(szFileNameSol, nFileFormat, nBeginIndexPrimalSol, nEndIndexPrimalSol, pnSolStatus, pdObjValue, pnNoOfCons, plNoOfCols, pnNoOfColsEvaluated, pnNoOfIterations, pdTimeTakenInSeconds, padPrimalValues, padDualValues)
    ccall((:LSreadSolutionFileLP, liblindo), Cint, (Ptr{Cchar}, Cint, Clonglong, Clonglong, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Clonglong}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), szFileNameSol, nFileFormat, nBeginIndexPrimalSol, nEndIndexPrimalSol, pnSolStatus, pdObjValue, pnNoOfCons, plNoOfCols, pnNoOfColsEvaluated, pnNoOfIterations, pdTimeTakenInSeconds, padPrimalValues, padDualValues)
end

function LSdateDiffSecs(nYr1, nMon1, nDay1, nHr1, nMin1, dSec1, nYr2, nMon2, nDay2, nHr2, nMin2, dSec2, pdSecdiff)
    ccall((:LSdateDiffSecs, liblindo), Cint, (Cint, Cint, Cint, Cint, Cint, Cdouble, Cint, Cint, Cint, Cint, Cint, Cdouble, Ptr{Cdouble}), nYr1, nMon1, nDay1, nHr1, nMin1, dSec1, nYr2, nMon2, nDay2, nHr2, nMin2, dSec2, pdSecdiff)
end

function LSdateYmdhms(dSecdiff, nYr1, nMon1, nDay1, nHr1, nMin1, dSec1, pnYr2, pnMon2, pnDay2, pnHr2, pnMin2, pdSec2, pnDow)
    ccall((:LSdateYmdhms, liblindo), Cint, (Cdouble, Cint, Cint, Cint, Cint, Cint, Cdouble, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}), dSecdiff, nYr1, nMon1, nDay1, nHr1, nMin1, dSec1, pnYr2, pnMon2, pnDay2, pnHr2, pnMin2, pdSec2, pnDow)
end

function LSdateToday(pnYr1, pnMon1, pnDay1, pnHr1, pnMin1, pdSec1, pnDow)
    ccall((:LSdateToday, liblindo), Cint, (Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cint}), pnYr1, pnMon1, pnDay1, pnHr1, pnMin1, pdSec1, pnDow)
end

function LSdateMakeDate(nYYYY, nMM, nDD)
    ccall((:LSdateMakeDate, liblindo), Cint, (Cint, Cint, Cint), nYYYY, nMM, nDD)
end

function LSdateMakeTime(nHH, nMM, dSS)
    ccall((:LSdateMakeTime, liblindo), Cdouble, (Cint, Cint, Cdouble), nHH, nMM, dSS)
end

function LSdateSetBaseDate(nYYYY, nMM, nDD)
    ccall((:LSdateSetBaseDate, liblindo), Cvoid, (Cint, Cint, Cint), nYYYY, nMM, nDD)
end

function LSdateScalarSec(nDate, dTime)
    ccall((:LSdateScalarSec, liblindo), Cdouble, (Cint, Cdouble), nDate, dTime)
end

function LSdateScalarSecInverse(dSSEC, pnDate, pdTime)
    ccall((:LSdateScalarSecInverse, liblindo), Cvoid, (Cdouble, Ptr{Cint}, Ptr{Cdouble}), dSSEC, pnDate, pdTime)
end

function LSdateScalarHour(nDate, dTime)
    ccall((:LSdateScalarHour, liblindo), Cdouble, (Cint, Cdouble), nDate, dTime)
end

function LSdateScalarHourInverse(dSHOUR, pnDate, pdTime)
    ccall((:LSdateScalarHourInverse, liblindo), Cvoid, (Cdouble, Ptr{Cint}, Ptr{Cdouble}), dSHOUR, pnDate, pdTime)
end

function LSdateJulianSec(nDate, dTime)
    ccall((:LSdateJulianSec, liblindo), Cdouble, (Cint, Cdouble), nDate, dTime)
end

function LSdateJulianSecInverse(dJSEC, pnDate, pdTime)
    ccall((:LSdateJulianSecInverse, liblindo), Cvoid, (Cdouble, Ptr{Cint}, Ptr{Cdouble}), dJSEC, pnDate, pdTime)
end

function LSdateJulianHour(nDate, dTime)
    ccall((:LSdateJulianHour, liblindo), Cdouble, (Cint, Cdouble), nDate, dTime)
end

function LSdateJulianHourInverse(dJHOUR, pnDate, pdTime)
    ccall((:LSdateJulianHourInverse, liblindo), Cvoid, (Cdouble, Ptr{Cint}, Ptr{Cdouble}), dJHOUR, pnDate, pdTime)
end

function LSdateDiff(nDate1, dTime1, nDate2, dTime2, pnDays, pdSecs)
    ccall((:LSdateDiff, liblindo), Cvoid, (Cint, Cdouble, Cint, Cdouble, Ptr{Cint}, Ptr{Cdouble}), nDate1, dTime1, nDate2, dTime2, pnDays, pdSecs)
end

function LSdateNow(pnDate, pdTime)
    ccall((:LSdateNow, liblindo), Cvoid, (Ptr{Cint}, Ptr{Cdouble}), pnDate, pdTime)
end

function LSdateIsLeapYear(nYear)
    ccall((:LSdateIsLeapYear, liblindo), Cint, (Cint,), nYear)
end

function LSdateJulianDay(nDate)
    ccall((:LSdateJulianDay, liblindo), Cint, (Cint,), nDate)
end

function LSdateDayOfWeek(nDate)
    ccall((:LSdateDayOfWeek, liblindo), Cint, (Cint,), nDate)
end

function LSdateWeekOfYear(nDate)
    ccall((:LSdateWeekOfYear, liblindo), Cint, (Cint,), nDate)
end

function LSdateQuarterOfYear(nDate)
    ccall((:LSdateQuarterOfYear, liblindo), Cint, (Cint,), nDate)
end

function LSdateDayOfYear(nDate)
    ccall((:LSdateDayOfYear, liblindo), Cint, (Cint,), nDate)
end

function LSdateNextWeekDay(nDate)
    ccall((:LSdateNextWeekDay, liblindo), Cint, (Cint,), nDate)
end

function LSdatePrevWeekDay(nDate)
    ccall((:LSdatePrevWeekDay, liblindo), Cint, (Cint,), nDate)
end

function LSdateNextMonth(nDate)
    ccall((:LSdateNextMonth, liblindo), Cint, (Cint,), nDate)
end

function LSdateDateToDays(nDate)
    ccall((:LSdateDateToDays, liblindo), Cint, (Cint,), nDate)
end

function LSdateDaysToDate(nDays)
    ccall((:LSdateDaysToDate, liblindo), Cint, (Cint,), nDays)
end

function LSdateTimeToSecs(dTime)
    ccall((:LSdateTimeToSecs, liblindo), Cdouble, (Cdouble,), dTime)
end

function LSdateSecsToTime(dSecs)
    ccall((:LSdateSecsToTime, liblindo), Cdouble, (Cdouble,), dSecs)
end

function LSdateFutureDate(pnDate, pdTime, nDays, dSecs)
    ccall((:LSdateFutureDate, liblindo), Cvoid, (Ptr{Cint}, Ptr{Cdouble}, Cint, Cint), pnDate, pdTime, nDays, dSecs)
end

function LSdatePastDate(pnDate, pdTime, nDays, dSecs)
    ccall((:LSdatePastDate, liblindo), Cvoid, (Ptr{Cint}, Ptr{Cdouble}, Cint, Cdouble), pnDate, pdTime, nDays, dSecs)
end

function LSdateIsValidDate(nDate)
    ccall((:LSdateIsValidDate, liblindo), Cint, (Cint,), nDate)
end

function LSdateIsValidTime(dTime)
    ccall((:LSdateIsValidTime, liblindo), Cint, (Cdouble,), dTime)
end

function LSdateIsDateFuture(nDate, dTime)
    ccall((:LSdateIsDateFuture, liblindo), Cint, (Cint, Cdouble), nDate, dTime)
end

function LSdateIsDatePast(nDate, dTime)
    ccall((:LSdateIsDatePast, liblindo), Cint, (Cint, Cdouble), nDate, dTime)
end

function LSdateYear(nDate)
    ccall((:LSdateYear, liblindo), Cint, (Cint,), nDate)
end

function LSdateMonth(nDate)
    ccall((:LSdateMonth, liblindo), Cint, (Cint,), nDate)
end

function LSdateDay(nDate)
    ccall((:LSdateDay, liblindo), Cint, (Cint,), nDate)
end

function LSdateHour(dTime)
    ccall((:LSdateHour, liblindo), Cint, (Cdouble,), dTime)
end

function LSdateMinute(dTime)
    ccall((:LSdateMinute, liblindo), Cint, (Cdouble,), dTime)
end

function LSdateSecond(dTime)
    ccall((:LSdateSecond, liblindo), Cdouble, (Cdouble,), dTime)
end

function LSdateWeekOfMonth(nDate)
    ccall((:LSdateWeekOfMonth, liblindo), Cint, (Cint,), nDate)
end

function LSdateLocalTimeStamp(szTimeBuffer)
    ccall((:LSdateLocalTimeStamp, liblindo), Ptr{Cchar}, (Ptr{Cchar},), szTimeBuffer)
end

function LSdateDateNum(nDate)
    ccall((:LSdateDateNum, liblindo), Cint, (Cint,), nDate)
end

function LSdateMakeDateNum(nYYYY, nMM, nDD)
    ccall((:LSdateMakeDateNum, liblindo), Cint, (Cint, Cint, Cint), nYYYY, nMM, nDD)
end

function LSrunTuner(pEnv)
    ccall((:LSrunTuner, liblindo), Cint, (pLSenv,), pEnv)
end

function LSrunTunerFile(pEnv, szJsonFile)
    ccall((:LSrunTunerFile, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, szJsonFile)
end

function LSrunTunerString(pEnv, szJsonString)
    ccall((:LSrunTunerString, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, szJsonString)
end

function LSloadTunerConfigString(pEnv, szJsonString)
    ccall((:LSloadTunerConfigString, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, szJsonString)
end

function LSloadTunerConfigFile(pEnv, szJsonFile)
    ccall((:LSloadTunerConfigFile, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, szJsonFile)
end

function LSclearTuner(pEnv)
    ccall((:LSclearTuner, liblindo), Cint, (pLSenv,), pEnv)
end

function LSresetTuner(pEnv)
    ccall((:LSresetTuner, liblindo), Cint, (pLSenv,), pEnv)
end

function LSprintTuner(pEnv)
    ccall((:LSprintTuner, liblindo), Cint, (pLSenv,), pEnv)
end

function LSsetTunerOption(pEnv, szKey, dval)
    ccall((:LSsetTunerOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Cdouble), pEnv, szKey, dval)
end

function LSgetTunerOption(pEnv, szkey, pdval)
    ccall((:LSgetTunerOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cdouble}), pEnv, szkey, pdval)
end

function LSsetTunerStrOption(pEnv, szKey, szval)
    ccall((:LSsetTunerStrOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cchar}), pEnv, szKey, szval)
end

function LSgetTunerStrOption(pEnv, szkey, szval)
    ccall((:LSgetTunerStrOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cchar}), pEnv, szkey, szval)
end

function LSgetTunerResult(pEnv, szkey, jInstance, kConfig, pdval)
    ccall((:LSgetTunerResult, liblindo), Cint, (pLSenv, Ptr{Cchar}, Cint, Cint, Ptr{Cdouble}), pEnv, szkey, jInstance, kConfig, pdval)
end

function LSgetTunerSpace(pEnv, panParamId, numParam)
    ccall((:LSgetTunerSpace, liblindo), Cint, (pLSenv, Ptr{Cint}, Ptr{Cint}), pEnv, panParamId, numParam)
end

function LSwriteTunerConfigString(pEnv, szJsonString, szJsonFile)
    ccall((:LSwriteTunerConfigString, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cchar}), pEnv, szJsonString, szJsonFile)
end

function LSgetTunerConfigString(pEnv, pszJsonString)
    ccall((:LSgetTunerConfigString, liblindo), Cint, (pLSenv, Ptr{Ptr{Cchar}}), pEnv, pszJsonString)
end

function LSwriteTunerParameters(pEnv, szFile, jInstance, mCriterion)
    ccall((:LSwriteTunerParameters, liblindo), Cint, (pLSenv, Ptr{Cchar}, Cint, Cint), pEnv, szFile, jInstance, mCriterion)
end

function LSaddTunerInstance(pEnv, szFile)
    ccall((:LSaddTunerInstance, liblindo), Cint, (pLSenv, Ptr{Cchar}), pEnv, szFile)
end

function LSaddTunerModelInstance(pEnv, szKey, pModel)
    ccall((:LSaddTunerModelInstance, liblindo), Cint, (pLSenv, Ptr{Cchar}, pLSmodel), pEnv, szKey, pModel)
end

function LSaddTunerZStatic(pEnv, jGroupId, iParam, dValue)
    ccall((:LSaddTunerZStatic, liblindo), Cint, (pLSenv, Cint, Cint, Cdouble), pEnv, jGroupId, iParam, dValue)
end

function LSaddTunerZDynamic(pEnv, iParam)
    ccall((:LSaddTunerZDynamic, liblindo), Cint, (pLSenv, Cint), pEnv, iParam)
end

function LSaddTunerOption(pEnv, szKey, dValue)
    ccall((:LSaddTunerOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Cdouble), pEnv, szKey, dValue)
end

function LSaddTunerStrOption(pEnv, szKey, szValue)
    ccall((:LSaddTunerStrOption, liblindo), Cint, (pLSenv, Ptr{Cchar}, Ptr{Cchar}), pEnv, szKey, szValue)
end

function LSdisplayTunerResults(pEnv)
    ccall((:LSdisplayTunerResults, liblindo), Cint, (pLSenv,), pEnv)
end

function LSgetLicenseInfo(pModel, pnMaxcons, pnMaxs, pnMaxints, pnReserved1, pnDaystoexp, pnDaystotrialexp, pnNlpAllowed, pnUsers, pnBarAllowed, pnRuntime, pnEdulicense, pachText)
    ccall((:LSgetLicenseInfo, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cchar}), pModel, pnMaxcons, pnMaxs, pnMaxints, pnReserved1, pnDaystoexp, pnDaystotrialexp, pnNlpAllowed, pnUsers, pnBarAllowed, pnRuntime, pnEdulicense, pachText)
end

function LSgetDimensions(pModel, pnVars, pnCons, pnCones, pnAnnz, pnQCnnz, pnConennz, pnNLPnnz, pnNLPobjnnz, pnVarNamelen, pnConNamelen, pnConeNamelen)
    ccall((:LSgetDimensions, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnVars, pnCons, pnCones, pnAnnz, pnQCnnz, pnConennz, pnNLPnnz, pnNLPobjnnz, pnVarNamelen, pnConNamelen, pnConeNamelen)
end

function LSbnbSolve(pModel, pszFname)
    ccall((:LSbnbSolve, liblindo), Cint, (pLSmodel, Ptr{Cchar}), pModel, pszFname)
end

function LSgetDualMIPsolution(pModel, padPrimal, padDual, padRedcosts, panCstatus, panRstatus)
    ccall((:LSgetDualMIPsolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}), pModel, padPrimal, padDual, padRedcosts, panCstatus, panRstatus)
end

function LSgetMIPSolutionStatus(pModel, pnStatus)
    ccall((:LSgetMIPSolutionStatus, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, pnStatus)
end

function LSgetSolutionStatus(pModel, nStatus)
    ccall((:LSgetSolutionStatus, liblindo), Cint, (pLSmodel, Ptr{Cint}), pModel, nStatus)
end

function LSgetObjective(pModel, pdObjval)
    ccall((:LSgetObjective, liblindo), Cint, (pLSmodel, Ptr{Cdouble}), pModel, pdObjval)
end

function LSgetSolutionInfo(pModel, pnMethod, pnElapsed, pnSpxiter, pnBariter, pnNlpiter, pnPrimStatus, pnDualStatus, pnBasStatus, pdPobjval, pdDobjval, pdPinfeas, pdDinfeas)
    ccall((:LSgetSolutionInfo, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pnMethod, pnElapsed, pnSpxiter, pnBariter, pnNlpiter, pnPrimStatus, pnDualStatus, pnBasStatus, pdPobjval, pdDobjval, pdPinfeas, pdDinfeas)
end

function LSgetMIPSolution(pModel, pdPobjval, padPrimal)
    ccall((:LSgetMIPSolution, liblindo), Cint, (pLSmodel, Ptr{Cdouble}, Ptr{Cdouble}), pModel, pdPobjval, padPrimal)
end

function LSgetCurrentMIPSolutionInfo(pModel, pnMIPstatus, pdMIPobjval, pdBestbound, pdSpxiter, pdBariter, pdNlpiter, pnLPcnt, pnBranchcnt, pnActivecnt, pnCons_prep, pnVars_prep, pnAnnz_prep, pnInt_prep, pnCut_contra, pnCut_obj, pnCut_gub, pnCut_lift, pnCut_flow, pnCut_gomory, pnCut_gcd, pnCut_clique, pnCut_disagg, pnCut_planloc, pnCut_latice, pnCut_coef)
    ccall((:LSgetCurrentMIPSolutionInfo, liblindo), Cint, (pLSmodel, Ptr{Cint}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), pModel, pnMIPstatus, pdMIPobjval, pdBestbound, pdSpxiter, pdBariter, pdNlpiter, pnLPcnt, pnBranchcnt, pnActivecnt, pnCons_prep, pnVars_prep, pnAnnz_prep, pnInt_prep, pnCut_contra, pnCut_obj, pnCut_gub, pnCut_lift, pnCut_flow, pnCut_gomory, pnCut_gcd, pnCut_clique, pnCut_disagg, pnCut_planloc, pnCut_latice, pnCut_coef)
end

function LSgetCLOpt(pEnv, nArgc, pszArgv, pszOpt)
    ccall((:LSgetCLOpt, liblindo), Cint, (pLSenv, Cint, Ptr{Ptr{Cchar}}, Ptr{Cchar}), pEnv, nArgc, pszArgv, pszOpt)
end

function LSgetCLOptArg(pEnv, pszOptArg)
    ccall((:LSgetCLOptArg, liblindo), Cint, (pLSenv, Ptr{Ptr{Cchar}}), pEnv, pszOptArg)
end

function LSgetCLOptInd(pEnv, pnOptInd)
    ccall((:LSgetCLOptInd, liblindo), Cint, (pLSenv, Ptr{Cint}), pEnv, pnOptInd)
end

function LSsolveExternally(pModel, mSolver, nMethod, nFileFormat, pnStatus)
    ccall((:LSsolveExternally, liblindo), Cint, (pLSmodel, Cint, Cint, Cint, Ptr{Cint}), pModel, mSolver, nMethod, nFileFormat, pnStatus)
end

function LSgetMasterModel(pModel)
    ccall((:LSgetMasterModel, liblindo), pLSmodel, (pLSmodel,), pModel)
end
