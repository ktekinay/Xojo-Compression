#tag Module
Protected Module M_ZSTD
	#tag Method, Flags = &h21
		Private Function GetErrorName(code As UInteger) As String
		  declare function ZSTD_getErrorName lib kLib ( code as UInteger ) as CString
		  return ZSTD_getErrorName( code )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsError(code As UInteger) As Boolean
		  declare function ZSTD_isError lib kLib ( code as UInteger ) as UInteger
		  var result as UInteger = ZSTD_isError( code )
		  
		  const kZero as UInteger = 0
		  return result <> kZero
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MaybeRaiseException(code As UInteger, useMessage As String = "")
		  if IsError( code ) then
		    var msg as string = useMessage
		    if msg = "" then
		      msg = GetErrorName( code )
		    end if
		    
		    RaiseException msg
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RaiseException(msg As String)
		  var err as new RuntimeException
		  err.Message = msg
		  raise err
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = kLib, Type = String, Dynamic = False, Default = \"libzstd.dylib", Scope = Protected
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
	#tag EndViewBehavior
End Module
#tag EndModule
