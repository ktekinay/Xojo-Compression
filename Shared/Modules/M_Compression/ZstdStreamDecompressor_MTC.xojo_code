#tag Class
Class ZstdStreamDecompressor_MTC
Inherits M_Compression.ZstdStreamBase
	#tag Event
		Sub DoFlush()
		  var dataRemaining as UInteger
		  
		  do
		    dataRemaining = DecompressStream( OutBuffer, InBuffer )
		    if OutBuffer.Pos >= OutBuffer.VirtualSize then
		      FlushBuffer OutBuffer
		    end if
		    
		    if InBuffer.Pos >= InBuffer.VirtualSize then
		      InBuffer.Pos = 0
		      InBuffer.VirtualSize = 0
		    end if
		  loop until dataRemaining = 0
		  
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
		  
		  declare function ZSTD_initDStream lib kLibZstd ( zsc as ptr ) as UInteger
		  error = ZSTD_initDStream( self.DecompressContext )
		  ZstdMaybeRaiseException error 
		  
		  var inbufferSize as UInteger = RecommendedChunkSize
		  
		  declare function ZSTD_DStreamOutSize lib kLibZstd () as UInteger
		  var outBufferSize as UInteger = ZSTD_DStreamOutSize
		  ZstdMaybeRaiseException outBufferSize
		  
		  InBufferData = new MemoryBlock( inBufferSize )
		  OutBufferData = new MemoryBlock( outBufferSize )
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DoWrite(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer, ByRef dataRemaining As UInteger)
		  dataRemaining = DecompressStream( outBuffer, inBuffer )
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  super.Constructor( kLevelDefault )
		  
		  Reset
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DecompressStream(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer) As UInteger
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  declare function ZSTD_decompressStream lib kLibZstd ( _
		  cctx as ptr, _
		  ByRef output as ZstdBuffer, _
		  ByRef input as ZstdBuffer _
		  ) as UInteger
		  
		  var result as UInteger = ZSTD_decompressStream( DecompressContext, outBuffer, inBuffer )
		  ZstdMaybeRaiseException result
		  
		  return result
		  
		End Function
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
			    declare function ZSTD_DStreamInSize lib kLibZstd () as UInteger
			    var inbufferSize as UInteger = ZSTD_DStreamInSize
			    ZstdMaybeRaiseException inBufferSize
			    
			    mRecommendedChunkSize = inBufferSize
			  end if
			  
			  return mRecommendedChunkSize
			  
			End Get
		#tag EndGetter
		RecommendedChunkSize As Integer
	#tag EndComputedProperty


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
