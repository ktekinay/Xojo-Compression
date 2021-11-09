#tag Class
Private Class ZstdBase
	#tag Method, Flags = &h1
		Protected Sub Constructor(compressionLevel As Integer = kLevelDefault)
		  if compressionLevel = kLevelDefault then
		    compressionLevel = LevelDefault
		  end if
		  
		  CompressContext = new CCTX
		  var code as integer = CompressContext.SetParameter( CCTX.kParamCompressionLevel, compressionLevel )
		  
		  if code <> 0 then // It was clamped
		    self.CompressionLevel = code
		  else
		    self.CompressionLevel = compressionLevel
		  end if
		  
		  DecompressContext = new DCTX
		  
		  Cores = DefaultCores
		  
		  RaiseEvent DoConstruction
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(zstdDictionary As ZstdDictionary_MTC)
		  Constructor kLevelDefault
		  
		  //
		  // If dict is nil then we
		  // want the NilObjectException
		  //
		  
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var code as UInteger
		  
		  var cdict as ptr
		  var ddict as ptr
		  
		  var idict as ZstdDictionaryInterface = zstdDictionary
		  cdict = idict.GetCDict
		  ddict = idict.GetDDict
		  
		  declare function ZSTD_CCtx_refCDict lib kLibZstd ( cctx as Ptr, cdict as ptr ) as UInteger
		  
		  code = ZSTD_CCtx_refCDict( CompressContext, cdict )
		  ZstdMaybeRaiseException code
		  
		  declare function ZSTD_DCtx_refDDict lib kLibZstd ( dctx as Ptr, ddict as ptr ) as UInteger
		  
		  code = ZSTD_DCtx_refDDict( DecompressContext, ddict )
		  ZstdMaybeRaiseException code
		  
		  self.Dictionary = zstdDictionary
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = false
		Private Shared Sub ValidateCoresValue(value As Integer)
		  if value <> 0 then
		    var bounds as Pair = CCTX.GetBounds( CCTX.kParamNbWorkers )
		    var lowerBound as integer = bounds.Left.IntegerValue
		    var upperBound as integer = bounds.Right.IntegerValue
		    
		    if value < lowerBound or value > upperBound then
		      RaiseException "Invalid value for Cores, must be between " + lowerBound.ToString + " and " + upperBound.ToString
		    end if
		  end if
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DoConstruction()
	#tag EndHook


	#tag Property, Flags = &h1
		Protected CompressContext As CCTX
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected CompressionLevel As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mCores
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  if mCores = value then
			    return
			  end if
			  
			  #if TargetWindows then
			    if value <> DefaultCores then
			      //
			      // DefaultCores can't be changed on Windows right now
			      //
			      RaiseException "Cores is not yet supported on Windows"
			    end if
			  #endif
			  
			  mCores = value
			  
			End Set
		#tag EndSetter
		Cores As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, CompatibilityFlags = false
		#tag Getter
			Get
			  var result as Pair = CCTX.GetBounds( CCTX.kParamNbWorkers )
			  return result.Right.IntegerValue
			  
			End Get
		#tag EndGetter
		Shared CoresMax As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected DecompressContext As DCTX
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return mDefaultCores
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #if TargetWindows then
			    RaiseException "Cores is not yet supported on Windows"
			  #endif
			  
			  mDefaultCores = value
			End Set
		#tag EndSetter
		Shared DefaultCores As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected Dictionary As ZstdDictionary_MTC
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    #if TargetARM then
			      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
			    #elseif TargetX86 then
			      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
			    #endif
			  #endif
			  
			  declare function ZSTD_defaultCLevel lib kLibZstd () as Int32
			  return ZSTD_defaultCLevel
			  
			End Get
		#tag EndGetter
		Shared LevelDefault As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return kLevelFast
			  
			End Get
		#tag EndGetter
		Shared LevelFast As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    #if TargetARM then
			      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
			    #elseif TargetX86 then
			      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
			    #endif
			  #endif
			  
			  declare function ZSTD_maxCLevel lib kLibZstd () as Int32
			  var value as Int32 = ZSTD_maxCLevel
			  return value
			  
			End Get
		#tag EndGetter
		Shared LevelMax As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    #if TargetARM then
			      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
			    #elseif TargetX86 then
			      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
			    #endif
			  #endif
			  
			  declare function ZSTD_minCLevel lib kLibZstd () as Int32
			  var value as Int32 = ZSTD_minCLevel
			  
			  //**********************************************************/
			  //*                                                        */
			  //*   In Zstd lib v.1.5, there appears to be a bug where   */
			  //*    the byte order of the Int32 is incorrect and you    */
			  //*   will be a really low value (&H01 << 17), but since   */
			  //*   the library doesn't seem to care, we won't either    */
			  //*                                                        */
			  //**********************************************************/
			  
			  return value
			  
			End Get
		#tag EndGetter
		Shared LevelMin As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21, Description = 546865206E756D626572206F6620636F72657320746F2075736520666F7220636F6D7072657373696F6E2E
		Attributes( Hidden ) Private mCores As Integer
	#tag EndProperty

	#tag Property, Flags = &h21, Description = 466F7220636F6D7072657373696F6E2C20746865206E756D626572206F6620636F72657320746F207573652062792064656661756C742E
		Attributes( Hidden ) Private Shared mDefaultCores As Integer = 0
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    #if TargetARM then
			      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
			    #elseif TargetX86 then
			      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
			    #endif
			  #endif
			  
			  declare function ZSTD_versionNumber lib kLibZstd () As UInteger
			  return ZSTD_versionNumber()
			  
			End Get
		#tag EndGetter
		Shared Version As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  #if TargetMacOS then
			    #if TargetARM then
			      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
			    #elseif TargetX86 then
			      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
			    #endif
			  #endif
			  
			  declare function ZSTD_versionString lib kLibZstd () As CString
			  return ZSTD_versionString()
			  
			End Get
		#tag EndGetter
		Shared VersionString As String
	#tag EndComputedProperty


	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"-999999", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kLevelFast, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = ZSTD_CONTENTSIZE_ERROR, Type = Double, Dynamic = False, Default = \"&hFFFFFFFFFFFFFFFE", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = ZSTD_CONTENTSIZE_UNKNOWN, Type = Double, Dynamic = False, Default = \"&hFFFFFFFFFFFFFFFF", Scope = Protected
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Cores"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
