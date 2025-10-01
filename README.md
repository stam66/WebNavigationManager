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
```xojo
Public MainShell as wp_MainShell
Public Navigation as WebNavigationManager
```

### In the Session's **Opening** event:
```xojo
xojoMainShell = New wp_MainShell
MainShell.Show
Navigation = New WebNavigationManager(MainShell)

// Navigate to initial container
Var w As New wc_Landing
Navigation.NavigateTo(w)
```

### 2. **wp_MainShell** Configuration
Properties:
- xojoPublic ContentArea As WebContainer  

Controls:
- Placeholder (WebContainer) - The area where content containers are embedded

Methods:
```xojo
Sub RepositionContent()
  If ContentArea IsA wc_Base Then
    wc_Base(ContentArea).EmbedInto(Placeholder)
  End If
End Sub
```

Events:
- Call RepositionContent() from Placeholder.Opening event
- Call RepositionContent() from Placeholder.Resized event