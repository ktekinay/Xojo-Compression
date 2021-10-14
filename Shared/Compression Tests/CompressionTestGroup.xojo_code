#tag Class
Protected Class CompressionTestGroup
Inherits TestGroup
	#tag Event
		Sub Setup()
		  if BigData = "" then
		    var f as FolderItem = SpecialFolder.Resource( "json_test.txt.zst" )
		    var tis as TextInputStream = TextInputStream.Open( f )
		    var compressed as string = tis.ReadAll
		    tis.Close
		    tis = nil
		    
		    var z as new Zstd_MTC
		    mBigData = z.Decompress( compressed, Encodings.UTF8 )
		  end if
		  
		  RaiseEvent Setup
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h1
		Protected Function Compress(data As String, level As Integer, tag As Variant = Nil) As String
		  StartTestTimer "compress"
		  var compressed as string = RaiseEvent CompressData( data, level, tag )
		  LogTestTimer "compress"
		  
		  return compressed
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressDefaultTest()
		  DoCompress CompressTestLevel
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub CompressFastTest()
		  DoCompress 1
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function Decompress(data As String, originalSize As Integer, encoding As TextEncoding = Nil, tag As Variant = Nil) As String
		  StartTestTimer "decompressed"
		  var decompressed as string = RaiseEvent DecompressData( data, originalSize, encoding, tag )
		  LogTestTimer "decompressed"
		  
		  return decompressed
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DoCompress(level As Integer)
		  const kFormat as string = "#,##0"
		  
		  var s as string = BigData
		  var sBytes as integer = s.Bytes
		  
		  Assert.Message "s.Bytes = " + sBytes.ToString( kFormat )
		  Assert.Message "Compression Level = " + level.ToString
		  
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


	#tag Hook, Flags = &h0, Description = 436F6D70726573732074686520676976656E20646174612061742074686520676976656E206C6576656C2E
		Event CompressData(data As String, level As Integer, tag As Variant) As String
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 4465636F6D70726573732074686520676976656E20646174612E
		Event DecompressData(data As String, originalSize As Integer, encoding As TextEncoding, tag As Variant) As String
	#tag EndHook

	#tag Hook, Flags = &h0
		Event Setup()
	#tag EndHook


	#tag ComputedProperty, Flags = &h1
		#tag Getter
			Get
			  Return mBigData
			End Get
		#tag EndGetter
		Protected Shared BigData As String
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected CompressTestLevel As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Attributes( Hidden ) Private Shared mBigData As String
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
