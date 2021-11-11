#tag Class
Protected Class URLConnectionZstdTests
Inherits TestGroup
	#tag Event
		Sub TearDown()
		  if Connector isa object then
		    RemoveHandler Connector.ContentReceived, WeakAddressOf Connector_ContentReceived
		    Connector = nil
		  end if
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub Connector_ContentReceived(sender As URLConnectionZstd_MTC, URL As String, HTTPStatus As Integer, content As String)
		  Assert.Message content
		  Assert.Pass
		  
		  AsyncComplete
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CreateConnector()
		  if Connector is nil then
		    Connector = new URLConnectionZstd_MTC( true )
		    AddHandler Connector.ContentReceived, WeakAddressOf Connector_ContentReceived
		  end if
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendSyncTest()
		  var socket as new URLConnectionZstd_MTC( true )
		  
		  var received as string = socket.SendSync( "GET", kUrl, 10 )
		  
		  Assert.Message received
		  Assert.Pass
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendTest()
		  CreateConnector
		  
		  Connector.Send( "GET", kUrl, 10 )
		  AsyncAwait 10
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub StandardContentTest()
		  var socket as new URLConnectionZstd_MTC
		  var content as string = socket.SendSync( "GET", "https://www.google.com", 10 )
		  Assert.IsTrue content.IndexOf( "<head>" ) <> -1
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Connector As URLConnectionZstd_MTC
	#tag EndProperty


	#tag Constant, Name = kURL, Type = String, Dynamic = False, Default = \"https://api.daniel.priv.no/http-tests/encodings/zstd/decompress", Scope = Private
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
		#tag ViewProperty
			Name="Connector"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
