#tag Class
Protected Class ZlibTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub CompressTest()
		  var z as new Zlib_MTC
		  var data as string = CompressionTestGroup.BigData
		  
		  var compressed as string = z.Compress2( data, z.LevelFast )
		  var decompressed as string = z.Uncompress( compressed, data.Bytes, data.Encoding )
		  
		  Assert.AreSame data, decompressed
		End Sub
	#tag EndMethod


End Class
#tag EndClass
