#tag Class
Protected Class ZstdTests
Inherits TestGroup
	#tag Event
		Sub Setup()
		  Z = new Zstd_MTC
		  
		  if BigData = "" then
		    var f as FolderItem = SpecialFolder.Resource( "json_test.txt.zst" )
		    var tis as TextInputStream = TextInputStream.Open( f )
		    var compressed as string = tis.ReadAll
		    tis.Close
		    tis = nil
		    
		    var z as new Zstd_MTC
		    BigData = z.Decompress( compressed, Encodings.UTF8 )
		  end if
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub CompressTest()
		  var s as string = BigData
		  
		  Assert.Message "s.Bytes = " + s.Bytes.ToString
		  var compressed as string 
		  for i as integer = 1 to 2
		    self.StartTestTimer( "compress" )
		    compressed = Z.Compress( s )
		    self.LogTestTimer( "compress" )
		  next i
		  Assert.Message "compressed.Bytes = " + compressed.Bytes.ToString
		  var ratio as double = 100.0 - ( ( compressed.Bytes / s.Bytes ) * 100.0 )
		  Assert.Message "compression = " + ratio.ToString
		  
		  var decompressed as string
		  for i as integer = 1 to 2
		    self.StartTestTimer( "decompress" )
		    decompressed = Z.Decompress( compressed, s.Encoding )
		    self.LogTestTimer( "decompress" )
		  next i
		  
		  Assert.AreSame s, decompressed
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ErrorTest()
		  var s as string = "something"
		  
		  #pragma BreakOnExceptions false
		  try
		    call Z.Decompress( s )
		    Assert.Fail "Did not raise an exception"
		  catch err as RuntimeException
		    Assert.Pass
		  end try
		  #pragma BreakOnExceptions default
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub VersionTest()
		  var v as UInteger = Z.Version
		  Assert.IsTrue v <> 0
		  Assert.Message v.ToString
		  
		  var s as string = Z.VersionString
		  Assert.AreNotEqual "", s
		  Assert.Message s
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Shared BigData As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Z As Zstd_MTC
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
