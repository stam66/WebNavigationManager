#tag Class
Protected Class WebNavigationManager
	#tag Method, Flags = &h0
		Sub Constructor(host As wp_MainShell)
		  mHostPage = host
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LogNavigation(action As String, destination As WebContainer)
		  Var name As String = If(destination IsA wc_Base, wc_Base(destination).ContainerID, "Unknown")
		  System.DebugLog("Navigation: " + action + " → " + name)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NavigateBack()
		  If mHistory.Count > 0 Then
		    If mHostPage.ContentArea <> Nil Then
		      mForward.Add(mHostPage.ContentArea)
		      mHostPage.ContentArea.Visible = False
		    End If
		    
		    Var previousContainer As WebContainer = mHistory.Pop
		    mHostPage.ContentArea = previousContainer
		    
		    // For wc_Base containers, handle embedding properly
		    If previousContainer IsA wc_Base Then
		      Var wc As wc_Base = wc_Base(previousContainer)
		      
		      // Only embed if not already embedded
		      If wc.Parent = Nil Then
		        // Calculate size based on position mode
		        Var embedW, embedH As Integer
		        If wc.Position = wc_Base.PositionEnum.TopLeft Then
		          embedW = mHostPage.Placeholder.Width
		          embedH = mHostPage.Placeholder.Height
		        Else
		          embedW = wc.Width
		          embedH = wc.Height
		        End If
		        
		        // Embed with correct size
		        previousContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, embedW, embedH)
		      End If
		      
		      // Then let EmbedInto do positioning and locking
		      wc.EmbedInto(mHostPage.Placeholder)
		    Else
		      If previousContainer.Parent = Nil Then
		        previousContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		      End If
		    End If
		    
		    previousContainer.Visible = True
		    LogNavigation("NavigateBack", previousContainer)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NavigateForward()
		  If mForward.Count > 0 Then
		    If mHostPage.ContentArea <> Nil Then
		      mHistory.Add(mHostPage.ContentArea)
		      mHostPage.ContentArea.Visible = False
		    End If
		    
		    Var nextContainer As WebContainer = mForward.Pop
		    mHostPage.ContentArea = nextContainer
		    
		    // For wc_Base containers, handle embedding properly
		    If nextContainer IsA wc_Base Then
		      Var wc As wc_Base = wc_Base(nextContainer)
		      
		      // Only embed if not already embedded
		      If wc.Parent = Nil Then
		        // Calculate size based on position mode
		        Var embedW, embedH As Integer
		        If wc.Position = wc_Base.PositionEnum.TopLeft Then
		          embedW = mHostPage.Placeholder.Width
		          embedH = mHostPage.Placeholder.Height
		        Else
		          embedW = wc.Width
		          embedH = wc.Height
		        End If
		        
		        // Embed with correct size
		        nextContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, embedW, embedH)
		      End If
		      
		      // Then let EmbedInto do positioning and locking
		      wc.EmbedInto(mHostPage.Placeholder)
		    Else
		      If nextContainer.Parent = Nil Then
		        nextContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		      End If
		    End If
		    
		    nextContainer.Visible = True
		    LogNavigation("NavigateForward", nextContainer)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NavigateTo(container as WebContainer)
		  If mHostPage.ContentArea <> Nil Then
		    mHistory.Add(mHostPage.ContentArea)
		    mHostPage.ContentArea.Visible = False
		  End If
		  
		  mForward.RemoveAll
		  mHostPage.ContentArea = container
		  
		  // For wc_Base containers, embed them directly first
		  If container IsA wc_Base Then
		    Var wc As wc_Base = wc_Base(container)
		    
		    // Calculate size based on position mode
		    Var embedW, embedH As Integer
		    If wc.Position = wc_Base.PositionEnum.TopLeft Then
		      embedW = mHostPage.Placeholder.Width
		      embedH = mHostPage.Placeholder.Height
		    Else
		      embedW = wc.Width
		      embedH = wc.Height
		    End If
		    
		    // Embed with correct size
		    container.EmbedWithin(mHostPage.Placeholder, 0, 0, embedW, embedH)
		    
		    // Then let EmbedInto do positioning and locking
		    wc.EmbedInto(mHostPage.Placeholder)
		  Else
		    container.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		  End If
		  
		  container.Visible = True
		  LogNavigation("NavigateTo", container)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mForward() As WebContainer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHistory() As WebContainer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHostPage As wp_MainShell
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TargetContainer As WebContainer
	#tag EndProperty


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
