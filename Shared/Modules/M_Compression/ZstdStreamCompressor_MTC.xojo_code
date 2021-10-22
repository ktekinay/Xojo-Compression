#tag Class
Class ZstdStreamCompressor_MTC
Inherits M_Compression.ZstdStream
	#tag Event
		Sub DoFlush()
		  var dataRemaining as UInteger
		  
		  do
		    dataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.ContinueIt )
		    FlushBuffer OutBuffer
		    
		    if InBuffer.Pos >= InBuffer.VirtualSize then
		      InBuffer.Pos = 0
		      InBuffer.VirtualSize = 0
		    end if
		  loop until dataRemaining = 0
		  
		  do
		    dataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.FlushIt )
		    FlushBuffer OutBuffer
		  loop until dataRemaining = 0
		  
		  dataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.EndIt )
		  FlushBuffer OutBuffer
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DoReset()
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  var error as UInteger
		  
		  declare function ZSTD_initCStream lib kLibZstd ( zsc as ptr, compressionLevel as Int32 ) as UInteger
		  error = ZSTD_initCStream( self.CompressContext, DefaultLevel )
		  ZstdMaybeRaiseException error 
		  
		  var inbufferSize as UInteger = RecommendedChunkSize
		  
		  declare function ZSTD_CStreamOutSize lib kLibZstd () as UInteger
		  var outBufferSize as UInteger = ZSTD_CStreamOutSize
		  ZstdMaybeRaiseException outBufferSize
		  
		  if InBufferData is nil or InBufferData.Size <> inBufferSize then
		    InBufferData = new MemoryBlock( inBufferSize )
		  end if
		  
		  if OutBufferData is nil or OutBufferData.Size <> outBufferSize then
		    OutBufferData = new MemoryBlock( outBufferSize )
		  end if
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DoWrite(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer, ByRef dataRemaining As UInteger)
		  dataRemaining = CompressStream2( outBuffer, inBuffer, Directives.ContinueIt )
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function CompressStream2(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer, directive As Directives) As UInteger
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_compressStream2 lib kLibZstd ( _
		  cctx as ptr, _
		  ByRef output as ZstdBuffer, _
		  ByRef input as ZstdBuffer, _
		  endOp as Directives _
		  ) as UInteger
		  
		  var result as UInteger = ZSTD_compressStream2( CompressContext, outBuffer, inBuffer, directive )
		  ZstdMaybeRaiseException result
		  
		  return result
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  super.Constructor( defaultLevel )
		  
		  Reset
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Attributes( Hidden ) Private mRecommendedChunkSize As Integer
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
			  
			  if mRecommendedChunkSize = 0 then
			    declare function ZSTD_CStreamInSize lib kLibZstd () as UInteger
			    var inbufferSize as Uinteger = ZSTD_CStreamInSize
			    ZstdMaybeRaiseException inBufferSize
			    
			    mRecommendedChunkSize = inBufferSize
			  end if
			  
			  return mRecommendedChunkSize
			  
			End Get
		#tag EndGetter
		RecommendedChunkSize As Integer
	#tag EndComputedProperty


	#tag Enum, Name = Directives, Type = Integer, Flags = &h21
		ContinueIt
		  FlushIt
		EndIt
	#tag EndEnum


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
			Name="IsDataAvailable"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RecommendedChunkSize"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
