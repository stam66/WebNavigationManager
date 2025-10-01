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
		    // Push current to forward stack and hide it
		    If mHostPage.ContentArea <> Nil Then
		      mForward.Add(mHostPage.ContentArea)
		      mHostPage.ContentArea.Visible = False  // Hide current
		    End If
		    
		    Var previousContainer As WebContainer = mHistory.Pop
		    mHostPage.ContentArea = previousContainer
		    previousContainer.Visible = True  // Show previous
		    
		    If previousContainer IsA wc_Base Then
		      wc_Base(previousContainer).EmbedInto(mHostPage.Placeholder)
		    Else
		      previousContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		    End If
		    
		    // Log the navigation
		    LogNavigation("NavigateBack", previousContainer)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NavigateForward()
		  If mForward.Count > 0 Then
		    // Push current to history and hide it
		    If mHostPage.ContentArea <> Nil Then
		      mHistory.Add(mHostPage.ContentArea)
		      mHostPage.ContentArea.Visible = False  // Hide current
		    End If
		    
		    Var nextContainer As WebContainer = mForward.Pop
		    mHostPage.ContentArea = nextContainer
		    nextContainer.Visible = True  // Show next
		    
		    If nextContainer IsA wc_Base Then
		      wc_Base(nextContainer).EmbedInto(mHostPage.Placeholder)
		    Else
		      nextContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		    End If
		    
		    // Log the navigation
		    LogNavigation("NavigateForward", nextContainer)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub NavigateTo(container as WebContainer)
		  // Push current container to history if it exists AND hide it
		  If mHostPage.ContentArea <> Nil Then
		    mHistory.Add(mHostPage.ContentArea)
		    mHostPage.ContentArea.Visible = False  // Hide the previous container
		  End If
		  
		  // Clear forward stack on new navigation
		  mForward.RemoveAll
		  
		  // Set new container
		  mHostPage.ContentArea = container
		  
		  // Make sure new container is visible
		  container.Visible = True
		  
		  // Force embedding for wc_Base containers
		  If container IsA wc_Base Then
		    wc_Base(container).EmbedInto(mHostPage.Placeholder)
		  Else
		    // Fallback for non-wc_Base containers
		    container.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
		  End If
		  
		  // Force the reposition
		  mHostPage.RepositionContent
		  
		  // Log the navigation
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
