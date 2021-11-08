#tag Class
Protected Class CompressionTestGroup
Inherits TestGroup
	#tag Method, Flags = &h1
		Protected Function Compress(withCompressor As Compressor_MTC, data As String) As String
		  StartTestTimer "compress"
		  var compressed as string = withCompressor.Compress( data )
		  LogTestTimer "compress"
		  
		  return compressed
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressCompressedTest()
		  var f as FolderItem = SpecialFolder.Resource( "json_test.txt.zst" )
		  
		  var bs as BinaryStream = BinaryStream.Open( f )
		  var fileLength as integer = bs.Length
		  var contents as string = bs.Read( fileLength )
		  bs.Close
		  
		  var compressor as Compressor_MTC = Compressor( 1 )
		  
		  StartTestTimer "compress"
		  var compressed as string = compressor.Compress( contents )
		  LogTestTimer "compress"
		  
		  StartTestTimer "decompress"
		  var decompressed as string = compressor.Decompress( compressed )
		  LogTestTimer "decompress"
		  
		  Assert.AreSame contents, decompressed
		  Assert.Message "Original size = " + contents.Bytes.ToString( "#,##0" ) + " bytes"
		  Assert.Message "Compressed size = " + compressed.Bytes.ToString( "#,##0" ) + " bytes"
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressDefaultTest()
		  DoCompress kLevelDefault
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressFastTest()
		  DoCompress 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Compressor(compressionLevel As Integer = -999999) As Compressor_MTC
		  var c as Compressor_MTC = RaiseEvent GetCompressor( compressionLevel )
		  return c
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressTinyTest()
		  var s as string = "a"
		  Assert.Message "s = " + s
		  
		  var compressor as Compressor_MTC = self.Compressor( 1 )
		  
		  var compressed as string = Compress( compressor, s )
		  Assert.Message "compressed.Bytes = " + compressed.Bytes.ToString
		  
		  var decompressed as string = Decompress( compressor, compressed, Encodings.UTF8 )
		  
		  Assert.AreSame s, decompressed
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CorruptedDataTest()
		  var s as string = Crypto.GenerateRandomBytes( 20 )
		  
		  #pragma BreakOnExceptions false
		  try
		    call Decompress( Compressor, s )
		    Assert.Fail "Should have generated exception"
		  catch err as CompressionException_MTC
		    Assert.Pass
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Decompress(withCompressor As Compressor_MTC, data As String, encoding As TextEncoding = Nil) As String
		  StartTestTimer "decompressed"
		  var decompressed as string = withCompressor.Decompress( data, encoding )
		  LogTestTimer "decompressed"
		  
		  return decompressed
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoCompress(level As Integer)
		  const kFormat as string = "#,##0"
		  
		  var s as string = BigData
		  var sBytes as integer = s.Bytes
		  
		  var compressor as Compressor_MTC = Compressor( level )
		  
		  Assert.Message "s.Bytes = " + sBytes.ToString( kFormat )
		  Assert.Message "Compression Level = " + if( level = kLevelDefault, "default", level.ToString )
		  
		  var compressed as string 
		  for i as integer = 1 to 2
		    compressed = Compress( compressor, s )
		  next i
		  Assert.Message "compressed.Bytes = " + compressed.Bytes.ToString( kFormat )
		  var ratio as double = 100.0 - ( ( compressed.Bytes / s.Bytes ) * 100.0 )
		  Assert.Message "compression = " + ratio.ToString + "%"
		  
		  var decompressed as string
		  for i as integer = 1 to 2
		    decompressed = Decompress( compressor, compressed, s.Encoding )
		  next i
		  
		  Assert.AreSame s, decompressed
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event GetCompressor(compressionLevel As Integer) As Compressor_MTC
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  if mBigData = "" then
			    var f as FolderItem = SpecialFolder.Resource( "json_test.txt.zst" )
			    var tis as TextInputStream = TextInputStream.Open( f )
			    var compressed as string = tis.ReadAll
			    tis.Close
			    tis = nil
			    
			    var z as new Zstd_MTC
			    mBigData = z.Decompress( compressed, Encodings.UTF8 )
			  end if
			  
			  return mBigData
			End Get
		#tag EndGetter
		Shared BigData As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Attributes( Hidden ) Private Shared mBigData As String
	#tag EndProperty


	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"-999999", Scope = Protected
	#tag EndConstant


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
