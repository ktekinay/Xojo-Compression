#tag Class
Private Class CCTX
Inherits ZstdStructure
	#tag Event , Description = 43726561746520616E6420696E697469616C697A652061206E6577207374727563747572652E
		Function CreateStructure() As Ptr
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_createCCtx lib kLibZstd () as ptr
		  return ZSTD_createCCtx
		  
		End Function
	#tag EndEvent

	#tag Event , Description = 54686520636C61737320737472756374757265206E6565647320746F20626520746F726E20646F776E2E
		Function Destroy(p As Ptr) As UInteger
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_freeCCtx lib kLibZstd ( cctx as ptr ) as UInteger
		  return ZSTD_freeCCtx( p )
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Shared Function GetBounds(param As Integer) As Pair
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var result as ZstdBounds
		  
		  declare function ZSTD_cParam_getBounds lib kLibZstd ( param As UInt32 ) As ZstdBounds
		  result = ZSTD_cParam_getBounds( param )
		  
		  #if DebugBuild then
		    var mb as MemoryBlock = result.StringValue( TargetLittleEndian )
		    mb = mb
		  #endif
		  
		  ZstdMaybeRaiseException result.Error
		  
		  return result.LowerBound : result.UpperBound
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ResetSession()
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  const kResetSessionOnly as integer = 1
		  const kResetSessionAndParameters as integer = 3
		  
		  declare function ZSTD_CCtx_reset lib kLibZstd ( cctx as ptr, directive as UInt32 ) as UInteger
		  
		  var code as UInteger = ZSTD_CCtx_reset( self, kResetSessionOnly )
		  ZstdMaybeRaiseException code
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SetParameter(param As Integer, value As Integer) As Integer
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_CCtx_setParameter lib kLibZstd ( cctx as ptr, param as Int32, value as Int32 ) as UInteger
		  var code as UInteger = ZSTD_CCtx_setParameter( self, param, value )
		  ZstdMaybeRaiseException( code )
		  
		  return code
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPledgedSourceSize(size As UInteger)
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_CCtx_setPledgedSrcSize lib kLibZstd ( cctx as ptr, pledgedSrcSize as UInt64 ) as UInteger
		  var code as UInteger = ZSTD_CCtx_setPledgedSrcSize( self, size )
		  ZstdMaybeRaiseException( code )
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kParamCCompressionLevel, Type = Double, Dynamic = False, Default = \"100", Scope = Public
	#tag EndConstant

	#tag Constant, Name = kParamChainLog, Type = Double, Dynamic = False, Default = \"103", Scope = Public, Description = 53697A65206F6620746865206D756C74692D70726F626520736561726368207461626C652C206173206120706F776572206F6620322E
	#tag EndConstant

	#tag Constant, Name = kParamChecksumFlag, Type = Double, Dynamic = False, Default = \"201", Scope = Public, Description = 412033322D6269747320636865636B73756D206F6620636F6E74656E74206973207772697474656E20617420656E64206F66206672616D65202864656661756C743A3029202A2F
	#tag EndConstant

	#tag Constant, Name = kParamCompressionLevel, Type = Double, Dynamic = False, Default = \"100", Scope = Public, Description = 53657420636F6D7072657373696F6E20706172616D6574657273206163636F7264696E6720746F207072652D646566696E656420634C6576656C207461626C652E
	#tag EndConstant

	#tag Constant, Name = kParamContentSizeFlag, Type = Double, Dynamic = False, Default = \"200", Scope = Public, Description = 436F6E74656E742073697A652077696C6C206265207772697474656E20696E746F206672616D6520686561646572205F7768656E65766572206B6E6F776E5F202864656661756C743A3129
	#tag EndConstant

	#tag Constant, Name = kParamDictIDFlag, Type = Double, Dynamic = False, Default = \"202", Scope = Public, Description = 5768656E206170706C696361626C652C2064696374696F6E6172792773204944206973207772697474656E20696E746F206672616D6520686561646572202864656661756C743A3129202A2F
	#tag EndConstant

	#tag Constant, Name = kParamEnableLongDistanceMatching, Type = Double, Dynamic = False, Default = \"160", Scope = Public, Description = 456E61626C65206C6F6E672064697374616E6365206D61746368696E672E
	#tag EndConstant

	#tag Constant, Name = kParamHashLog, Type = Double, Dynamic = False, Default = \"102", Scope = Public, Description = 53697A65206F662074686520696E697469616C2070726F6265207461626C652C206173206120706F776572206F6620322E
	#tag EndConstant

	#tag Constant, Name = kParamJobSize, Type = Double, Dynamic = False, Default = \"401", Scope = Public, Description = 53697A65206F66206120636F6D7072657373696F6E206A6F622E20546869732076616C756520697320656E666F72636564206F6E6C79207768656E206E62576F726B657273203E3D20312E
	#tag EndConstant

	#tag Constant, Name = kParamLdmBucketSizeLog, Type = Double, Dynamic = False, Default = \"163", Scope = Public, Description = 4C6F672073697A65206F662065616368206275636B657420696E20746865204C444D2068617368207461626C6520666F7220636F6C6C6973696F6E207265736F6C7574696F6E2E
	#tag EndConstant

	#tag Constant, Name = kParamLdmHashLog, Type = Double, Dynamic = False, Default = \"161", Scope = Public, Description = 53697A65206F6620746865207461626C6520666F72206C6F6E672064697374616E6365206D61746368696E672C206173206120706F776572206F6620322E
	#tag EndConstant

	#tag Constant, Name = kParamLdmHashRateLog, Type = Double, Dynamic = False, Default = \"164", Scope = Public, Description = 4672657175656E6379206F6620696E73657274696E672F6C6F6F6B696E6720757020656E747269657320696E746F20746865204C444D2068617368207461626C652E
	#tag EndConstant

	#tag Constant, Name = kParamLdmMinMatch, Type = Double, Dynamic = False, Default = \"162", Scope = Public, Description = 4D696E696D756D206D617463682073697A6520666F72206C6F6E672064697374616E6365206D6174636865722E
	#tag EndConstant

	#tag Constant, Name = kParamMinMatch, Type = Double, Dynamic = False, Default = \"105", Scope = Public, Description = 4D696E696D756D2073697A65206F66207365617263686564206D6174636865732E
	#tag EndConstant

	#tag Constant, Name = kParamNbWorkers, Type = Double, Dynamic = False, Default = \"400", Scope = Public, Description = 53656C65637420686F77206D616E7920746872656164732077696C6C20626520737061776E656420746F20636F6D707265737320696E20706172616C6C656C2E
	#tag EndConstant

	#tag Constant, Name = kParamOverlapLog, Type = Double, Dynamic = False, Default = \"402", Scope = Public, Description = 436F6E74726F6C20746865206F7665726C61702073697A652C2061732061206672616374696F6E206F662077696E646F772073697A652E
	#tag EndConstant

	#tag Constant, Name = kParamSearchLog, Type = Double, Dynamic = False, Default = \"104", Scope = Public, Description = 4E756D626572206F662073656172636820617474656D7074732C206173206120706F776572206F6620322E
	#tag EndConstant

	#tag Constant, Name = kParamStrategy, Type = Double, Dynamic = False, Default = \"107", Scope = Public, Description = 536565205A5354445F737472617465677920656E756D20646566696E6974696F6E2E
	#tag EndConstant

	#tag Constant, Name = kParamTargetLength, Type = Double, Dynamic = False, Default = \"106", Scope = Public, Description = 496D70616374206F662074686973206669656C6420646570656E6473206F6E2073747261746567792E
	#tag EndConstant

	#tag Constant, Name = kParamWindowLog, Type = Double, Dynamic = False, Default = \"101", Scope = Public, Description = 4D6178696D756D20616C6C6F776564206261636B2D7265666572656E63652064697374616E63652C2065787072657373656420617320706F776572206F6620322E
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
	#tag EndViewBehavior
End Class
#tag EndClass
