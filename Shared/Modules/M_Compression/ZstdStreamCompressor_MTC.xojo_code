#tag Class
Class ZstdStreamCompressor_MTC
Inherits M_Compression.ZstdStreamBase
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

	#tag Method, Flags = &h0
		Sub Flush()
		  // Part of the Writeable interface.
		  
		  var startingBytes as integer = DataBufferBytes
		  
		  FlushBuffer OutBuffer
		  do
		    DataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.ContinueIt )
		    FlushBuffer OutBuffer
		    
		    if InBuffer.Pos >= InBuffer.DataSize then
		      InBuffer.Pos = 0
		      InBuffer.DataSize = 0
		    end if
		  loop until DataRemaining = 0
		  
		  do
		    DataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.FlushIt )
		    FlushBuffer OutBuffer
		  loop until DataRemaining = 0
		  
		  DataRemaining = CompressStream2( OutBuffer, InBuffer, Directives.EndIt )
		  FlushBuffer OutBuffer
		  
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
		  
		  declare function ZSTD_initCStream lib kLibZstd ( zsc as ptr, compressionLevel as Int32 ) as UInteger
		  error = ZSTD_initCStream( self.CompressContext, DefaultLevel )
		  ZstdMaybeRaiseException error 
		  
		  var inbufferSize as UInteger = RecommendedChunkSize
		  
		  declare function ZSTD_CStreamOutSize lib kLibZstd () as UInteger
		  var outBufferSize as UInteger = ZSTD_CStreamOutSize
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
		  
		  IsEndOfFile = false
		  
		  //
		  // We have to split the src into chunks
		  // and consume it all
		  //
		  var inBuffer as ZstdBuffer = self.InBuffer
		  var outBuffer as ZstdBuffer = self.OutBuffer
		  
		  var dataRemaining as UInteger = self.DataRemaining
		  
		  while src <> ""
		    var remainingInBuffer as integer = InBufferData.Size - inBuffer.Pos
		    var chunk as string
		    
		    if src.Bytes <= remainingInBuffer then
		      chunk = src
		      src = ""
		      
		    else
		      chunk = src.MiddleBytes( 0, remainingInBuffer )
		      src = src.MiddleBytes( remainingInBuffer )
		      
		    end if
		    
		    if chunk <> "" then
		      InBufferData.StringValue( inBuffer.Pos, chunk.Bytes ) = chunk
		      inBuffer.DataSize = InBuffer.Pos + chunk.Bytes
		    end if
		    
		    dataRemaining = CompressStream2( outBuffer, inBuffer, Directives.ContinueIt )
		    
		    if inBuffer.Pos = inBuffer.DataSize then
		      inBuffer.Pos = 0
		      inBuffer.DataSize = 0
		    end if
		    
		    if dataRemaining <> 0 then
		      FlushBuffer outBuffer
		      RaiseDataAvailable
		    end if
		  wend
		  
		  self.InBuffer = inBuffer
		  self.OutBuffer = outBuffer
		  self.DataRemaining = dataRemaining
		  
		  
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
