import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
  id: root
  width: 1920
  height: 1080
  color: "#282c34" // base

  // ===================== ONE DARK PALETTE =====================
  readonly property color cBase: "#282c34"
  readonly property color cSurface: "#2c313c"
  readonly property color cOverlay: "#353b45"
  readonly property color cText: "#abb2bf"
  readonly property color cSubtext: "#7f848e"
  readonly property color cMuted: "#5c6370"
  readonly property color cWhite: "#ffffff"
  readonly property color cBlue: "#61afef"
  readonly property color cCyan: "#56b6c2"
  readonly property color cGreen: "#98c379"
  readonly property color cRed: "#e06c75"
  readonly property color cYellow: "#e5c07b"
  readonly property color cOrange: "#d19a66"
  readonly property color cPurple: "#c678dd"

  // ===================== SOLID BACKGROUND =====================
  Rectangle {
    anchors.fill: parent
    color: root.cBase
  }

  // ===================== ANIMATED PIPES BACKGROUND =====================
  Canvas {
    id: pipesCanvas
    anchors.fill: parent
    renderTarget: Canvas.FramebufferObject
    renderStrategy: Canvas.Cooperative

    readonly property int cell: 18
    property var pipeColors: [root.cBlue, root.cCyan, root.cGreen, root.cYellow, root.cPurple, root.cRed]
    property var dirs: [[1,0],[-1,0],[0,1],[0,-1]]
    property var pipes: []
    property int pipeCount: 16
    property bool gridDrawn: false
    property int frameCount: 0

    readonly property int fadeDurationFrames: 90
    readonly property real initialDropEnd: 0.08
    readonly property real plateauEnd: 0.85
    readonly property real plateauLevel: 0.62

    property var litCells: ({})

    function dischargeAlpha(t) {
      if (t < initialDropEnd) {
        var f = t / initialDropEnd
        return 1.0 - f * (1.0 - plateauLevel)
      }
      if (t < plateauEnd) {
        var f2 = (t - initialDropEnd) / (plateauEnd - initialDropEnd)
        return plateauLevel - f2 * 0.05
      }
      var f3 = (t - plateauEnd) / (1 - plateauEnd)
      return Math.max(0, (plateauLevel - 0.05) * Math.pow(1 - f3, 3))
    }

    function makePipe() {
      var cols = Math.floor(width / cell)
      var rows = Math.floor(height / cell)
      return {
        x: Math.floor(Math.random() * cols),
        y: Math.floor(Math.random() * rows),
        dir: dirs[Math.floor(Math.random() * 4)],
        color: pipeColors[Math.floor(Math.random() * pipeColors.length)],
        life: 60 + Math.random() * 120,
        turnCooldown: 0
      }
    }

    function drawBaseGrid(ctx) {
      var cols = Math.floor(width / cell)
      var rows = Math.floor(height / cell)
      ctx.fillStyle = root.cOverlay
      for (var gx = 0; gx < cols; gx++) {
        for (var gy = 0; gy < rows; gy++) {
          ctx.fillRect(gx * cell, gy * cell, cell - 2, cell - 2)
        }
      }
    }

    Component.onCompleted: {
      var arr = []
      for (var i = 0; i < pipeCount; i++) arr.push(makePipe())
      pipes = arr
      requestPaint()
    }

    onPaint: {
      var ctx = getContext("2d")
      var cols = Math.floor(width / cell)
      var rows = Math.floor(height / cell)

      if (!gridDrawn) {
        ctx.fillStyle = root.cBase
        ctx.fillRect(0, 0, width, height)
        drawBaseGrid(ctx)
        gridDrawn = true
      }

      frameCount += 1

      for (var i = 0; i < pipes.length; i++) {
        var p = pipes[i]
        var key = p.x + "," + p.y
        litCells[key] = { frame: frameCount, color: p.color }
      }

      var keys = Object.keys(litCells)
      for (var k = 0; k < keys.length; k++) {
        var key2 = keys[k]
        var entry = litCells[key2]
        var age = frameCount - entry.frame
        var t = age / fadeDurationFrames

        if (t >= 1) {
          var parts = key2.split(",")
          var gx2 = parseInt(parts[0], 10)
          var gy2 = parseInt(parts[1], 10)
          ctx.fillStyle = root.cOverlay
          ctx.fillRect(gx2 * cell, gy2 * cell, cell - 2, cell - 2)
          delete litCells[key2]
          continue
        }

        var parts2 = key2.split(",")
        var gx = parseInt(parts2[0], 10)
        var gy = parseInt(parts2[1], 10)
        var alpha = dischargeAlpha(t)

        ctx.fillStyle = root.cOverlay
        ctx.fillRect(gx * cell, gy * cell, cell - 2, cell - 2)
        ctx.fillStyle = entry.color
        ctx.globalAlpha = alpha
        ctx.fillRect(gx * cell, gy * cell, cell - 2, cell - 2)
        ctx.globalAlpha = 1.0
      }

      for (var j = 0; j < pipes.length; j++) {
        var pp = pipes[j]

        pp.turnCooldown -= 1
        if (pp.turnCooldown <= 0 && Math.random() < 0.12) {
          pp.dir = dirs[Math.floor(Math.random() * 4)]
          pp.turnCooldown = 10
        }

        pp.x += pp.dir[0]
        pp.y += pp.dir[1]

        if (pp.x < 0) pp.x = cols - 1
        if (pp.x >= cols) pp.x = 0
        if (pp.y < 0) pp.y = rows - 1
        if (pp.y >= rows) pp.y = 0

        pp.life -= 1
        if (pp.life <= 0) {
          pipes[j] = makePipe()
        }
      }
    }

    Timer {
      interval: 60
      running: true
      repeat: true
      onTriggered: pipesCanvas.requestPaint()
    }

    onWidthChanged: { gridDrawn = false; requestPaint() }
    onHeightChanged: { gridDrawn = false; requestPaint() }
  }

  // Subtle dark overlay so the card stays readable over busy pipes
  Rectangle {
    anchors.fill: parent
    color: root.cBase
    opacity: 0.15
  }

  // ===================== CLOCK TIMER =====================
  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      clockText.text = Qt.formatTime(new Date(), "hh:mm")
      dateText.text = Qt.formatDate(new Date(), "yyyy-MM-dd")
    }
  }

  // ===================== UNIFIED CARD =====================
  Rectangle {
    id: loginCard
    anchors.centerIn: parent
    width: 400
    height: unifiedColumn.implicitHeight + 80
    radius: 18
    color: Qt.rgba(0.173, 0.192, 0.227, 0.82)
    border.color: Qt.rgba(1, 1, 1, 0.07)
    border.width: 1

    Column {
      id: unifiedColumn
      anchors.centerIn: parent
      width: parent.width - 64
      spacing: 0

      // ---- CLOCK SECTION ----
      Column {
        width: parent.width
        spacing: 6
        bottomPadding: 24

        Text {
          id: clockText
          anchors.horizontalCenter: parent.horizontalCenter
          color: root.cText
          font.pixelSize: 72
          font.weight: Font.Bold
          font.family: "LiterationSans Nerd Font"
        }

        Text {
          id: dateText
          anchors.horizontalCenter: parent.horizontalCenter
          color: root.cSubtext
          font.pixelSize: 18
          font.family: "LiterationSans Nerd Font"
        }
      }

      // ---- DIVIDER ----
      Rectangle {
        width: parent.width
        height: 2
        color: Qt.rgba(1, 1, 1, 0.08)
      }

      // ---- LOGIN SECTION ----
      Column {
        width: parent.width
        spacing: 18
        topPadding: 24

        // Hidden ListView to read the current user's properties
        ListView {
          id: currentUserReader
          visible: false
          height: 0
          width: 0
          model: userModel
          currentIndex: userModel.lastIndex
          delegate: Item {
            property string userName: model.name
            property url userIcon: model.icon
          }
        }

        // Avatar
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          width: 84
          height: 84
          radius: 42
          color: root.cOverlay
          border.color: root.cBlue
          border.width: 2

          Image {
            id: avatarImg
            anchors.fill: parent
            anchors.margins: 3
            fillMode: Image.PreserveAspectCrop
            source: currentUserReader.currentItem ? currentUserReader.currentItem.userIcon : ""
            visible: source !== ""
          }

          Text {
            anchors.centerIn: parent
            visible: !avatarImg.visible
            text: "🙂"
            font.pixelSize: 36
            color: root.cText
          }
        }

        // Username
        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: currentUserReader.currentItem ? currentUserReader.currentItem.userName : ""
          color: root.cText
          font.pixelSize: 18
          font.family: "LiterationSans Nerd Font"
        }

        // Password field
        Rectangle {
          id: passwordBox
          width: parent.width
          height: 44
          radius: 8
          color: root.cBase
          border.color: passwordInput.activeFocus ? root.cBlue : root.cOverlay
          border.width: 1

          property bool revealPassword: false

          TextInput {
            id: passwordInput
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            rightPadding: revealToggle.width + 8
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            echoMode: passwordBox.revealPassword ? TextInput.Normal : TextInput.Password
            color: root.cText
            font.pixelSize: 15
            font.family: "LiterationSans Nerd Font"
            focus: true
            selectByMouse: true

            Text {
              text: "Password"
              color: root.cMuted
              font.pixelSize: 15
              font.family: "LiterationSans Nerd Font"
              anchors.centerIn: parent
              visible: passwordInput.text.length === 0
            }

            Keys.onReturnPressed: doLogin()
            Keys.onEnterPressed: doLogin()
          }

          Item {
            id: revealToggle
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.rightMargin: 10
            width: 28

            property color iconColor: revealMouse.containsMouse ? root.cText : root.cMuted

            Rectangle {
              anchors.centerIn: parent
              width: 18; height: 10; radius: 5
              color: "transparent"
              border.color: revealToggle.iconColor
              border.width: 1.5
            }
            Rectangle {
              anchors.centerIn: parent
              width: 5; height: 5; radius: 2.5
              color: revealToggle.iconColor
            }
            Rectangle {
              anchors.centerIn: parent
              width: 20; height: 1.5; rotation: 45
              color: revealToggle.iconColor
              visible: !passwordBox.revealPassword
            }

            MouseArea {
              id: revealMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                passwordBox.revealPassword = !passwordBox.revealPassword
                passwordInput.forceActiveFocus()
              }
            }
          }
        }

        // Error message
        Text {
          id: errorText
          anchors.horizontalCenter: parent.horizontalCenter
          color: root.cRed
          font.pixelSize: 13
          font.family: "LiterationSans Nerd Font"
          text: ""
          visible: text !== ""
        }

        // Login button
        Rectangle {
          width: parent.width
          height: 40
          radius: 8
          color: loginMouse.pressed ? Qt.darker(root.cBlue, 1.2) : root.cBlue

          Text {
            anchors.centerIn: parent
            text: "Login"
            color: root.cBase
            font.pixelSize: 15
            font.weight: Font.DemiBold
            font.family: "LiterationSans Nerd Font"
          }

          MouseArea {
            id: loginMouse
            anchors.fill: parent
            onClicked: doLogin()
          }
        }
      }
    }
  }

  function doLogin() {
    errorText.text = ""
    sddm.login(
      currentUserReader.currentItem ? currentUserReader.currentItem.userName : "",
      passwordInput.text,
      sessionModel.lastIndex
    )
  }

  Connections {
    target: sddm
    function onLoginFailed() {
      errorText.text = "Login failed"
      passwordInput.text = ""
      passwordInput.forceActiveFocus()
    }
  }

  // ===================== POWER ROW =====================
  Row {
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    anchors.margins: 28
    spacing: 22

    Text {
      text: "Suspend"
      color: root.cSubtext
      font.pixelSize: 14
      font.family: "LiterationSans Nerd Font"
      visible: sddm.canSuspend
      MouseArea { anchors.fill: parent; onClicked: sddm.suspend() }
    }
    Text {
      text: "Reboot"
      color: root.cYellow
      font.pixelSize: 14
      font.family: "LiterationSans Nerd Font"
      visible: sddm.canReboot
      MouseArea { anchors.fill: parent; onClicked: sddm.reboot() }
    }
    Text {
      text: "Shutdown"
      color: root.cRed
      font.pixelSize: 14
      font.family: "LiterationSans Nerd Font"
      visible: sddm.canPowerOff
      MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() }
    }
  }

  // Hidden ListView for session name
  ListView {
    id: currentSessionReader
    visible: false
    height: 0
    width: 0
    model: sessionModel
    currentIndex: sessionModel.lastIndex
    delegate: Item {
      property string sessionName: model.name
    }
  }

  // Session picker, bottom-left
  Row {
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.margins: 28
    spacing: 8

    Text {
      text: currentSessionReader.currentItem ? currentSessionReader.currentItem.sessionName : ""
      color: root.cCyan
      font.pixelSize: 14
      font.family: "LiterationSans Nerd Font"
    }
  }

  Component.onCompleted: passwordInput.forceActiveFocus()
}
