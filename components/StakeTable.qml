// Copyright (c) 2014-2018, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import moneroComponents.Clipboard 1.0
import moneroComponents.AddressBookModel 1.0

import "../components" as MoneroComponents
import "../js/TxUtils.js" as TxUtils

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    property var previousItem
    property int rowSpacing: 12
    property var addressBookModel: null

    function buildTxDetailsString(tx_id, paymentId, tx_key,tx_note, destinations, rings, address, address_label) {
        var trStart = '<tr><td width="85" style="padding-top:5px"><b>',
            trMiddle = '</b></td><td style="padding-left:10px;padding-top:5px;">',
            trEnd = "</td></tr>";

        return '<table border="0">'
            + (tx_id ? trStart + qsTr("Tx ID:") + trMiddle + tx_id + trEnd : "")
            + (address_label ? trStart + qsTr("Address label:") + trMiddle + address_label + trEnd : "")
            + (address ? trStart + qsTr("Address:") + trMiddle + address + trEnd : "")
            + (paymentId ? trStart + qsTr("Payment ID:") + trMiddle + paymentId + trEnd : "")
            + (tx_key ? trStart + qsTr("Tx key:") + trMiddle + tx_key + trEnd : "")
            + (tx_note ? trStart + qsTr("Tx note:") + trMiddle + tx_note + trEnd : "")
            + (destinations ? trStart + qsTr("Destinations:") + trMiddle + destinations + trEnd : "")
            + (rings ? trStart + qsTr("Rings:") + trMiddle + rings + trEnd : "")
            + "</table>"
            + translationManager.emptyString;
    }

    function lookupPaymentID(paymentId) {
        if (!addressBookModel)
            return ""
        var idx = addressBookModel.lookupPaymentID(paymentId)
        if (idx < 0)
            return ""
        idx = addressBookModel.index(idx, 0)
        return addressBookModel.data(idx, AddressBookModel.AddressBookDescriptionRole)
    }

    header: Rectangle {
        height: 27 * scaleRatio
        width: listView.width
        color: "transparent"

        Rectangle{
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.top
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Text {
            id: stakeHeader
            width: 200 * scaleRatio
            anchors.left: parent.left
            anchors.leftMargin: 40 * scaleRatio
            font.family: "Arial"
            font.pixelSize: 14
            font.bold: true
            color: "#808080"
            text: qsTr("Staked:") + translationManager.emptyString
        }
        Text {
            id: dateHeader
            width: 200 * scaleRatio
            anchors.left: stakeHeader.right
            anchors.leftMargin: 80 * scaleRatio
            font.family: "Arial"
            font.pixelSize: 14
            font.bold: true
            color: "#808080"
            text: qsTr("Date:") + translationManager.emptyString
        }
        Text {
            id: locktimeHeader
            width: 150 * scaleRatio
            anchors.left: dateHeader.right
            anchors.leftMargin: 100 * scaleRatio
            font.family: "Arial"
            font.pixelSize: 14
            font.bold: true
            color: "#808080"
            text: qsTr("Lock time: (block/~days)") + translationManager.emptyString
        }
        Text {
            id: expirateHeader
            width: 100 * scaleRatio
            anchors.left: locktimeHeader.right
            anchors.leftMargin: 200 * scaleRatio
            font.family: "Arial"
            font.pixelSize: 14
            font.bold: true
            color: "#808080"
            text: qsTr("Expirate time: (height/~time)") + translationManager.emptyString
        }
    }

    footer: Rectangle {
        height: 127 * scaleRatio
        width: listView.width
        color: "transparent"

        Text {
            anchors.centerIn: parent
            font.family: "Arial"
            font.pixelSize: 14
            color: "#545454"
            text: qsTr("No more results") + translationManager.emptyString
        }
    }

    delegate: Rectangle {
        id: delegate
        property bool collapsed: false
        height: 70 * scaleRatio
        width: listView.width
        color: "transparent"

        // borders
        Rectangle{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: collapsed ? 2 : 1
            color: collapsed ? "#BBBBBB" : "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.top
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Rectangle {
            id: row1
            anchors.left: parent.left
            anchors.leftMargin: 20 * scaleRatio
            anchors.right: parent.right
            anchors.rightMargin: 20 * scaleRatio
            anchors.top: parent.top
            anchors.topMargin: 15 * scaleRatio
            height: 40 * scaleRatio
            color: "transparent"

            MouseArea {
                    hoverEnabled: true
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        parent.color = "#404040"
                    }
                    onExited: {
                        parent.color = "transparent"
                    }
                    onClicked: {
                            console.log("Copied txid to clipboard");
                            clipboard.setText(hash);
                            appWindow.showStatusMessage(qsTr("Copied txid to clipboard"),3)
                    }
                }

            Image {
                id: arrowImage
                source: "../images/lockIcon.png"
                height: 18 * scaleRatio
                width: (confirmationsRequired === 60  ? 18 : 12) * scaleRatio
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: amountLabel
                anchors.left: arrowImage.right
                anchors.leftMargin: 18 * scaleRatio
                anchors.verticalCenter: parent.verticalCenter
                font.family: MoneroComponents.Style.fontBold.name
                font.pixelSize: 18 * scaleRatio
                font.bold: true
                text: {
                    var _amount = amount;
                    if(_amount === 0){
                        // *sometimes* amount is 0, while the 'destinations string' 
                        // has the correct amount, so we try to fetch it from that instead.
                        _amount = TxUtils.destinationsToAmount(destinations);
                        _amount = (_amount *1);
                    }

                    if(_amount === 0){
                        _amount = currentWallet.revealTxOut(hash);
                    }

                    return _amount + " XMC";
                }
                color: MoneroComponents.Style.white

                MouseArea {
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            parent.color = MoneroComponents.Style.orange
                        }
                        onExited: {
                            parent.color = MoneroComponents.Style.white
                        }
                        onClicked: {
                                console.log("Copied to clipboard");
                                clipboard.setText(parent.text.split(" ")[0]);
                                appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
                        }
                    }
            }

            Rectangle {
                id: timeRect
                anchors.leftMargin: 300 * scaleRatio
                anchors.left: parent.left
                width: 200 * scaleRatio
                height: parent.height
                color: "transparent"

                Text {
                    id: dateLabel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 18 * scaleRatio
                    font.bold: true
                    text: date
                    color: "#808080"
                }

                Text {
                    id: timeLabel
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: dateLabel.right
                    anchors.leftMargin: 7 * scaleRatio
                    font.pixelSize: 18 * scaleRatio
                    font.bold: true
                    text: time
                    color: "#808080"
                }
            }

            Rectangle {
                id: locktimeRect
                anchors.leftMargin: 100 * scaleRatio
                anchors.left: timeRect.right
                width: 300 * scaleRatio
                height: parent.height
                color: "transparent"

                Text {
                    id: locktimeLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18 * scaleRatio
                    font.bold: true
                    text: qsTr("%1/%2").arg(confirmationsRequired).arg(confirmationsRequired/720)
                    color: "#808080"
                }
            }

            Rectangle {
                id: expiratetimeRect
                anchors.leftMargin: 50 * scaleRatio
                anchors.left: locktimeRect.right
                width: 300 * scaleRatio
                height: parent.height
                color: "transparent"

                Text {
                    id: expirateLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18 * scaleRatio
                    font.bold: true
                    text: unlockTime + "/" + expirateTime
                    color: unlockTime < blockHeight + 10000 ? "red" : "#808080"
                }
            }
        }
    }

    Clipboard { id: clipboard }
}
