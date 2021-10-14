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


End Class
#tag EndClass
