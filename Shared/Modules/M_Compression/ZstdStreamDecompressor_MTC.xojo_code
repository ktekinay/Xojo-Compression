#tag Class
Class ZstdStreamDecompressor_MTC
Inherits M_Compression.ZstdStreamBase
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

	#tag Method, Flags = &h0
		Sub Flush()
		  // Part of the Writeable interface.
		  
		  var startingBytes as integer = DataBufferBytes
		  
		  FlushBuffer OutBuffer
		  do
		    DataRemaining = DecompressStream( OutBuffer, InBuffer )
		    FlushBuffer OutBuffer
		    
		    if InBuffer.Pos >= InBuffer.DataSize then
		      InBuffer.Pos = 0
		      InBuffer.DataSize = 0
		    end if
		  loop until OutBuffer.Pos < OutBuffer.DataSize
		  
		  if DataBufferBytes <> startingBytes then
		    RaiseDataAvailable
		  end if
		  
		  Reset
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  #if TargetMacOS then
		    #if TargetARM then
		      const kLibZstd as string = "ARM/" + M_Compression.kLibZstd
		    #elseif TargetX86 then
		      const kLibZstd as string = "Intel/" + M_Compression.kLibZstd
		    #endif
		  #endif
		  
		  super.Reset
		  
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
		  
		  InBuffer.Data = InBufferData
		  InBuffer.DataSize = 0
		  InBuffer.Pos = 0
		  
		  OutBuffer.Data = OutBufferData
		  OutBuffer.DataSize = outBufferSize
		  OutBuffer.Pos = 0
		  
		  IsEndOfFile = true
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(src As String)
		  // Part of the Writeable interface.
		  
		  #if not DebugBuild
		    #pragma BoundsChecking false
		    #pragma BreakOnExceptions false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  if src = "" then
		    //
		    // Nothing to do
		    //
		    return
		  end if
		  
		  IsEndOfFile = false
		  
		  //
		  // We have to split the src into chunks
		  // and consume it all
		  //
		  var inBuffer as ZstdBuffer = self.InBuffer
		  var outBuffer as ZstdBuffer = self.OutBuffer
		  
		  var inBufferDataSize as integer = InBufferData.Size
		  
		  var dataRemaining as UInteger = self.DataRemaining
		  var startingDataBufferBytes as integer = DataBufferBytes
		  
		  #if DebugBuild
		    var loopCount as integer // For debugging
		  #endif
		  
		  var prevOutBufferPos as UInteger = outBuffer.Pos
		  
		  do
		    #if DebugBuild
		      if loopCount = 0 then
		        loopCount = loopCount // A place to break
		      end if
		    #endif
		    
		    if outBuffer.Pos = outBuffer.DataSize then
		      FlushBuffer outBuffer
		    elseif outBuffer.Pos = prevOutBufferPos and src = "" then
		      exit
		    end if
		    
		    var chunk as string
		    
		    if src = "" or inBuffer.Pos <> 0 then
		      //
		      // Do nothing
		      //
		      
		    elseif dataRemaining <> 0 then
		      chunk = src.MiddleBytes( 0, dataRemaining )
		      src = src.MiddleBytes( dataRemaining )
		      
		    elseif src.Bytes <= inBufferDataSize then
		      chunk = src
		      src = ""
		      
		    else
		      chunk = src.MiddleBytes( 0, inBufferDataSize )
		      src = src.MiddleBytes( inBufferDataSize )
		      
		    end if
		    
		    if chunk <> "" then
		      InBufferData.StringValue( 0, chunk.Bytes ) = chunk
		      inBuffer.DataSize = chunk.Bytes
		    end if
		    
		    prevOutBufferPos = outBuffer.Pos
		    dataRemaining = DecompressStream( outBuffer, inBuffer )
		    
		    if inBuffer.Pos = inBuffer.DataSize then
		      inBuffer.Pos = 0
		      inBuffer.DataSize = 0
		    end if
		    
		    #if DebugBuild
		      loopCount = loopCount + 1
		    #endif
		  loop
		  
		  self.InBuffer = inBuffer
		  self.OutBuffer = outBuffer
		  self.DataRemaining = dataRemaining
		  
		  if DataBufferBytes <> startingDataBufferBytes then
		    RaiseDataAvailable
		  end if
		  
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
