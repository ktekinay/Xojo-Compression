#tag Module
Protected Module Gzip
	#tag Method, Flags = &h1
		Protected Function Compress(s as string, level as integer = Z_DEFAULT_COMPRESSION) As string
		  soft declare function compress2 lib gzip_library (dest as Ptr, byref destLen as integer, source as Cstring, sourceLen as integer, level as integer) as integer
		  
		  dim bufferLen as integer = lenb(s) * 1.1  + 12
		  dim buffer as memoryblock
		  buffer = new memoryblock(bufferLen)
		  
		  compressError = compress2 (buffer, bufferLen, s, lenb(s), level)
		  
		  if compressError = Z_OK then
		    
		    return buffer.StringValue(0,bufferLen)
		    
		  else
		    
		    return ""
		    
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Error() As integer
		  return compressError
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Uncompress(source as string, uncompressedSize as integer) As String
		  soft declare function uncompress lib gzip_library (dest as Ptr, byref destLen as integer, source as Cstring, sourceLen as integer) as integer
		  
		  dim bufferLen as integer =  uncompressedSize
		  dim buffer as memoryblock
		  buffer  = new MemoryBlock(bufferLen)
		  
		  compressError = uncompress (buffer, bufferLen, source, lenb(source))
		  
		  if compressError = Z_OK then
		    return buffer.StringValue(0, bufferLen)
		  else
		    return ""
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Version() As string
		  soft declare function zlibVersion lib gzip_library () as CString
		  
		  return zlibVersion()
		  
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private compressError As integer
	#tag EndProperty


	#tag Constant, Name = gzip_library, Type = String, Dynamic = False, Default = \"libz.dylib", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"libz.dylib"
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"zlib1.dll"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"libz.so"
	#tag EndConstant

	#tag Constant, Name = Z_BEST_COMPRESSION, Type = Double, Dynamic = False, Default = \"9", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_BEST_SPEED_COMPRESSION, Type = Double, Dynamic = False, Default = \"1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_BUF_ERROR, Type = Double, Dynamic = False, Default = \"-5", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_DATA_ERROR, Type = Double, Dynamic = False, Default = \"-3", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_DEFAULT_COMPRESSION, Type = Double, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_ERRNO, Type = Double, Dynamic = False, Default = \"-1", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_MEM_ERROR, Type = Double, Dynamic = False, Default = \"-4", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_NO_COMPRESSION, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_OK, Type = Double, Dynamic = False, Default = \"0", Scope = Public
	#tag EndConstant

	#tag Constant, Name = Z_STREAM_ERROR, Type = Double, Dynamic = False, Default = \"-2", Scope = Public
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="2147483648"
			Type="Integer"
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
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
