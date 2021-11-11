#tag Class
Protected Class AdditionalClassesTests
Inherits TestGroup
	#tag Method, Flags = &h0
		Sub URLConnectionZstdTest()
		  const kUrl as string = "https://api.daniel.priv.no/http-tests/encodings/zstd/decompress"
		  
		  var socket as new URLConnectionZstd_MTC
		  var received as string = socket.SendSync( "GET", kUrl, 10 )
		  
		  return
		End Sub
	#tag EndMethod


End Class
#tag EndClass
