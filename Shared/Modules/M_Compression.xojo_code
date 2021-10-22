#tag Module
Protected Module M_Compression
	#tag Method, Flags = &h21
		Private Sub RaiseException(msg As String)
		  var err as new CompressionException_MTC
		  err.Message = msg
		  raise err
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ZstdGetErrorName(code As UInteger) As String
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_getErrorName lib kLibZstd ( code as UInteger ) as CString
		  return ZSTD_getErrorName( code )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ZstdIsError(code As UInteger) As Boolean
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_isError lib kLibZstd ( code as UInteger ) as UInteger
		  var result as UInteger = ZSTD_isError( code )
		  
		  const kZero as UInteger = 0
		  return result <> kZero
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ZstdMaybeRaiseException(code As UInteger, useMessage As String = "")
		  if ZstdIsError( code ) then
		    var msg as string = useMessage
		    if msg = "" then
		      msg = ZstdGetErrorName( code )
		    end if
		    
		    RaiseException msg
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kLibZlib, Type = String, Dynamic = False, Default = \"libz.dylib", Scope = Private
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"libz.dylib"
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"zlib1.dll"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"libz.so"
	#tag EndConstant

	#tag Constant, Name = kLibZstd, Type = String, Dynamic = False, Default = \"libzstd.dylib", Scope = Private
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"libzstd.dylib"
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"libzstd.dll"
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
End Module
#tag EndModule
