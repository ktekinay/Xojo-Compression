#tag Class
Class Zlib_MTC
	#tag Method, Flags = &h0
		Function Compress2(src As MemoryBlock, compressionLevel As Integer = kLevelDefault) As MemoryBlock
		  var destSize as UInteger = CompressBound( src.Size )
		  var dest as new MemoryBlock( destSize )
		  
		  CompressToMemoryBlock src, dest, destSize, 0, compressionLevel
		  
		  if dest.Size <> destSize then
		    dest.Size = destSize
		  end if
		  
		  return dest
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CompressBound(size As UInteger) As UInteger
		  declare function compressBound lib kLibZlib ( size as UInteger ) as UInteger
		  return compressBound( size )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub CompressToMemoryBlock(src As MemoryBlock, ByRef dest As MemoryBlock, ByRef destSize As UInteger, startPos As Integer, compressionLevel As Integer)
		  if compressionLevel = kLevelDefault then
		    compressionLevel = DefaultLevel
		  end if
		  
		  var destPtr as ptr = dest
		  if startPos <> 0 then
		    destPtr = ptr( integer( destPtr ) + startPos )
		  end if
		  
		  declare function compress2 lib kLibZlib ( _
		  dest as ptr, ByRef destSize as UInteger, _
		  source as ptr, sourceLen as UInteger, _
		  level as Int32 _
		  ) as Int32
		  
		  var result as Int32 = compress2( destPtr, destSize, src, src.Size, compressionLevel )
		  MaybeRaiseException result
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  self.DefaultLevel = defaultLevel
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetMagicNumber() As String
		  return ChrB( &h1f ) + ChrB( &h8b )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub MaybeRaiseException(result As Integer, msg As String = "")
		  
		  select case result
		  case Z_MEM_ERROR
		    if msg = "" then
		      msg = "Not enough memory"
		    end if
		    
		  case Z_BUF_ERROR
		    if msg = "" then
		      msg = "Not enough room in the output buffer"
		    end if
		    
		  case Z_DATA_ERROR
		    if msg = "" then
		      msg = "Data error"
		    end if
		    
		  case else
		    msg = ""
		    
		  end select
		  
		  if msg <> "" then
		    RaiseException msg
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Uncompress(src As MemoryBlock, originalSize As Integer, encoding As TextEncoding = Nil) As String
		  return Uncompress( src, src.Size, originalSize, encoding )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Uncompress(srcPtr As Ptr, srcSize As Integer, originalSize As Integer, encoding As TextEncoding) As String
		  var dest as new MemoryBlock( originalSize )
		  var destSize as UInteger = originalSize
		  
		  declare function uncompress lib kLibZlib ( dest as ptr, ByRef destSize as UInteger, src as ptr, sourceLen as UInteger ) as Int32
		  
		  var result as Int32 = uncompress( dest, destSize, srcPtr, srcSize )
		  MaybeRaiseException result
		  
		  return dest.StringValue( 0, destSize, encoding )
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h1
		Protected DefaultLevel As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return kLevelDefault
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
			  return kLevelMax
			End Get
		#tag EndGetter
		Shared LevelMax As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  declare function zlibVersion lib kLibZlib () as CString
			  
			  return zlibVersion()
			  
			  
			End Get
		#tag EndGetter
		Shared Version As String
	#tag EndComputedProperty


	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"-1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kLevelFast, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kLevelMax, Type = Double, Dynamic = False, Default = \"9", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = Z_BUF_ERROR, Type = Double, Dynamic = False, Default = \"-5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_DATA_ERROR, Type = Double, Dynamic = False, Default = \"-3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_MEM_ERROR, Type = Double, Dynamic = False, Default = \"-4", Scope = Private
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
