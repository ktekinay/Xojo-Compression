#tag Class
Protected Class ZstdTests
Inherits CompressionTestGroup
	#tag Event , Description = 436F6D70726573732074686520676976656E20646174612061742074686520676976656E206C6576656C2E
		Function CompressData(data As String, level As Integer, tag As Variant) As String
		  #pragma unused tag
		  
		  return Z.Compress( data, level )
		  
		End Function
	#tag EndEvent

	#tag Event , Description = 4465636F6D70726573732074686520676976656E20646174612E
		Function DecompressData(data As String, originalSize As Integer, encoding As TextEncoding, tag As Variant) As String
		  #pragma unused originalSize
		  #pragma unused tag
		  
		  return Z.Decompress( data, encoding )
		End Function
	#tag EndEvent

	#tag Event
		Sub Setup()
		  Z = new Zstd_MTC
		  CompressTestLevel = Z.LevelDefault
		  
		End Sub
	#tag EndEvent


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
