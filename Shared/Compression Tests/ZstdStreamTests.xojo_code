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
		  catch err as CompressionException_MTC
		    Assert.Pass 
		  end try
		  #pragma BreakOnExceptions default
		  
		  AsyncComplete
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ConsecutiveFlushTest()
		  var compressor as new ZstdStreamCompressor_MTC
		  compressor.Flush
		  Assert.Pass "Compressor flush before use"
		  
		  compressor.Write "ABC"
		  compressor.Flush
		  compressor.Flush
		  Assert.Pass "Compresser flush twice before ReadAll"
		  
		  var compressed as string = compressor.ReadAll
		  compressor.Flush
		  Assert.AreEqual "", compressor.ReadAll, "Compressor should have been empty after flush"
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  decompressor.Flush
		  Assert.Pass "Decompressor flush before use"
		  
		  decompressor.Write compressed
		  decompressor.Flush
		  decompressor.Flush
		  Assert.Pass "Decompressor flush twice before ReadAll"
		  
		  var decompressed as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreSame "ABC", decompressed
		  
		  decompressor.Flush
		  Assert.AreEqual "", decompressor.ReadAll, "Decompressor should have been empty after flush"
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DataAvailableEventThroughThreadTest()
		  StreamThread = new Thread
		  AddHandler StreamThread.Run, WeakAddressOf StreamThread_Run
		  
		  StreamThread.Start
		  AsyncAwait 5
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PartialStreamTest()
		  var compressor as new ZstdStreamCompressor_MTC
		  compressor.Write "ABC"
		  compressor.Flush
		  var compressed1 as string = compressor.ReadAll
		  
		  compressor.Write "123"
		  compressor.Flush
		  var compressed2 as string = compressor.ReadAll
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  decompressor.Write compressed1 + compressed2
		  decompressor.Flush
		  var actual as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreSame "ABC123", actual, "Combined does not match"
		  
		  var stages() as string
		  decompressor.Write compressed1.LeftBytes( compressed1.Bytes - 6 )
		  stages.Add decompressor.ReadAll( Encodings.UTF8 )
		  
		  decompressor.Write compressed1.RightBytes( 6 ) + compressed2.LeftBytes( compressed2.Bytes - 7 )
		  stages.Add decompressor.ReadAll( Encodings.UTF8 )
		  
		  decompressor.Write compressed2.RightBytes( 7 )
		  stages.Add decompressor.ReadAll( Encodings.UTF8 )
		  
		  decompressor.Flush
		  stages.Add decompressor.ReadAll( Encodings.UTF8 )
		  
		  var final as string = String.FromArray( stages, "" )
		  Assert.AreSame "ABC123", final
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadFrameTest()
		  var compressor as new ZstdStreamCompressor_MTC
		  compressor.Write "ABC"
		  compressor.Flush
		  var compressed as string = compressor.ReadFrame
		  
		  compressor.Write "123"
		  compressor.Flush
		  compressed = compressed + compressor.ReadFrame
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  var frames() as string
		  
		  for i as integer = 0 to compressed.Bytes
		    var char as string = compressed.MiddleBytes( i, 1 )
		    
		    decompressor.Write char
		    var frame as string = decompressor.ReadFrame( Encodings.UTF8 )
		    if frame <> "" then
		      frames.Add frame
		    end if
		  next
		  decompressor.Flush
		  Assert.AreEqual "", decompressor.ReadAll
		  
		  var frameCount as integer = frames.Count
		  Assert.AreEqual 2, frameCount
		  
		  if frameCount = 2 then
		    Assert.AreSame "ABC", frames( 0 )
		    Assert.AreSame "123", frames( 1 )
		  end if
		  
		  frames.RemoveAll
		  for i as integer = 0 to compressed.Bytes
		    var char as string = compressed.MiddleBytes( i, 1 )
		    
		    decompressor.Write char
		  next
		  decompressor.Flush
		  
		  while decompressor.IsFrameAvailable
		    var frame as string = decompressor.ReadFrame( Encodings.UTF8 )
		    frames.Add frame
		  wend
		  
		  frameCount = frames.Count
		  Assert.AreEqual 2, frameCount, "FrameCount is not unexpected"
		  
		  if frameCount = 2 then
		    Assert.AreSame "ABC", frames( 0 )
		    Assert.AreSame "123", frames( 1 )
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadTest()
		  var data as string = "ABC123"
		  
		  var compressor as new ZstdStreamCompressor_MTC
		  compressor.Write data.MiddleBytes( 0, data.Bytes \ 2 )
		  compressor.Flush
		  var compressed as string = compressor.ReadAll
		  
		  compressor.Write data.MiddleBytes( data.Bytes \ 2 )
		  compressor.Flush
		  compressed = compressed + compressor.ReadAll
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  decompressor.Write compressed
		  decompressor.Flush
		  
		  var dataArr() as string = data.SplitBytes( "" )
		  for i as integer = 0 to dataArr.LastRowIndex
		    var readChar as string = decompressor.Read( 1, dataArr( i ).Encoding )
		    Assert.AreSame dataArr( i ), readChar, dataArr( i )
		  next
		  
		  Assert.IsTrue decompressor.EndOfFile
		  Assert.IsFalse decompressor.IsDataAvailable
		  
		  decompressor.Write compressed
		  decompressor.Flush
		  
		  var part as string = decompressor.Read( 2, Encodings.UTF8 )
		  Assert.AreSame data.LeftBytes( 2 ), part, data.LeftBytes( 2 )
		  
		  part = decompressor.ReadFrame( Encodings.UTF8 )
		  Assert.AreSame data.MiddleBytes( 2, 1 ), part, data.MiddleBytes( 2, 1 )
		  
		  part = decompressor.Read( 1, Encodings.UTF8 )
		  Assert.AreSame data.MiddleBytes( 3, 1), part, data.MiddleBytes( 3, 1)
		  
		  part = decompressor.ReadFrame( Encodings.UTF8 )
		  Assert.AreSame data.RightBytes( 2 ), part, data.RightBytes( 2 )
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
		Sub SmallDataTest()
		  var s as string = "abcabc 123123 "
		  s = s + s + s + s
		  
		  Assert.Message "s.Bytes = " + s.Bytes.ToString
		  
		  var compressor as new ZstdStreamCompressor_MTC
		  compressor.Write s
		  compressor.Flush
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  decompressor.Write compressor.ReadAll
		  decompressor.Flush
		  
		  var decompressed as string = decompressor.ReadAll( s.Encoding )
		  Assert.AreSame s, decompressed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StreamThread_Run(sender As Thread)
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  var s as string = CompressionTestGroup.BigData
		  var chunkSize as integer = compressor.RecommendedChunkSize
		  
		  AddHandler compressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  for i as integer = 0 to s.Bytes - 1 step chunkSize
		    compressor.Write s.MiddleBytes( i, chunkSize )
		  next
		  compressor.Flush
		  
		  while not compressor.EndOfFile
		    sender.Sleep 10
		  wend
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
		  
		  while not decompressor.EndOfFile
		    sender.Sleep 10
		  wend
		  RemoveHandler decompressor.DataAvailable, WeakAddressOf Stream_DataAvailable
		  
		  var decompressed as string = String.FromArray( CollectedStream, "" )
		  decompressed = decompressed.DefineEncoding( s.Encoding )
		  
		  Assert.AreSame s, decompressed
		  
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
		    
		  catch err as CompressionException_MTC
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
		    
		  catch err as CompressionException_MTC
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
		    
		  catch err as CompressionException_MTC
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
		    
		  catch err as CompressionException_MTC
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
		Private StreamThread As Thread
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
