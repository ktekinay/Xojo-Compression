#tag Class
Protected Class URLConnectionZstd_MTC
Inherits URLConnection
	#tag Event
		Sub ContentReceived(URL As String, HTTPStatus As Integer, content As String)
		  if not IsSync then
		    content = MaybeDecompressContent( content )
		  end if
		  
		  RaiseEvent ContentReceived( URL, HTTPStatus, content )
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub FileReceived(URL As String, HTTPStatus As Integer, file As FolderItem)
		  if not IsSync then
		    MaybeDecompressFile file
		  end if
		  
		  RaiseEvent FileReceived( URL, HTTPStatus, file )
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(isZstdOnly As Boolean = False)
		  var enc as string = kAcceptedEncodings
		  
		  if isZstdOnly then
		    enc = kZstdEncoding
		  end if
		  
		  me.RequestHeader( kHeaderAcceptEncoding ) = enc
		  
		End Sub
	#tag EndMethod

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
		  
		  var originalContent as string = content
		  
		  if originalContent <> "" and IsZstdCompressed then
		    var c as new Zstd_MTC
		    content = c.Decompress( originalContent, originalContent.Encoding )
		    
		    if content.Encoding is nil and Encodings.UTF8.IsValidData( content ) then
		      content = content.DefineEncoding( Encodings.UTF8 )
		    end if
		  end if
		  
		  return content
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MaybeDecompressFile(ByRef file As FolderItem)
		  if not IsZstdCompressed or _
		    file is nil or not file.Exists or _
		    file.IsFolder or _
		    not file.IsReadable or not file.IsWriteable then
		    //
		    // Nothing to do
		    //
		    return
		  end if
		  
		  //
		  // Let's try to decompress it
		  //
		  var out as FolderItem = FolderItem.TemporaryFile
		  var bs as BinaryStream = BinaryStream.Create( out, true )
		  var raiseErr as RuntimeException
		  
		  try
		    var d as new ZstdStreamDecompressor_MTC
		    
		    var targetChunkSize as integer = ( 1024 * 1024 * 2 ) + d.RecommendedChunkSize
		    var chunkSize as integer = targetChunkSize - ( targetChunkSize mod d.RecommendedChunkSize )
		    
		    while not bs.EndOfFile
		      var chunk as string = bs.Read( chunkSize )
		      d.Write chunk
		      
		      chunk = d.ReadAll
		      bs.Write chunk
		    wend
		    
		    d.Flush
		    var chunk as string = d.ReadAll
		    bs.Write chunk
		    
		    bs.Close
		    bs = nil
		    
		    //
		    // Move the temp file to the original
		    //
		    var targetFile as new FolderItem( file )
		    
		    var baseName as string = targetFile.Name + ".original"
		    var newName as string = baseName
		    var indexer as integer
		    
		    var targetParent as FolderItem = targetFile.Parent
		    
		    while targetParent.Child( newName ).Exists
		      indexer = indexer + 1
		      newName = baseName + indexer.ToString
		    wend
		    
		    file.Name = newName
		    do
		      file = new FolderItem( targetParent.Child( newName ) )
		    loop until file.Exists // Just in case we need the OS to catch up
		    
		    out.MoveTo targetFile
		    file.Delete
		    
		    out = nil
		    file = targetFile
		    
		  catch err as CompressionException_MTC
		    //
		    // Didn't work so we will just return the original file
		    //
		    
		  catch err as RuntimeException
		    raiseErr = err // Raise this below after cleanup
		    
		  end try
		  
		  
		  Cleanup:
		  
		  if out isa object and out.Exists and out.NativePath <> file.NativePath then
		    if bs isa object then
		      bs.Close
		      bs = nil
		    end if
		    
		    out.Delete
		    out = nil
		  end if
		  
		  if raiseErr isa object then
		    raise raiseErr
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SendSync(method As String, URL As String, file As FolderItem, timeout As Integer = 0)
		  IsSync = true
		  
		  super.SendSync( method, URL, file, timeout )
		  MaybeDecompressFile file
		  
		  IsSync = false
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SendSync(method As String, URL As String, timeout As Integer = 0) As String
		  IsSync = true
		  
		  var content as string = super.SendSync( method, URL, timeout )
		  content = MaybeDecompressContent( content )
		  
		  IsSync = false
		  
		  return content
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event ContentReceived(URL As String, HTTPStatus As Integer, content As String)
	#tag EndHook

	#tag Hook, Flags = &h0
		Event FileReceived(URL As String, HTTPStatus As Integer, file As FolderItem)
	#tag EndHook


	#tag Property, Flags = &h21
		Private IsSync As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  var contentEncoding as string = ResponseHeader( kHeaderContentEncoding )
			  return contentEncoding = kZstdEncoding
			  
			End Get
		#tag EndGetter
		Private IsZstdCompressed As Boolean
	#tag EndComputedProperty


	#tag Constant, Name = kAcceptedEncodings, Type = String, Dynamic = False, Default = \"zstd\x2C gzip\x2C deflate", Scope = Private
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
