#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep MacResources
					AppliesTo = 0
					Architecture = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vUmVzb3VyY2VzL2pzb25fdGVzdC50eHQuenN0
				End
				Begin CopyFilesBuildStep MacLibs
					AppliesTo = 0
					Architecture = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vUmVzb3VyY2VzL01hYy9saWJ6c3RkLmR5bGli
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin CopyFilesBuildStep WinResources
					AppliesTo = 0
					Architecture = 0
					Destination = 1
					Subdirectory = 
					FolderItem = Li4vLi4vUmVzb3VyY2VzL2pzb25fdGVzdC50eHQ=
				End
			End
#tag EndBuildAutomation
