#tag Class
Private Class DCTX
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
		  
		  declare function ZSTD_createDCtx lib kLibZstd () as ptr
		  return ZSTD_createDCtx
		  
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
		  
		  declare function ZSTD_freeDCtx lib kLibZstd ( cctx as ptr ) as UInteger
		  return ZSTD_freeDCtx( p )
		  
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
		  
		  declare function ZSTD_dParam_getBounds lib kLibZstd ( param As UInt32 ) As ZstdBounds
		  result = ZSTD_dParam_getBounds( param )
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
		  
		  declare function ZSTD_DCtx_reset lib kLibZstd ( dctx as ptr, directive as UInt32 ) as UInteger
		  
		  var code as UInteger = ZSTD_DCtx_reset( self, kResetSessionOnly )
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
		  
		  declare function ZSTD_DCtx_setParameter lib kLibZstd ( dctx as ptr, param as Int32, value as Int32 ) as UInteger
		  var code as UInteger = ZSTD_DCtx_setParameter( self, param, value )
		  ZstdMaybeRaiseException( code )
		  
		  return code
		  
		End Function
	#tag EndMethod


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
