#tag Class
Class ZstdDictionary_MTC
Implements M_Compression.ZstdDictionaryInterface
	#tag Method, Flags = &h0
		Sub Constructor(dictData As String, compressionLevel As Integer = kLevelDefault)
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  if compressionLevel = kLevelDefault then
		    compressionLevel = Zstd_MTC.LevelDefault
		  end if
		  
		  //
		  // Must be ready for an empty string
		  //
		  
		  var dictMB as MemoryBlock
		  var dictBuffer as ptr
		  var dictBufferSize as integer
		  
		  if dictData <> "" then
		    dictMB = dictData
		    dictBuffer = dictMB
		    dictBufferSize = dictMB.Size
		  end if
		  
		  declare function ZSTD_createCDict lib kLibZstd ( dictBuffer as ptr, dictBufferSize as UInteger, compressionLevel as Int32 ) as ptr
		  
		  CDict = ZSTD_createCDict( dictBuffer, dictBufferSize, compressionLevel )
		  
		  declare function ZSTD_createDDict lib kLibZStd ( dictbuffer as ptr, dictBufferSize as UInteger ) as ptr
		  
		  DDict = ZSTD_createDDict( dictBuffer, dictBufferSize )
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var code as UInteger
		  
		  if CDict <> nil then
		    declare function ZSTD_freeCDict lib kLibZstd ( cdict as ptr ) as UInteger
		    
		    code = ZSTD_freeCDict( CDict )
		    ZstdMaybeRaiseException code
		    
		    CDict = nil
		  end if
		  
		  if DDict <> nil then
		    declare function ZSTD_freeDDict lib kLibZstd ( ddict as ptr ) as UInteger
		    
		    code = ZSTD_freeDDict( DDict )
		    ZstdMaybeRaiseException code
		    
		    DDict = nil
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetCDict() As Ptr
		  return CDict
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetDDict() As Ptr
		  return DDict
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CDict As Ptr
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DDict As Ptr
	#tag EndProperty


	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"-999999", Scope = Protected
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
			Name="CDict"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
