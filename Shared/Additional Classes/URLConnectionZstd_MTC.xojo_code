#tag Class
Protected Class URLConnectionZstd_MTC
Inherits URLConnection
	#tag Event
		Sub ContentReceived(URL As String, HTTPStatus As Integer, content As String)
		  content = MaybeDecompressContent( content )
		  
		  RaiseEvent ContentReceived( URL, HTTPStatus, content )
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub FileReceived(URL As String, HTTPStatus As Integer, file As FolderItem)
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Function MaybeDecompressContent(content As String) As String
		  #if DebugBuild
		    var headersArr() as string 
		    for each headerPair as pair in ResponseHeaders
		      headersArr.Add headerPair.Left + ": " + headerPair.Right
		    next
		    var headers as string = String.FromArray( headersArr, EndOfLine )
		    #pragma unused headers
		  #endif
		  
		  if IsZstdCompressed then
		    var actualContent as string = content.MiddleBytes( 15 )
		    actualContent = actualContent.LeftBytes( actualContent.Bytes - 8 )
		    
		    var c as new Zstd_MTC
		    content = c.Decompress( actualContent )
		  end if
		  
		  return content
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Send(method As String, URL As String, file As FolderItem, timeout As Integer = 60)
		  SetAcceptedEncodings
		  super.Send( method, URL, file, timeout )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Send(method As String, URL As String, timeout As Integer = 60)
		  SetAcceptedEncodings
		  super.Send( method, URL, timeout )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendSync(method As String, URL As String, file As FolderItem, timeout As Integer = 0)
		  SetAcceptedEncodings
		  Super.SendSync( method, URL, file, timeout )
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SendSync(method As String, URL As String, timeout As Integer = 0) As String
		  SetAcceptedEncodings
		  var content as string = super.SendSync( method, URL, timeout )
		  return content
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetAcceptedEncodings()
		  me.RequestHeader( kHeaderAcceptEncoding ) = kAcceptedEncodings
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ContentReceived(URL As String, HTTPStatus As Integer, content As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event FileReceived(URL As String, HTTPStatus As Integer, file As FolderItem)
	#tag EndHook


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  var contentEncoding as string = ResponseHeader( kHeaderContentEncoding )
			  return contentEncoding = kZstdEncoding 
			  
			End Get
		#tag EndGetter
		Private IsZstdCompressed As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = kAcceptedEncodings, Type = String, Dynamic = False, Default = \"zstd;q\x3D1.0\x2C gzip;q\x3D0.9\x2C deflate;q\x3D0.8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderAcceptEncoding, Type = String, Dynamic = False, Default = \"Accept-Encoding", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderContentEncoding, Type = String, Dynamic = False, Default = \"Content-Encoding", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kZstdEncoding, Type = String, Dynamic = False, Default = \"zstd", Scope = Private
	#tag EndConstant


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
			Name="AllowCertificateValidation"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HTTPStatusCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
