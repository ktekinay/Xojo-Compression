#tag Class
Protected Class Zstd_MTC
	#tag Method, Flags = &h0
		Function Compress(src As MemoryBlock, compressionLevel As Integer = kLevelDefault) As String
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
		  const k8 as UInt64 = 2 ^ 8
		  const k10 as UInt64 = 2 ^ 10
		  const k11 as UInt64 = 2 ^ 11
		  const kLimit as UInt64 = 128 * k10
		  
		  #if DebugBuild
		    var debugLimit as UInt64 = kLimit
		    #pragma unused debugLimit
		  #endif
		  
		  var srcSize as UInt64 = src.Size
		  
		  // this formula ensures that bound(A) + bound(B) <= bound(A+B) as long as A and B >= 128 KB
		  var bound as integer = _
		  srcSize + ( srcSize \ k8 ) + if( srcSize < kLimit, ( kLimit - srcSize) \ k11, 0 )
		  return bound
		  
		  // (srcSize + (srcSize>>8) + ((srcSize < (128<<10)) ? (((128<<10) - srcSize) >> 11) /* margin, from 64 to 0 */ : 0))  /* this formula ensures that bound(A) + bound(B) <= bound(A+B) as long as A and B >= 128 KB */
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  self.DefaultLevel = defaultLevel
		  
		  declare function ZSTD_createCCtx lib kLib () as ptr
		  CompressContext = ZSTD_createCCtx
		  
		  declare function ZSTD_createDCtx lib kLib () as ptr
		  DecompressContext = ZSTD_createDCtx
		  
		  MySemaphore = new Semaphore
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Decompress(src As MemoryBlock, encoding As TextEncoding = Nil) As String
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
		Private Sub Destructor()
		  if CompressContext <> nil then
		    declare function ZSTD_freeCCtx lib kLib ( cctx as ptr ) as UInteger
		    var size as integer = ZSTD_freeCCtx( CompressContext )
		    MaybeRaiseException size
		    
		    CompressContext = nil
		  end if
		  
		  if DecompressContext <> nil then
		    declare function ZSTD_freeDCtx lib kLib ( dctx as ptr ) as UInteger
		    var size as integer = ZSTD_freeDCtx( DecompressContext )
		    MaybeRaiseException size
		    
		    DecompressContext = nil
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Function GetErrorName(code As UInteger) As String
		  declare function ZSTD_getErrorName lib kLib ( code as UInteger ) as CString
		  return ZSTD_getErrorName( code )
		  
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

	#tag Method, Flags = &h21
		Private Shared Function IsError(code As UInteger) As Boolean
		  declare function ZSTD_isError lib kLib ( code as UInteger ) as UInteger
		  var result as UInteger = ZSTD_isError( code )
		  
		  const kZero as UInteger = 0
		  return result <> kZero
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub MaybeRaiseException(code As UInteger, useMessage As String = "")
		  if IsError( code ) then
		    var msg as string = useMessage
		    if msg = "" then
		      msg = GetErrorName( code )
		    end if
		    
		    RaiseException msg
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub RaiseException(msg As String)
		  var err as new RuntimeException
		  err.Message = msg
		  raise err
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CompressContext As Ptr
	#tag EndProperty

	#tag Property, Flags = &h21
		Private DecompressContext As Ptr
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

	#tag Constant, Name = kLib, Type = String, Dynamic = False, Default = \"libzstd.dylib", Scope = Protected
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
