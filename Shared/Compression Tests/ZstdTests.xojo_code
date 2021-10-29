#tag Class
Protected Class ZstdTests
Inherits CompressionTestGroup
	#tag Event , Description = 436F6D70726573732074686520676976656E20646174612061742074686520676976656E206C6576656C2E
		Function CompressData(data As String, level As Integer, tag As Variant) As String
		  #pragma unused tag
		  
		  return Compressor.Compress( data, level )
		  
		End Function
	#tag EndEvent

	#tag Event , Description = 4465636F6D70726573732074686520676976656E20646174612E
		Function DecompressData(data As String, originalSize As Integer, encoding As TextEncoding, tag As Variant) As String
		  #pragma unused originalSize
		  #pragma unused tag
		  
		  return Compressor.Decompress( data, encoding )
		End Function
	#tag EndEvent

	#tag Event
		Function GetCompressor() As Compressor_MTC
		  return new Zstd_MTC
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub Setup()
		  CompressTestLevel = Zstd_MTC.LevelDefault
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub ErrorTest()
		  var s as string = "something"
		  
		  #pragma BreakOnExceptions false
		  try
		    call Compressor.Decompress( s )
		    Assert.Fail "Did not raise an exception"
		  catch err as CompressionException_MTC
		    Assert.Pass
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub MultipleCoreTest()
		  const kFormat as string = "#,##0"
		  const kCores as integer = 4
		  
		  var s as string = BigData
		  var sBytes as integer = s.Bytes
		  var level as integer = Zstd_MTC.LevelDefault
		  
		  Assert.Message "s.Bytes = " + sBytes.ToString( kFormat )
		  Assert.Message "Compression Level = " + level.ToString
		  Assert.Message "Cores = " + kCores.ToString
		  
		  Zstd_MTC( Compressor ).Cores = kCores
		  
		  var compressed as string 
		  for i as integer = 1 to 2
		    compressed = Compress( s, level )
		  next i
		  Assert.Message "compressed.Bytes = " + compressed.Bytes.ToString( kFormat )
		  var ratio as double = 100.0 - ( ( compressed.Bytes / s.Bytes ) * 100.0 )
		  Assert.Message "compression = " + ratio.ToString + "%"
		  
		  var decompressed as string
		  for i as integer = 1 to 2
		    decompressed = Decompress( compressed, s.Bytes, s.Encoding )
		  next i
		  
		  Assert.AreSame s, decompressed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VersionTest()
		  var v as UInteger = Zstd_MTC.Version
		  Assert.IsTrue v <> 0
		  Assert.Message v.ToString
		  
		  var s as string = Zstd_MTC.VersionString
		  Assert.AreNotEqual "", s
		  Assert.Message s
		  
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
