#tag Class
Private Class CCTX
Inherits M_ZSTD.ZstdStructure
	#tag Event , Description = 43726561746520616E6420696E697469616C697A652061206E6577207374727563747572652E
		Function CreateStructure() As Ptr
		  declare function ZSTD_createCCtx lib kLib () as ptr
		  return ZSTD_createCCtx
		  
		End Function
	#tag EndEvent

	#tag Event , Description = 54686520636C61737320737472756374757265206E6565647320746F20626520746F726E20646F776E2E
		Function Destroy(p As Ptr) As UInteger
		  declare function ZSTD_freeCCtx lib kLib ( cctx as ptr ) as UInteger
		  return ZSTD_freeCCtx( p )
		  
		End Function
	#tag EndEvent


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
