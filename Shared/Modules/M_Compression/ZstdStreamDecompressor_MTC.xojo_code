#tag Class
Class ZstdStreamDecompressor_MTC
Inherits M_Compression.ZstdStream
	#tag Event
		Sub DoFlush()
		  var dataRemaining as UInteger
		  
		  while not IsFrameComplete or InBuffer.Pos < InBuffer.VirtualSize
		    dataRemaining = DecompressStream( OutBuffer, InBuffer )
		    if OutBuffer.Pos >= OutBuffer.VirtualSize then
		      FlushBuffer OutBuffer
		    end if
		    
		    if InBuffer.Pos >= InBuffer.VirtualSize then
		      InBuffer.Pos = 0
		      InBuffer.VirtualSize = 0
		    end if
		    
		    IsFrameComplete = dataRemaining = 0 // Have to set this here
		  wend
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub DoInit()
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
		  
		  IsAlwaysWrite = true
		  
		End Sub
	#tag EndEvent

	#tag Event , Description = 506572666F726D207468652057726974652C2072657475726E206461746152656D61696E696E6720696E2074686520706172616D6574657220616E64207768657468657220746865206672616D6520697320636F6D706C65746520696E2074686520726573756C742E
		Function DoWrite(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer, ByRef dataRemaining As UInteger) As Boolean
		  dataRemaining = DecompressStream( outBuffer, inBuffer )
		  return dataRemaining = 0
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  super.Constructor( kLevelDefault )
		  
		  Init
		  
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
			Name="IsFrameAvailable"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BytesAvailable"
			Visible=false
			Group="Behavior"
			InitialValue=""
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
