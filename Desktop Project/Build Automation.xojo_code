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
					FolderItem = Li4vLi4vUmVzb3VyY2VzL2pzb25fdGVzdF9zdHJlYW1fbGV2ZWwtMS56c3Q=
				End
				Begin CopyFilesBuildStep MacIntelLibs
					AppliesTo = 0
					Architecture = 1
					Destination = 0
					Subdirectory = Intel
					FolderItem = Li4vLi4vUmVzb3VyY2VzL01hYy9JbnRlbC9saWJ6c3RkLmR5bGli
				End
				Begin CopyFilesBuildStep MacArmLibs
					AppliesTo = 0
					Architecture = 2
					Destination = 0
					Subdirectory = ARM
					FolderItem = Li4vLi4vUmVzb3VyY2VzL01hYy9BUk0vbGlienN0ZC5keWxpYg==
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
					FolderItem = Li4vLi4vUmVzb3VyY2VzL2pzb25fdGVzdC50eHQuenN0
					FolderItem = Li4vLi4vUmVzb3VyY2VzL2pzb25fdGVzdF9zdHJlYW1fbGV2ZWwtMS56c3Q=
				End
				Begin CopyFilesBuildStep WinLibs
					AppliesTo = 0
					Architecture = 0
					Destination = 0
					Subdirectory = 
					FolderItem = Li4vLi4vUmVzb3VyY2VzL1dpbmRvd3MvNjQtYml0L2xpYnpzdGQuZGxs
					FolderItem = Li4vLi4vUmVzb3VyY2VzL1dpbmRvd3MvNjQtYml0L2xpYnpzdGQuZGxsLmE=
					FolderItem = Li4vLi4vUmVzb3VyY2VzL1dpbmRvd3MvNjQtYml0L3psaWIxLmRsbA==
				End
			End
#tag EndBuildAutomation
