#tag Class
Private Class ZstdStreamBase
Inherits ZstdBase
Implements Readable, Writeable
	#tag Method, Flags = &h1
		Protected Sub AddToDataBuffer(s As String)
		  if s <> "" then
		    DataBuffer.Add s
		    DataBufferBytes = DataBufferBytes + s.Bytes
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub ClearDataBuffer()
		  DataBuffer.RemoveAll
		  DataBufferBytes = 0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function EndOfFile() As Boolean
		  // Part of the Readable interface.
		  
		  return IsEndOfFile
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function EOF() As Boolean
		  // Part of the Readable interface.
		  
		  return EndOfFile
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Flush()
		  // Part of the Writeable interface.
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub FlushBuffer(ByRef outBuffer As ZstdBuffer)
		  if outBuffer.Pos <> 0 then
		    AddToDataBuffer OutBufferData.StringValue( 0, outBuffer.Pos )
		    outBuffer.Pos = 0
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function GetDataBuffer() As String
		  if DataBuffer.Count = 1 then
		    return DataBuffer( 0 )
		    
		  elseif DataBuffer.Count = 0 then
		    return ""
		    
		  else
		    var buffer as string = String.FromArray( DataBuffer, "" )
		    DataBuffer.ResizeTo 0
		    DataBuffer( 0 ) = buffer
		    
		    return buffer
		    
		  end if
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub RaiseDataAvailable()
		  RaiseEvent DataAvailable
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Read(count As Integer, encoding As TextEncoding = Nil) As String
		  // Part of the Readable interface.
		  
		  var returnValue as string 
		  
		  if count > 0 then
		    var current as string = GetDataBuffer
		    ClearDataBuffer
		    
		    if count >= current.Bytes then
		      returnValue = current
		      current = ""
		    else
		      returnValue = current.MiddleBytes( 0, count )
		      current = current.MiddleBytes( count )
		    end if
		    
		    AddToDataBuffer current
		    
		    if encoding <> nil then
		      returnValue = returnValue.DefineEncoding( encoding )
		    end if
		  end if
		  
		  return returnValue
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ReadAll(encoding As TextEncoding = Nil) As String
		  return Read( DataBufferBytes, encoding )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function ReadError() As Boolean
		  // Part of the Readable interface.
		  
		  return false
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Reset()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(src As String)
		  // Part of the Writeable interface.
		  
		  #pragma unused src
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21, CompatibilityFlags = (TargetConsole and (Target32Bit or Target64Bit)) or  (TargetWeb and (Target32Bit or Target64Bit)) or  (TargetDesktop and (Target32Bit or Target64Bit))
		Private Function WriteError() As Boolean
		  // Part of the Writeable interface.
		  
		  return false
		  
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event DataAvailable()
	#tag EndHook


	#tag Property, Flags = &h1
		Protected DataBuffer() As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DataBufferBytes As Integer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DataRemaining As UInteger
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected InBuffer As ZstdBuffer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected InBufferData As MemoryBlock
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return DataBufferBytes <> 0
			  
			End Get
		#tag EndGetter
		IsDataAvailable As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h1
		Protected IsEndOfFile As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected OutBuffer As ZstdBuffer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected OutBufferData As MemoryBlock
	#tag EndProperty


	#tag Structure, Name = ZstdBuffer, Flags = &h1
		Data As Ptr
		  DataSize As UInteger
		Pos As UInteger
	#tag EndStructure


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
			Name="IsDataAvailable"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
