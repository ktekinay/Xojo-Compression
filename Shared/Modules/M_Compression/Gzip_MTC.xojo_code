#tag Class
Class Gzip_MTC
Implements M_Compression.Compressor_MTC
	#tag Method, Flags = &h0
		Function Compress(src As MemoryBlock, compressionLevel As Integer = kLevelDefault) As String
		  if compressionLevel = kLevelDefault then
		    compressionLevel = DefaultLevel
		  end if
		  
		  var destSize as UInteger = CompressBound( src.Size )
		  var dest as new MemoryBlock( destSize + kHeaderBytes + kFooterBytes )
		  dest.LittleEndian = true
		  
		  declare function compress2 lib kLibZlib ( _
		  dest as ptr, ByRef destSize as UInteger, _
		  source as ptr, sourceLen as UInteger, _
		  level as integer _
		  ) as integer
		  
		  var destPtr as ptr = dest
		  //
		  // Advance past header
		  //
		  destPtr = ptr( integer( destPtr ) + kHeaderBytes )
		  var result as integer = compress2( destPtr, destSize, src, src.Size, compressionLevel )
		  MaybeRaiseException result
		  
		  //
		  // No error, so let's fill in the header and footer
		  //
		  destPtr = dest // Reset this
		  var magicNumber as string = GetMagicNumber
		  dest.StringValue( 0, magicNumber.Bytes ) = magicNumber
		  destPtr.Byte( 2 ) = 8
		  dest.UInt32Value( 4 ) = DateTime.Now.SecondsFrom1970
		  
		  #if TargetMacOS then
		    destPtr.Byte( 9 ) = 7
		  #elseif TargetWindows then
		    destPtr.Byte( 9 ) = 0
		  #elseif TargetLinux then
		    destPtr.Byte( 9 ) = 3
		  #else
		    destPtr.Byte( 9 ) = 255
		  #endif
		  
		  var footerStartPos as integer = kHeaderBytes + destSize
		  var crc as MemoryBlock = Crypto.Hash( src, Crypto.HashAlgorithms.CRC32 )
		  
		  dest.UInt32Value( footerStartPos ) = crc.UInt32Value( 0 )
		  dest.UInt32Value( footerStartPos + 4 ) = src.Size
		  return dest.StringValue( 0, kHeaderBytes + destSize + kFooterBytes )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CompressBound(size As UInteger) As UInteger
		  declare function compressBound lib kLibZlib ( size as UInteger ) as UInteger
		  return compressBound( size )
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(defaultLevel As Integer = kLevelDefault)
		  self.DefaultLevel = defaultLevel
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Decompress(src As MemoryBlock, encoding As TextEncoding = Nil) As String
		  if src.Size < ( kHeaderBytes + kFooterBytes + 9 ) then
		    RaiseException "Data is too small"
		  elseif StrComp( src.StringValue( 0, 2 ), GetMagicNumber, 0 ) <> 0 then
		    RaiseException "Bad header"
		  end if
		  
		  src.LittleEndian = true
		  
		  //
		  // Get the file flags
		  //
		  var dataStartPos as integer = kHeaderBytes
		  var fileFlag as integer = src.Byte( 3 )
		  var hasHeaderCrc as boolean = ( fileFlag and &b10 ) <> 0
		  var hasExtraFields as boolean = ( fileFlag and &b100 ) <> 0
		  var hasFilename as boolean = ( fileFlag and &b1000 ) <> 0
		  var hasComment as boolean = ( fileFlag and &b10000 ) <> 0
		  
		  //
		  // Check each in order
		  //
		  if hasExtraFields then
		    var extraFieldLen as integer = src.UInt16Value( dataStartPos )
		    dataStartPos = dataStartPos + extraFieldLen
		  end if
		  
		  if hasFilename then
		    var fileName as string = src.CString( dataStartPos )
		    dataStartPos = dataStartPos + fileName.Bytes + 1
		  end if
		  
		  if hasComment then
		    var comment as string = src.CString( dataStartPos )
		    dataStartPos = dataStartPos + comment.Bytes + 1
		  end if
		  
		  if hasHeaderCrc then
		    dataStartPos = dataStartPos + 2
		  end if
		  
		  //
		  // Get data from the footer
		  //
		  var destSize as UInteger = src.UInt32Value( src.Size - 4 )
		  var expectedCrc as UInt32 = src.UInt32Value( src.Size - 8 )
		  
		  var dest as new MemoryBlock( destSize )
		  
		  var dataSize as UInteger = src.Size - dataStartPos - kFooterBytes
		  
		  declare function uncompress lib kLibZlib ( dest as ptr, ByRef destSize as UInteger, src as ptr, sourceLen as UInteger ) as integer
		  
		  var startPtr as ptr = src
		  startPtr = ptr( integer( startPtr ) + dataStartPos )
		  
		  var result as integer = uncompress( dest, destSize, startPtr, dataSize )
		  MaybeRaiseException result
		  
		  if dest.Size <> destSize then
		    dest.Size = destSize
		  end if
		  
		  var actualCrc as MemoryBlock = Crypto.Hash( dest, Crypto.HashAlgorithms.CRC32 )
		  
		  if actualCrc.UInt32Value( 0 ) <> expectedCrc then
		    RaiseException "Data appears to be corrupted"
		  end if
		  
		  return dest.StringValue( 0, destSize, encoding )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetMagicNumber() As String
		  return ChrB( &h1f ) + ChrB( &h8b )
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Shared Sub MaybeRaiseException(result As Integer, msg As String = "")
		  
		  select case result
		  case Z_MEM_ERROR
		    if msg = "" then
		      msg = "Not enough memory"
		    end if
		    
		  case Z_BUF_ERROR
		    if msg = "" then
		      msg = "Not enough room in the output buffer"
		    end if
		    
		  case else
		    msg = ""
		    
		  end select
		  
		  if msg <> "" then
		    RaiseException msg
		  end if
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private DefaultLevel As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return kLevelDefault
			End Get
		#tag EndGetter
		Shared LevelDefault As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return kLevelFast
			  
			End Get
		#tag EndGetter
		Shared LevelFast As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  return kLevelMax
			End Get
		#tag EndGetter
		Shared LevelMax As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  declare function zlibVersion lib kLibZlib () as CString
			  
			  return zlibVersion()
			  
			  
			End Get
		#tag EndGetter
		Shared Version As String
	#tag EndComputedProperty


	#tag Constant, Name = kFooterBytes, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHeaderBytes, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLevelDefault, Type = Double, Dynamic = False, Default = \"-1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLevelFast, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLevelMax, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_BUF_ERROR, Type = Double, Dynamic = False, Default = \"-5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = Z_MEM_ERROR, Type = Double, Dynamic = False, Default = \"-4", Scope = Private
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
End Class
#tag EndClass
