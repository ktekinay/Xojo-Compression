#tag Class
Class Zstd_MTC
Inherits ZstdBase
Implements M_Compression.Compressor_MTC
	#tag Event
		Sub DoConstruction()
		  //
		  // Placeholder to hide this from the outside
		  //
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function Compress(src As MemoryBlock) As String
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var destSize as integer = CompressBound( src )
		  var dest as new MemoryBlock( destSize )
		  
		  var compressionLevel as integer = DefaultLevel
		  
		  MySemaphore.Signal
		  try
		    CompressContext.SetParameter( CCTX.kParamCompressionLevel, compressionLevel )
		    CompressContext.SetParameter( CCTX.kParamNbWorkers, Cores )
		    CompressContext.SetPledgedSourceSize( src.Size )
		    
		  catch err as RuntimeException
		    MySemaphore.Release
		    raise err
		  end try
		  
		  declare function ZSTD_compress2 lib kLibZstd ( _
		  cctx as ptr, _
		  dst as ptr, dstCapacity as UInteger, _
		  src as ptr, srcSize as UInteger _
		  ) as UInteger
		  
		  var actualSize as UInteger = ZSTD_compress2( CompressContext, dest, destSize, src, src.Size )
		  
		  MySemaphore.Release
		  ZstdMaybeRaiseException actualSize
		  
		  return dest.StringValue( 0, actualSize )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CompressBound(src As MemoryBlock) As Integer
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_compressBound lib kLibZstd ( size as UInteger ) as UInteger
		  return ZSTD_compressBound( src.Size )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  super.Constructor( defaultLevel )
		  
		  MySemaphore = new Semaphore
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Decompress(src As MemoryBlock, encoding As TextEncoding = Nil) As String
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var decompressedSize as UInteger = GetFrameContentSize( src )
		  if decompressedSize = ZSTD_CONTENTSIZE_UNKNOWN then
		    RaiseException "Unknown size, use streaming classes"
		  end if
		  
		  var dest as new MemoryBlock( decompressedSize )
		  
		  MySemaphore.Signal
		  declare function ZSTD_decompressDCtx lib kLibZstd ( dctx as ptr, dst as ptr, dstCapacity as UInteger, src as ptr, compressedSize as UInteger ) as UInteger
		  
		  var actualSize as UInteger = _
		  ZSTD_decompressDCtx( DecompressContext, dest, dest.Size, src, src.Size )
		  MySemaphore.Release
		  
		  return dest.StringValue( 0, actualSize, encoding )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetFrameContentSize(src As MemoryBlock) As UInteger
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_getFrameContentSize lib kLibZstd ( src as ptr, srcSize as UInteger ) as UInteger
		  
		  var size as UInteger = ZSTD_getFrameContentSize( src, src.Size )
		  if size = ZSTD_CONTENTSIZE_ERROR then
		    RaiseException "Invalid data"
		  end if
		  
		  return size
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private MySemaphore As Semaphore
	#tag EndProperty


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
