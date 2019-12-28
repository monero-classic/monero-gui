import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import moneroComponents.Clipboard 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.NetworkType 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionInfo 1.0
import moneroComponents.TransactionHistoryModel 1.0
import FontAwesome 1.0
import "../components"
import "../components" as MoneroComponents
import "." 1.0
import "../js/TxUtils.js" as TxUtils

Rectangle {
    id: root

    signal paymentClicked(string address, string paymentId, string amount, int mixinCount, int priority, string description, string unlocktime)

    color: "transparent"
    property alias transferHeight1: pageRoot.height
    property int mixin: 10  // (ring size 11)
    property string warningContent: ""
    property string sendButtonWarning: ""
    property string startLinkText: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><font size='2'> (</font><a href='#'>Start daemon</a><font size='2'>)</font>") + translationManager.emptyString
    property string settingsPath: applicationDirPath + "/pos.json"
    // @TODO: remove after pid removal hardfork
    property bool warningLongPidTransfer: false
    property var model
    property int tableHeight: !isMobile ? table.contentHeight : tableMobile.contentHeight

    QtObject {
        id: d
        property bool initialized: false
    }

    Clipboard { id: clipboard }

    onModelChanged: {
        if (typeof model !== 'undefined' && model != null) {
            if (!d.initialized) {
                model.sortRole = TransactionHistoryModel.TransactionBlockHeightRole
                model.sort(0, Qt.DescendingOrder);
                d.initialized = true
            }
        }
    }

    function clearFields() {
        amountLine.text = ""
        locktimeDropdown.currentIndex = 0
        updateLocktimeDropdown()
    }

    ColumnLayout {
      id: pageRoot
      anchors.margins: 20
      anchors.topMargin: 40

      anchors.left: parent.left
      anchors.top: parent.top
      anchors.right: parent.right

      spacing: 30

      RowLayout {
          visible: root.warningContent !== ""

          MoneroComponents.WarningBox {
              text: warningContent
              onLinkActivated: {
                  appWindow.startDaemon(appWindow.persistentSettings.daemonFlags);
              }
          }
      }

      GridLayout {
          columns: appWindow.walletMode < 2 ? 1 : 2
          Layout.fillWidth: true
          columnSpacing: 32

          ColumnLayout {
              Layout.fillWidth: true
              Layout.minimumWidth: 200

              // Amount input
              LineEdit {
                  id: amountLine
                  Layout.fillWidth: true
                  inlineIcon: true
                  labelText: qsTr("<style type='text/css'>a {text-decoration: none; color: #858585; font-size: 14px;}</style> Amount <font size='2'></font>")
                             + translationManager.emptyString
                  placeholderText: "0.00"
                  width: 100
                  fontBold: true
                  inlineButtonText: qsTr("All") + translationManager.emptyString
                  inlineButton.onClicked: amountLine.text = "(all)"
                  onTextChanged: {
                      if(amountLine.text.indexOf('.') === 0){
                          amountLine.text = '0' + amountLine.text;
                      }
                  }

                  validator: RegExpValidator {
                      regExp: /^(\d{1,8})?([\.]\d{1,12})?$/
                  }
              }
          }

          ColumnLayout {
              visible: appWindow.walletMode >= 2
              Layout.fillWidth: true
              Label {
                  id: transactionLocktime
                  Layout.topMargin: 12
                  text: qsTr("Lock time (days)") + translationManager.emptyString
                  fontBold: false
                  fontSize: 16
              }
              // Note: workaround for translations in listElements
              // ListElement: cannot use script for property value, so
              // code like this wont work:
              // ListElement { column1: qsTr("LOW") + translationManager.emptyString ; column2: ""; priority: PendingTransaction.Priority_Low }
              // For translations to work, the strings need to be listed in
              // the file components/StandardDropdown.qml too.

              // Priorites after v5
              ListModel {
                   id: locktimeModelV5

                   // Add more 200 height for block confirm spent
                   ListElement {column1: qsTr("90"); column2: ""; locktime: "65000"}
                   ListElement {column1: qsTr("180"); column2: ""; locktime: "129800"}
                   ListElement {column1: qsTr("360"); column2: ""; locktime: "259400"}
               }

              StandardDropdown {
                  Layout.fillWidth: true
                  id: locktimeDropdown
                  Layout.topMargin: 5
                  currentIndex: 0
              }
          }
          // Make sure dropdown is on top
          z: parent.z + 1
      }

      RowLayout {
          StandardButton {
              id: sendButton
              rightIcon: "qrc:///images/rightArrow.png"
              rightIconInactive: "qrc:///images/rightArrowInactive.png"
              Layout.topMargin: 40
              width: 200 * scaleRatio
              text: qsTr("Stake") + translationManager.emptyString
              enabled: {
                return updateSendButton()
              }
              onClicked: {
                  console.log("Stake: paymentClicked")
                  var unlocktime = locktimeModelV5.get(locktimeDropdown.currentIndex).locktime
                  var mainaddress = currentWallet.address(0, 0)
                  console.log("locktime: " + unlocktime)
                  console.log("amount: " + amountLine.text)
                  console.log("main address: " + mainaddress);
                  root.paymentClicked(mainaddress, "", amountLine.text, root.mixin, 0, "", unlocktime)
              }
          }
          StandardButton {
              id: exportStakeSettingsButton
              Layout.topMargin: 40
              anchors.left: sendButton.right
              anchors.leftMargin: 150
              width: 200 * scaleRatio
              text: qsTr("Export Stake Settings") + translationManager.emptyString
              small: true
              visible: !appWindow.viewOnly
              enabled: table.count > 0
              onClicked: {
                  console.log("Stake: export stake settings clicked")
                  exportStakeSettingsDialog.open();
              }
          }
          MoneroComponents.CheckBox {
              id: autoStakeCheckBox
              Layout.topMargin: 40
              anchors.left: exportStakeSettingsButton.right
              anchors.leftMargin: 150
              //fontBold: false
              fontSize: 16 * scaleRatio
              //checked: persistentSettings.hideBalance
              checked: false
              onClicked: {
                  //persistentSettings.hideBalance = !persistentSettings.hideBalance
                  //appWindow.updateBalance();
                  currentWallet.setAutoStake(autoStakeCheckBox.checked);
              }
              text: qsTr("Auto stake when one expirates") + translationManager.emptyString
          }
      }

      FileDialog {
          id: exportStakeSettingsDialog
          selectMultiple: false
          selectExisting: false
          onAccepted: {
              settingsPath = walletManager.urlToLocalPath(exportStakeSettingsDialog.fileUrl)
              console.log("stake settings path: " + settingsPath)
              currentWallet.exportStakedSettings(settingsPath);
          }
          onRejected: {
              console.log("Canceled");
          }
      }

      MoneroComponents.WarningBox {
          id: sendButtonWarningBox
          text: root.sendButtonWarning
          visible: root.sendButtonWarning !== ""
      }

      GridLayout {
          id: tableHeader
          columns: 1
          columnSpacing: 0
          rowSpacing: 0
          Layout.topMargin: 20
          Layout.fillWidth: true

          Label {
              fontSize: 16
              text: qsTr("Staked transaction list") + translationManager.emptyString
          }

          Rectangle {
            height: 10
          }

          RowLayout{
              Layout.preferredHeight: 10
              Layout.fillWidth: true

              Rectangle {
                  id: header
                  Layout.fillWidth: true
                  visible: table.count > 0

                  height: 10
                  color: "transparent"

                  Rectangle {
                      anchors.top: parent.top
                      anchors.left: parent.left
                      anchors.right: parent.right
                      anchors.rightMargin: 10
                      anchors.leftMargin: 10

                      height: 1
                      color: "#404040"
                  }

                  Image {
                      anchors.top: parent.top
                      anchors.left: parent.left

                      width: 10
                      height: 10

                      source: "../images/historyBorderRadius.png"
                  }

                  Image {
                      anchors.top: parent.top
                      anchors.right: parent.right

                      width: 10
                      height: 10

                      source: "../images/historyBorderRadius.png"
                      rotation: 90
                  }
              }
          }

          RowLayout {
              Layout.preferredHeight: table.contentHeight
              Layout.fillWidth: true
              Layout.fillHeight: true

              StakeTable {
                  id: table
                  visible: true
                  onContentYChanged: flickableScroll.flickableContentYChanged()
                  model: root.model
                  addressBookModel: null

                  Layout.fillWidth: true
                  Layout.fillHeight: true
              }

          }
      }
    } // pageRoot

    Component.onCompleted: {
        //Disable password page until enabled by updateStatus
        pageRoot.enabled = false
    }

    // fires on every page load
    function onPageCompleted() {
        console.log("stake page loaded")
        updateStatus();
        updateLocktimeDropdown()

        if(currentWallet != null && typeof currentWallet.history !== "undefined" ) {
            currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
        }
    }

    function updateLocktimeDropdown() {
        locktimeDropdown.dataModel = locktimeModelV5;
        locktimeDropdown.update()
    }

    function updateStatus() {
        var messageNotConnected = qsTr("Wallet is not connected to daemon.");
        if(appWindow.walletMode >= 2) messageNotConnected += root.startLinkText;
        pageRoot.enabled = true;
        if(typeof currentWallet === "undefined") {
            root.warningContent = messageNotConnected;
            return;
        }

        if (currentWallet.viewOnly) {
           // warningText.text = qsTr("Wallet is view only.")
           //return;
        }
        //pageRoot.enabled = false;

        switch (currentWallet.connected()) {
        case Wallet.ConnectionStatus_Disconnected:
            root.warningContent = messageNotConnected;
            break
        case Wallet.ConnectionStatus_WrongVersion:
            root.warningContent = qsTr("Connected daemon is not compatible with GUI. \n" +
                                   "Please upgrade or connect to another daemon")
            break
        default:
            if(!appWindow.daemonSynced){
                root.warningContent = qsTr("Waiting on daemon synchronization to finish.")
            } else {
                // everything OK, enable transfer page
                // Light wallet is always ready
                pageRoot.enabled = true;
                root.warningContent = "";
            }
        }
    }

    function updateSendButton(){
        // reset message
        root.sendButtonWarning = "";

        // Currently opened wallet is not view-only
        if(appWindow.viewOnly){
            root.sendButtonWarning = qsTr("Wallet is view-only and sends are not possible.") + translationManager.emptyString;
            return false;
        }

        if (amountLine.text == "") {
            return false;
        }

        // There are sufficient unlocked funds available
        if(parseFloat(amountLine.text) > parseFloat(middlePanel.unlockedBalanceText)){
            root.sendButtonWarning = qsTr("Amount is more than unlocked balance.") + translationManager.emptyString;
            return false;
        }

        // There is no warning box displayed
        if(root.warningContent !== ""){
            return false;
        }

        return true;
    }

    function update() {
        currentWallet.history.refresh(currentWallet.currentSubaddressAccount)
        currentWallet.exportStakedSettings(settingsPath);
    }

    Timer {
        // Simple mode connection check timer
        id: simpleModeConnectionTimer
        // every 30 minutes
        interval: 1800000; running: true; repeat: true
        onTriggered: root.update()
    }
}
