#tag Class
Protected Class ZstdStreamTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub StreamTest()
		  var compressedByCLI as string
		  
		  if true then
		    var bs as BinaryStream = BinaryStream.Open( SpecialFolder.Resource( "json_test_stream_level-1.zst" ) )
		    compressedByCLI = bs.Read( bs.Length )
		    bs.Close
		  end if
		  
		  var compressor as new ZstdStreamCompressor_MTC( Zstd_MTC.LevelFast )
		  
		  var s as string = CompressionTestGroup.BigData
		  's = "abcdef"
		  
		  StartTestTimer "encrypting"
		  for pos as integer = 0 to s.Bytes - 1 step compressor.RecommendedChunkSize
		    compressor.Write s.MiddleBytes( pos, compressor.RecommendedChunkSize )
		  next
		  compressor.Flush
		  
		  var encrypted as string = compressor.ReadAll
		  LogTestTimer "encrypting"
		  
		  var decompressor as new ZstdStreamDecompressor_MTC
		  
		  try
		    StartTestTimer "decrypt native"
		    for pos as integer = 0 to encrypted.Bytes step decompressor.RecommendedChunkSize
		      decompressor.Write encrypted.MiddleBytes( pos, decompressor.RecommendedChunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decrypt native"
		    Assert.Pass "Decompressed"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		  var decrypted as string = decompressor.ReadAll( Encodings.UTF8 )
		  Assert.AreEqual s.Bytes, decrypted.Bytes, "Decrypted byte count doesn't match"
		  if StrComp( decrypted, s, 0 ) <> 0 then
		    Assert.Fail "Decrypted bytes don't match"
		  else
		    Assert.Pass
		  end if
		  
		  decompressor = new ZstdStreamDecompressor_MTC
		  
		  try
		    StartTestTimer "decrypt cli"
		    for pos as integer = 0 to compressedByCLI.Bytes step decompressor.RecommendedChunkSize
		      decompressor.Write compressedByCLI.MiddleBytes( pos, decompressor.RecommendedChunkSize )
		    next
		    decompressor.Flush
		    LogTestTimer "decrypt cli"
		    Assert.Pass "Decompressed compressedByCLI"
		    
		  catch err as RuntimeException
		    if err isa EndException or err isa ThreadEndException then
		      raise err
		    end if
		    Assert.Fail err.Message
		    
		  end try
		  
		End Sub
	#tag EndMethod


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
