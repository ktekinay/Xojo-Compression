#tag Class
Private Class ZstdStructure
	#tag Method, Flags = &h0
		Sub Constructor()
		  MyPtr = RaiseEvent CreateStructure
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  if MyPtr <> nil then
		    var size as UInteger = RaiseEvent Destroy( MyPtr )
		    ZstdMaybeRaiseException size
		    
		    MyPtr = nil
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Attributes( Hidden )  Function Operator_Convert() As Ptr
		  return MyPtr
		  
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 43726561746520616E6420696E697469616C697A652061206E6577207374727563747572652E
		Event CreateStructure() As Ptr
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 54686520636C61737320737472756374757265206E6565647320746F20626520746F726E20646F776E2E
		Event Destroy(p As Ptr) As UInteger
	#tag EndHook


	#tag Property, Flags = &h21
		Private MyPtr As Ptr
	#tag EndProperty


	#tag Structure, Name = ZstdBounds, Flags = &h0, Attributes = \""
		Error As UInteger
		  LowerBound As Int32
		UpperBound As Int32
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
	#tag EndViewBehavior
End Class
#tag EndClass
