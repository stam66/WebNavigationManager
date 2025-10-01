# WebNavigationManager
WebContainer based page navigation for XOJO Web apps



## Overview
This navigation system provides a single-page application experience for XOJO WebApps by using a shell page that dynamically loads different WebContainers instead of creating multiple web pages. This approach enables smooth transitions with browser-like back/forward navigation.

## Basic concept  
The system is based on a page template where the background eleements are fixed and the content area is a container in which other containers are embedded.
These containers are a subclass of a subclass of WebContainer that contains embedding instructures (center or topLeft placement for exmaple)
A navigation class handles naviating to a webcontainer, back and forward and logs the activity.

## Simple usage in web app:
```
// Navigate to it
Session.Navigation.NavigateTo(myContainer)

Navigation Controls  
// Navigate back
Session.Navigation.NavigateBack()  

// Navigate forward
Session.Navigation.NavigateForward()
```

## Architecture

### Components
1. **Session** - Hold the isntance of the WebNavigationManager Class
2. **wp_MainShell** - Main shell page that hosts containers
3. **wc_Base** - Base class for all navigable WebContainers
4. **WebNavigationManager** - Handles navigation logic and history

---

## Setup Instructions

### 1. **Session** Setup
Add the following properties to your Session:
```
Public MainShell as wp_MainShell
Public Navigation as WebNavigationManager
```

### In the Session's **Opening** event:
```
MainShell = New wp_MainShell
MainShell.Show
Navigation = New WebNavigationManager(MainShell)

// Navigate to initial container
Var w As New wc_Landing
w.ContainerID = "Landing"
w.Position = wc_Base.PositionEnum.TopLeft
Navigation.NavigateTo(w)
```

### 2. **wp_MainShell** Configuration
Properties:
- Public ContentArea As WebContainer  

##### Controls:
- Placeholder (WebContainer) - The area where content containers are embedded
- **IMPORTANT**: Lock Placeholder to all sides (LockLeft, LockTop, LockRight, LockBottom = True) so it resizes with the page


### 3. wc_Base WebContainer Class
This is a base class that all navigable WebContainers should inherit from.
Properties:
- Public ContainerID As String  // Unique identifier for logging
- Public Position As PositionEnum     // Center, TopLeft, etc.
PositionEnum:
```
Enum PositionEnum
  Center
  TopLeft
End Enum
```

Key Method - EmbedInto:
```
Public Sub EmbedInto(target As WebContainer) 
  // This only handles positioning and locking, NOT the actual embedding
  // Don't embed - assume already embedded by NavigationManager
  
  Select Case Position
  Case PositionEnum.TopLeft
    Self.LockLeft = True
    Self.LockTop = True
    Self.LockRight = True
    Self.LockBottom = True
    
  Case PositionEnum.Center
    Var targetW As Integer = target.Width
    Var targetH As Integer = target.Height
    Self.Left = (targetW - Self.Width) / 2
    Self.Top = (targetH - Self.Height) / 2
  End Select
End Sub
```


### 4. WebNavigationManager Class
This class manages the navigation stack and container transitions.
Complete Class Code:
```
Private mHostPage As wp_MainShell
Private mHistory() As WebContainer
Private mForward() As WebContainer

Public Sub Constructor(host As wp_MainShell)
  mHostPage = host
End Sub

Public Sub NavigateTo(container As WebContainer)
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

Public Sub NavigateBack()
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

Public Sub NavigateForward()
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

Private Sub LogNavigation(action As String, destination As WebContainer)
  Var name As String = If(destination IsA wc_Base, wc_Base(destination).ContainerID, "Unknown")
  System.DebugLog("Navigation: " + action + " → " + name)
End Sub
```
---

## Usage Example
### Creating a New Container
```
// Create a new container that inherits from wc_Base
Var myContainer As New wc_MyCustomContainer
myContainer.ContainerID = "MyContainer"
myContainer.Position = wc_Base.PositionEnum.Center  

// Navigate to it
Session.Navigation.NavigateTo(myContainer)

Navigation Controls  
// Navigate back
Session.Navigation.NavigateBack()  

// Navigate forward
Session.Navigation.NavigateForward()
```
