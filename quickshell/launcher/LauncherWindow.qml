import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
	bottom: true
	left: true
	right: true
    }

    color: "transparent"
    visible: true

    property int selectedIndex: 0

    property var filteredApps: {
	    var term = searchInput.text.toLowerCase().trim();
	    var apps = DesktopEntries.applications.values;
	    if (term === "") return apps;

	    return apps.filter(app => {
                var nameMatch = app.name && app.name.toLowerCase().includes(term);
		var commentMatch = app.comment && app.comment.toLowerCase().includes(term);
		return nameMatch || commentMatch;
            });
    }

    function launchApp(app) {
        if (!app) return;

	Process.execute(app.commandLine);

	searchInput.text = "";
	root.visible = false;
    }

    Rectangle {
        anchors.fill: parent
	color: "#80000000"

	MouseArea {
	    anchors.fill: parent
	    onClicked: root.visible = false
        }
    }

    Rectangle {
        width: 500
	height: 450
	anchors.centerIn: parent
	color:"#1e1e2e"
	radius: 12
	border.color: "#cba6f7"
	border.width: 2

	Column {
	    anchors.fill: parent
	    anchors.margins: 20
	    spacing: 15

	    Text {
	        text: "App Launcher"
		color: "#cdd6f4"
		font.pixelSize: 18
		font.bold: true
	    }

	    Rectangle {
                width: parent.width
		height: 45
		color: "#313244"
		radius: 8

		TextInput {
		    id: searchInput
		    anchors.fill: parent
		    anchors.margins: 12
		    color: "#cdd6f4"
		    font.pixelSize: 15
		    focus: root.visible

		    Text {
		        text: "Search apps..."
			color: "#6c7086"
			visible: parent.text.length === 0
			font.pixelSize: 14
		    }
                    
		    onTextChanged: root.selectedIndex = 0

		    Keys.onDownPressed: {
		        if (root.selectedIndex < root.filteredApps.length - 1) {
			    root.selectedIndex++;
		        }
		    }
		    Keys.onUpPressed: {
			if (root.selectedIndex > 0) {
			    root.selectedIndex--;
		        }
		    }
		    Keys.onReturnPressed: {
		        if (root.filteredApps.length > 0) {
			    root.launchApp(root.filteredApps[root.selectedIndex]);
		        }
		    }
		    Keys.onEscapePressed: {
			root.visible = false;
		    }
                }
	    }

	    ListView {
	        id: appListView
		width: parent.width
		height: parent.height - 90 
		clip: true
		spacing: 6

		model: root.filteredApps
		currentIndex: root.selectedIndex

		delegate: Rectangle {
		    id: itemRect
		    width: appListView.width
		    height: 50
		    radius: 8
		    color: index === root.selectedIndex ? "#45475a" : "transparent"

		    Row {
                        anchors.fill: parent
			anchors.margins: 10
			spacing: 12

			Rectangle {
			    width: 30
			    height: 30
			    radius: 6
			    color: "#cba6f7"
			    anchors.verticalCenter: parent.verticalCenter

			    Text {
				text: modelData.name ? modelData.name.charAt(0).toUpperCase() : "?"
				color: "#11111b"
				font.bold: true
				anchors.centerIn: parent
			    }
		        }

			Column {
			    anchors.verticalCenter: parent.verticalCenter
			    spacing: 2

			    Text {
			        text: modelData.name || "Unknown application"
				color: "#cdd6f4"
				font.pixelSize:14
				font.bold: true
			    }

			    Text {
			        text: modelData.comment || modelData.genericaName || ""
				color: "#a6adc8"
				font.pixelSize: 11
				elide: Text.ElideRight
				width: 380
				visible: text !== ""
			    }
			}
		    }

		    MouseArea {
			anchors.fill: parent
			hoverEnabled: true
			onEntered: root.selectedIndex = index
			onClicked: root.launchApp(modelData)
		    }
	        }
	    }
        }
    }
}
