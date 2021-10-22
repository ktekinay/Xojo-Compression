#tag Class
Protected Class ZstdStreamTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub ConcurrentThreadTest()
		  AsyncAwait 5
		  
		  ThreadCompressor = new ZstdStreamCompressor_MTC
		  
		  var th as new Thread
		  AddHandler th.Run, WeakAddressOf ConcurrentThreadTest_Run
		  
		  th.Start
		  
		  while th.ThreadState <> Thread.ThreadStates.Sleeping
		    Thread.YieldToNext
		  wend
		  
		  var startµs as double = System.Microseconds
		  
		  while ( System.Microseconds - startµs ) < 500000
		    ThreadCompressor.Write "abc"
		  wend
		  
		  RemoveHandler th.Run, WeakAddressOf ConcurrentThreadTest_Run
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ConcurrentThreadTest_Run(sender As Thread)
		  sender.Sleep 100
		  
		  #pragma BreakOnExceptions false
		  try
		    ThreadCompressor.Write "abc"
		    Assert.Fail "No exception"
		  catch err as RuntimeException
		    Assert.Pass 
		  end try
		  #pragma BreakOnExceptions default
		  
		  AsyncComplete
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DataAvailableEventTest()
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  var s as string = CompressionTestGroup.BigData
		  var chunkSize as integer = compressor.RecommendedChunkSize
		  
		  AddHandler compressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  for i as integer = 0 to s.Bytes - 1 step chunkSize
		    compressor.Write s.MiddleBytes( i, chunkSize )
		  next
		  compressor.Flush
		  RemoveHandler compressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  
		  var collected() as string
		  if true then
		    var empty() as string
		    collected = CollectedStream
		    CollectedStream = empty
		  end if
		  
		  AddHandler decompressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  for each block as string in collected
		    decompressor.Write block
		  next
		  decompressor.Flush
		  RemoveHandler decompressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  
		  var decompressed as string = String.FromArray( CollectedStream, "" )
		  decompressed = decompressed.DefineEncoding( s.Encoding )
		  
		  Assert.AreSame s, decompressed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReuseTest()
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  var s as string = CompressionTestGroup.BigData
		  
		  compressor.Write s
		  call compressor.Flush
		  decompressor.Write compressor.ReadAll
		  decompressor.Flush
		  var decompressed as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreSame s, decompressed, "Mismatch 1"
		  
		  s = "abcdegefghijklmnop12345 abcdegefghijklmnop12345 abcdegefghijklmnop12345 abcdegefghijklmnop12345"
		  compressor.Write s
		  compressor.Flush
		  decompressor.Write compressor.ReadAll
		  decompressor.Flush
		  decompressed = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreSame s, decompressed, "Mismatch 2"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SequentialThreadTest()
		  AsyncAwait 5
		  
		  ThreadCompressor = new ZstdStreamCompressor_MTC
		  
		  var th as new Thread
		  AddHandler th.Run, WeakAddressOf SequentialThreadTest_Run
		  
		  th.Start
		  
		  while th.ThreadState <> Thread.ThreadStates.Sleeping
		    Thread.YieldToNext
		  wend
		  
		  ThreadCompressor.Write "abc"
		  ThreadCompressor.Flush
		  call ThreadCompressor.ReadAll
		  
		  RemoveHandler th.Run, WeakAddressOf SequentialThreadTest_Run
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SequentialThreadTest_Run(sender As Thread)
		  sender.Sleep 100
		  
		  while ThreadCompressor.IsDataAvailable
		    Thread.YieldToNext
		  wend
		  
		  ThreadCompressor.Write "abc"
		  ThreadCompressor.Flush
		  call ThreadCompressor.ReadAll
		  
		  Assert.Pass
		  
		  AsyncComplete
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StreamWithEvenBlocksTest()
		  var compressedByCLI as string
		  
		  if true then
		    var bs as BinaryStream = BinaryStream.Open( SpecialFolder.Resource( "json_test_stream_level-1.zst" ) )
		    compressedByCLI = bs.Read( bs.Length )
		    bs.Close
		  end if
		  
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  
		  var s as string = CompressionTestGroup.BigData
		  
		  StartTestTimer "compressing"
		  for pos as integer = 0 to s.Bytes - 1 step compressor.RecommendedChunkSize
		    compressor.Write s.MiddleBytes( pos, compressor.RecommendedChunkSize )
		  next
		  compressor.Flush
		  
		  var compressed as string = compressor.ReadAll
		  LogTestTimer "compressing"
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  try
		    StartTestTimer "decompress native"
		    for pos as integer = 0 to compressed.Bytes step decompressor.RecommendedChunkSize
		      decompressor.Write compressed.MiddleBytes( pos, decompressor.RecommendedChunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decompress native"
		    Assert.Pass "Decompressed"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		  var decompressed as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreEqual s.Bytes, decompressed.Bytes, "decompressed byte count doesn't match"
		  if StrComp( decompressed, s, 0 ) <> 0 then
		    Assert.Fail "decompressed bytes don't match"
		  else
		    Assert.Pass
		  end if
		  
		  decompressor = new ZstdStreamDecompressor_MTC
		  
		  try
		    StartTestTimer "decompress cli"
		    for pos as integer = 0 to compressedByCLI.Bytes step decompressor.RecommendedChunkSize
		      decompressor.Write compressedByCLI.MiddleBytes( pos, decompressor.RecommendedChunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decompress cli"
		    Assert.Pass "Decompressed compressedByCLI"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StreamWithUnevenBlocksTest()
		  var compressedByCLI as string
		  
		  if true then
		    var bs as BinaryStream = BinaryStream.Open( SpecialFolder.Resource( "json_test_stream_level-1.zst" ) )
		    compressedByCLI = bs.Read( bs.Length )
		    bs.Close
		  end if
		  
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  var chunkSize as integer = compressor.RecommendedChunkSize + 1
		  
		  var s as string = CompressionTestGroup.BigData
		  
		  StartTestTimer "compressing"
		  for pos as integer = 0 to s.Bytes - 1 step chunkSize
		    compressor.Write s.MiddleBytes( pos, chunkSize )
		  next
		  compressor.Flush
		  
		  var compressed as string = compressor.ReadAll
		  LogTestTimer "compressing"
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  chunkSize = decompressor.RecommendedChunkSize + 1
		  try
		    StartTestTimer "decompress native"
		    for pos as integer = 0 to compressed.Bytes step chunkSize
		      decompressor.Write compressed.MiddleBytes( pos, chunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decompress native"
		    Assert.Pass "Decompressed"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		  var decompressed as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreEqual s.Bytes, decompressed.Bytes, "decompressed byte count doesn't match"
		  if StrComp( decompressed, s, 0 ) <> 0 then
		    Assert.Fail "decompressed bytes don't match"
		    var m1 as MemoryBlock = s
		    var m2 as MemoryBlock = decompressed
		    
		    var p1 as ptr = m1
		    var p2 as ptr = m2
		    
		    var lastByte as integer = max( m1.Size, m2.Size ) - 1
		    for b as integer = 0 to lastByte
		      if b >= m1.Size or b >= m2.Size or p1.Byte( b ) <> p2.Byte( b ) then
		        Assert.Message "Mismatch at byte " + b.ToString
		        exit
		      end if
		    next
		  else
		    Assert.Pass
		  end if
		  
		  decompressor = new ZstdStreamDecompressor_MTC
		  
		  try
		    StartTestTimer "decompress cli"
		    for pos as integer = 0 to compressedByCLI.Bytes step chunkSize
		      decompressor.Write compressedByCLI.MiddleBytes( pos, chunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decompress cli"
		    Assert.Pass "Decompressed compressedByCLI"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		  decompressed = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreEqual s.Bytes, decompressed.Bytes, "decompressed cli byte count doesn't match"
		  if StrComp( decompressed, s, 0 ) <> 0 then
		    Assert.Fail "decompressed cli bytes don't match"
		  else
		    Assert.Pass
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Stream_DataAvailable(sender As M_Compression.ZstdStream)
		  CollectedStream.Add sender.ReadAll
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CollectedStream() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private ThreadCompressor As ZstdStreamCompressor_MTC
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Duration"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FailedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IncludeGroup"
			Visible=false
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
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
			Name="IsRunning"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
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
			Name="NotImplementedCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="PassedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RunTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SkippedTestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StopTestOnFail"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
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
			Name="TestCount"
			Visible=false
			Group="Behavior"
			InitialValue=""
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
