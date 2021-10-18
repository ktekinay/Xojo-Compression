#tag Class
Class SimpleZlib_MTC
Inherits M_Compression.Zlib_MTC
Implements M_Compression.Compressor_MTC
	#tag Method, Flags = &h0
		Function Compress(src As MemoryBlock, compressionLevel As Integer = kLevelDefault) As String
		  //
		  // Adds a header to the data
		  //
		  var destSize as UInteger = super.CompressBound( src.Size )
		  var dest as new MemoryBlock( destSize + kHeaderBytes )
		  super.CompressToMemoryBlock( src, dest, destSize, kHeaderBytes, compressionLevel )
		  
		  dest.LittleEndian = true
		  
		  dest.Byte( 0 ) = AscB( "S" ) + 127
		  dest.Byte( 1 ) = AscB( "c" ) + 127
		  dest.UInt32Value( 2 ) = src.Size
		  
		  dest.LittleEndian = TargetLittleEndian
		  
		  return dest.StringValue( 0, destSize + kHeaderBytes )
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Decompress(src As MemoryBlock, encoding As TextEncoding = Nil) As String
		  //
		  // Check the header
		  //
		  if src.Size < kHeaderBytes then
		    RaiseException "Data is too small"
		  elseif src.Byte( 0 ) <> ( AscB( "S" ) + 127 ) or src.Byte( 1 ) <> ( AscB( "c" ) + 127 ) then
		    RaiseException "Incorrect header"
		  end if
		  
		  var origLittleEndian as boolean = src.LittleEndian
		  src.LittleEndian = true
		  var originalSize as integer = src.UInt32Value( 2 )
		  src.LittleEndian = origLittleEndian
		  
		  var srcPtr as ptr = src
		  srcPtr = ptr( integer( srcPtr ) + kHeaderBytes )
		  var srcSize as integer = src.Size - kHeaderBytes
		  
		  var decompressed as string = super.Uncompress( srcPtr, srcSize, originalSize, encoding )
		  return decompressed
		  
		  
		End Function
	#tag EndMethod


	#tag Constant, Name = kHeaderBytes, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant


End Class
#tag EndClass
