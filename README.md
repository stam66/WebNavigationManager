# WebNavigationManager
WebContainer based page navigation for XOJO Web apps



## Overview
This navigation system provides a single-page application experience for XOJO WebApps by using a shell page that dynamically loads different WebContainers instead of creating multiple web pages. This approach enables smooth transitions with browser-like back/forward navigation.

## Basic concept  
The system is based on a page template where the background eleements are fixed and the content area is a container in which other containers are embedded.
These containers are a subclass of a subclass of WebContainer that contains embedding instructures (center or topLeft placement for exmaple)
A navigation class handles naviating to a webcontainer, back and forward and logs the activity.

## Architecture

### Components
1. **Session** - Manages application-level instances for each user
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
xojoMainShell = New wp_MainShell
MainShell.Show
Navigation = New WebNavigationManager(MainShell)

// Navigate to initial container
Var w As New wc_Landing
Navigation.NavigateTo(w)
```

### 2. **wp_MainShell** Configuration
Properties:
- Public ContentArea As WebContainer  

Controls:
- Placeholder (WebContainer) - The area where content containers are embedded

Methods:
```
Sub RepositionContent()
  If ContentArea IsA wc_Base Then
    wc_Base(ContentArea).EmbedInto(Placeholder)
  End If
End Sub
```

Events:
- Call RepositionContent() from Placeholder.Opening event
- Call RepositionContent() from Placeholder.Resized event

### 3. wc_Base WebContainer Class
This is a base class that all navigable WebContainers should inherit from.
Properties:
- Public ContainerID As String  // Unique identifier for logging
Public Position As PositionEnum     // Center, TopLeft, etc.
- PositionEnum:
```
Enum PositionEnum
  Center
  TopLeft
End Enum
```

Key Method - EmbedInto:
```
Public Sub EmbedInto(target As WebContainer)
  // Only embed if not already embedded
  If Self.Parent = Nil Then
    Self.EmbedWithin(target, 0, 0, Self.Width, Self.Height)
  End If
  
  // Then position it
  Select Case Position
  Case PositionEnum.Center
    Self.Left = (target.Width - Self.Width) / 2
    Self.Top = (target.Height - Self.Height) / 2
    
  Case PositionEnum.TopLeft
    // Let the container stretch with its parent
    Self.LockLeft = True
    Self.LockTop = True
    Self.LockRight = True
    Self.LockBottom = True
    
    Self.Left = 0
    Self.Top = 0
  End Select
  
  Self.Width = Min(Self.Width, target.Width)
  Self.Height = Min(Self.Height, target.Height)
End Sub
```
Important: The Parent = Nil check prevents the "UnsupportedOperationException" that occurs when trying to embed an already-embedded container.

### 4. WebNavigationManager Class
This class manages the navigation stack and container transitions.
Complete Class Code:
```xojo
Private mHostPage As wp_MainShell
Private mHistory() As WebContainer
Private mForward() As WebContainer

Public Sub Constructor(host As wp_MainShell)
  mHostPage = host
End Sub

Public Sub NavigateTo(container As WebContainer)
  // Push current container to history if it exists AND hide it
  If mHostPage.ContentArea <> Nil Then
    mHistory.Add(mHostPage.ContentArea)
    mHostPage.ContentArea.Visible = False
  End If
  
  // Clear forward stack on new navigation
  mForward.RemoveAll
  
  // Set new container
  mHostPage.ContentArea = container
  container.Visible = True
  
  // Embed container
  If container IsA wc_Base Then
    wc_Base(container).EmbedInto(mHostPage.Placeholder)
  Else
    container.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
  End If
  
  mHostPage.RepositionContent
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
    previousContainer.Visible = True
    
    If previousContainer IsA wc_Base Then
      wc_Base(previousContainer).EmbedInto(mHostPage.Placeholder)
    Else
      previousContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
    End If
    
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
    nextContainer.Visible = True
    
    If nextContainer IsA wc_Base Then
      wc_Base(nextContainer).EmbedInto(mHostPage.Placeholder)
    Else
      nextContainer.EmbedWithin(mHostPage.Placeholder, 0, 0, mHostPage.Placeholder.Width, mHostPage.Placeholder.Height)
    End If
    
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