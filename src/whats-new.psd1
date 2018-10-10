@{
	ModuleVersion = '3.0.0'
	GUID = '861e5d28-8348-47d3-a2f6-cdd23e33bb55'
	Author = 'Nick Spreitzer'
	CompanyName = 'Nick Spreitzer'
	Copyright = '(c) 2018 Nick Spreitzer. All rights reserved.'
	NestedModules = @('.\modules\GitVersioning.psm1', 
	               '.\modules\OpenSolution.psm1', 
	               '.\modules\RemoveLocalBranches.psm1')
	FunctionsToExport = '*'
	CmdletsToExport = '*'
	VariablesToExport = '*'
	AliasesToExport = '*'
	PrivateData = @{
	    PSData = @{
	    } 
	} 
}
