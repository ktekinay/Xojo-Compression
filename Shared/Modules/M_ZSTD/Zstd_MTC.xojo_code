#tag Class
Class Zstd_MTC
	#tag Method, Flags = &h0
		Function Compress(src As MemoryBlock, compressionLevel As Integer = kLevelDefault) As String
		  if CompressContext is nil then
		    CompressContext = new CCTX
		  end if
		  
		  var destSize as integer = CompressBound( src )
		  var dest as new MemoryBlock( destSize )
		  
		  if compressionLevel = kLevelDefault then
		    compressionLevel = DefaultLevel
		  end if
		  
		  declare function ZSTD_compressCCtx lib kLib ( _
		  cctx as ptr, _
		  dst as ptr, dstCapacity as UInteger, _
		  src as ptr, srcSize as UInteger, _
		  compressionLevel as integer ) as UInteger
		  
		  MySemaphore.Signal
		  var actualSize as UInteger = ZSTD_compressCCtx( CompressContext, dest, destSize, src, src.Size, compressionLevel )
		  MySemaphore.Release
		  MaybeRaiseException actualSize
		  
		  return dest.StringValue( 0, actualSize )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CompressBound(src As MemoryBlock) As Integer
		  declare function ZSTD_compressBound lib kLib ( size as UInteger ) as UInteger
		  return ZSTD_compressBound( src.Size )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  self.DefaultLevel = defaultLevel
		  
		  MySemaphore = new Semaphore
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Decompress(src As MemoryBlock, encoding As TextEncoding = Nil) As String
		  if DecompressContext is nil then
		    DecompressContext = new DCTX
		  end if
		  
		  var decompressedSize as UInteger = GetFrameContentSize( src )
		  if decompressedSize = ZSTD_CONTENTSIZE_UNKNOWN then
		    RaiseException "Unknown size, use streaming functions"
		  end if
		  
		  var dest as new MemoryBlock( decompressedSize )
		  
		  declare function ZSTD_decompressDCtx lib kLib ( dctx as ptr, dst as ptr, dstCapacity as UInteger, src as ptr, compressedSize as UInteger ) as UInteger
		  
		  MySemaphore.Signal
		  var actualSize as UInteger = _
		  ZSTD_decompressDCtx( DecompressContext, dest, dest.Size, src, src.Size )
		  MySemaphore.Release
		  
		  return dest.StringValue( 0, actualSize, encoding )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetFrameContentSize(src As MemoryBlock) As UInteger
		  declare function ZSTD_getFrameContentSize lib kLib ( src as ptr, srcSize as UInteger ) as UInteger
		  
		  var size as UInteger = ZSTD_getFrameContentSize( src, src.Size )
		  if size = ZSTD_CONTENTSIZE_ERROR then
		    RaiseException "Invalid data"
		  end if
		  
		  return size
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CompressContext As CCTX
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DecompressContext As DCTX
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DefaultLevel As Integer
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
			  declare function ZSTD_maxCLevel lib kLib () as integer
			  return ZSTD_maxCLevel
			  
			End Get
		#tag EndGetter
		Shared LevelMax As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  declare function ZSTD_minCLevel lib kLib () as integer
			  return ZSTD_minCLevel
			  
			End Get
		#tag EndGetter
		Shared LevelMin As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private MySemaphore As Semaphore
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  declare function ZSTD_versionNumber lib kLib () As UInteger
			  return ZSTD_versionNumber()
			  
			End Get
		#tag EndGetter
		Version As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  declare function ZSTD_versionString lib kLib () As CString
			  return ZSTD_versionString()
			  
			End Get
		#tag EndGetter
		VersionString As String
	#tag EndComputedProperty


	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kLevelFast, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = ZSTD_CONTENTSIZE_ERROR, Type = Double, Dynamic = False, Default = \"&hFFFFFFFFFFFFFFFE", Scope = Private
	#tag EndConstant

	#tag Constant, Name = ZSTD_CONTENTSIZE_UNKNOWN, Type = Double, Dynamic = False, Default = \"&hFFFFFFFFFFFFFFFF", Scope = Private
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
			Name="Version"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="VersionString"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
