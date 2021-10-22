#tag Class
Protected Class ZstdStream
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

	#tag Method, Flags = &h21
		Private Sub ConfirmWriteThreadId()
		  var currentThreadID as integer = CurrentThreadID
		  
		  if WriteThreadID = currentThreadID then
		    //
		    // All good
		    //
		    
		  elseif WriteThreadID = kThreadIdNone then
		    //
		    // Let's store it
		    //
		    WriteThreadID = currentThreadID
		    
		  else
		    RaiseException "Cannot use the same object in different thread concurrently"
		    
		  end if
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Destructor()
		  if DataAvailableTimer isa object then
		    DataAvailableTimer.RunMode = Timer.RunModes.Off
		    RemoveHandler DataAvailableTimer.Action, WeakAddressOf RaiseDataAvailable
		    DataAvailableTimer = nil
		  end if
		  
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
		  
		  ConfirmWriteThreadId
		  
		  var startingDataBufferBytes as integer = DataBufferBytes
		  
		  FlushBuffer OutBuffer
		  RaiseEvent DoFlush
		  FlushBuffer OutBuffer
		  
		  if DataBufferBytes <> startingDataBufferBytes then
		    RaiseDataAvailable
		  end if
		  
		  Reset
		  
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
		Protected Sub RaiseDataAvailable(sender As Timer = Nil)
		  //
		  // Might be called directly or as part of the Timer
		  //
		  #pragma unused sender
		  
		  if IsDataAvailable then
		    
		    if CurrentThreadID = kThreadIdMain then
		      RaiseEvent DataAvailable
		      
		    else
		      //
		      // Start the timer
		      //
		      if DataAvailableTimer.RunMode = Timer.RunModes.Off then
		        DataAvailableTimer.RunMode = Timer.RunModes.Single
		      end if
		    end if
		    
		  end if
		  
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

	#tag Method, Flags = &h1
		Protected Sub Reset()
		  RaiseEvent DoReset
		  
		  InBuffer.Data = InBufferData
		  InBuffer.VirtualSize = 0
		  InBuffer.Pos = 0
		  
		  OutBuffer.Data = OutBufferData
		  OutBuffer.VirtualSize = OutBufferData.Size
		  OutBuffer.Pos = 0
		  
		  IsEndOfFile = true
		  
		  WriteThreadID = kThreadIdNone
		  
		  if DataAvailableTimer is nil then
		    DataAvailableTimer = new Timer
		    DataAvailableTimer.Period = 1
		    AddHandler DataAvailableTimer.Action, WeakAddressOf RaiseDataAvailable
		  end if
		  
		  DataAvailableTimer.RunMode = Timer.RunModes.Off
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Write(src As String)
		  // Part of the Writeable interface.
		  
		  #if not DebugBuild
		    #pragma BoundsChecking false
		    #pragma BreakOnExceptions false
		    #pragma NilObjectChecking false
		    #pragma StackOverflowChecking false
		  #endif
		  
		  ConfirmWriteThreadId
		  
		  if src = "" then
		    //
		    // Nothing to do
		    //
		    return
		  end if
		  
		  IsEndOfFile = false
		  
		  //
		  // We have to split the src into chunks
		  // and consume it all
		  //
		  #if DebugBuild then
		    //
		    // Easier to debug
		    //
		    var inBuffer as ZstdBuffer = self.InBuffer
		    var outBuffer as ZstdBuffer = self.OutBuffer
		    var inBufferData as MemoryBlock = self.InBufferData
		    var outBufferData as MemoryBlock = self.OutBufferData
		    #pragma unused outBufferData
		  #endif
		  
		  var inBufferDataSize as integer = inBufferData.Size
		  
		  var dataRemaining as UInteger
		  var startingDataBufferBytes as integer = DataBufferBytes
		  
		  #if DebugBuild
		    var loopCount as integer // For debugging
		  #endif
		  
		  var srcIndex as integer = 0
		  var srcBytes as integer = src.Bytes
		  
		  do
		    #if DebugBuild
		      if loopCount = 0 then
		        loopCount = loopCount // A place to break
		      end if
		    #endif
		    
		    var inBufferUnusedBytes as integer = inBufferDataSize - inBuffer.VirtualSize
		    var remainingSrcBytes as integer = srcBytes - srcIndex
		    
		    if srcIndex = srcBytes or inBufferUnusedBytes = 0 then
		      //
		      // Do nothing
		      //
		      
		    elseif remainingSrcBytes <= inBufferUnusedBytes then
		      inBufferData.StringValue( inBuffer.VirtualSize, remainingSrcBytes ) = src.MiddleBytes( srcIndex, remainingSrcBytes )
		      inBuffer.VirtualSize = inBuffer.VirtualSize + remainingSrcBytes
		      srcIndex = srcBytes
		      
		    else
		      inBufferData.StringValue( inBuffer.VirtualSize, inBufferUnusedBytes ) = src.MiddleBytes( srcIndex, inBufferUnusedBytes )
		      inBuffer.VirtualSize = inBuffer.VirtualSize + inBufferUnusedBytes
		      srcIndex = srcIndex + inBufferUnusedBytes
		      
		    end if
		    
		    if inBuffer.VirtualSize < inBufferDataSize then
		      //
		      // We will take care of this on the next pass
		      //
		      exit
		    end if
		    
		    RaiseEvent DoWrite( outBuffer, inBuffer, dataRemaining )
		    
		    if inBuffer.Pos = inBuffer.VirtualSize then
		      inBuffer.Pos = 0
		      inBuffer.VirtualSize = 0
		    end if
		    
		    if outBuffer.Pos = outBuffer.VirtualSize then
		      FlushBuffer outBuffer
		    elseif src = "" and inBuffer.Pos = 0 then
		      //
		      // Nothing more to consume
		      //
		      exit
		    end if
		    
		    #if DebugBuild
		      loopCount = loopCount + 1
		    #endif
		  loop
		  
		  #if DebugBuild
		    self.InBuffer = inBuffer
		    self.OutBuffer = outBuffer
		  #endif
		  
		  if DataBufferBytes <> startingDataBufferBytes then
		    RaiseDataAvailable
		  end if
		  
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

	#tag Hook, Flags = &h0
		Event DoFlush()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DoReset()
	#tag EndHook

	#tag Hook, Flags = &h0
		Event DoWrite(ByRef outBuffer As ZstdBuffer, ByRef inBuffer As ZstdBuffer, ByRef dataRemaining As UInteger)
	#tag EndHook


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  var th as Thread = Thread.Current
			  
			  if th is nil then
			    return kThreadIdMain
			  else
			    return th.ThreadID
			  end if
			  
			End Get
		#tag EndGetter
		Private CurrentThreadID As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private DataAvailableTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DataBuffer() As String
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected DataBufferBytes As Integer
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

	#tag Property, Flags = &h21
		Private WriteThreadID As Integer = kThreadIdNone
	#tag EndProperty


	#tag Constant, Name = kThreadIdMain, Type = Double, Dynamic = False, Default = \"-100", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kThreadIdNone, Type = Double, Dynamic = False, Default = \"-10000000", Scope = Private
	#tag EndConstant


	#tag Structure, Name = ZstdBuffer, Flags = &h1
		Data As Ptr
		  VirtualSize As UInteger
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
