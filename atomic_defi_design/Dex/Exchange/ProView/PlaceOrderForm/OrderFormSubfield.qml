import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../../../Constants" as Dex
import "../../../Components"
import App 1.0
import Dex.Themes 1.0 as Dex

// todo: coding style is wrong, use camelCase.
RowLayout
{
    id: control
    property alias  fiat_value: _fiat_label.text_value
    property alias  left_label: _left_label.text
    property alias  middle_label: _middle_label.text
    property alias  right_label: _right_label.text
    property string left_tooltip_text: ""
    property string middle_tooltip_text: ""
    property string right_tooltip_text: ""
    property alias  left_btn: _left_btn
    property alias  middle_btn: _middle_btn
    property alias  right_btn: _right_btn
    property alias  left_rect: _left_rect
    property alias  middle_rect: _middle_rect
    property alias  right_rect: _right_rect

    property alias  left_btn_mousearea: _left_btn_mousearea
    property alias  middle_btn_mousearea: _middle_btn_mousearea
    property alias  right_btn_mousearea: _right_btn_mousearea
    property int    pixel_size: 12
    property int    btn_width: 33
    spacing: 2
    height: 20
    width: parent.width

    Item
    {
        id: _left_btn
        visible: middle_label != qsTr("Min")
        width: btn_width
        height: parent.height

        DefaultRectangle
        {
            id: _left_rect
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        }

        DefaultText
        {
            id: _left_label
            anchors.centerIn: parent
            font.pixelSize: pixel_size
            color: Dex.CurrentTheme.foregroundColor2
            text: "-1%"
        }

        DexTooltip
        {
            id: _left_tooltip
            visible: _left_btn_mousearea.containsMouse && left_tooltip_text != ""
            
            contentItem: FloatingBackground
            {
                anchors.top: parent.bottom
                anchors.topMargin: 30
                color: Dex.CurrentTheme.accentColor

                DefaultText
                {
                    text: left_tooltip_text
                    font: Dex.DexTypo.caption
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 6
                    bottomPadding: 6
                }
            }

            background: Rectangle {
                width: 0
                height: 0
                color: "transparent"
            }
        }

        DefaultMouseArea
        {
            id: _left_btn_mousearea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Item
    {
        id: _middle_btn
        width: btn_width
        height: parent.height

        DefaultRectangle
        {
            id: _middle_rect
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor

            DefaultText
            {
                id: _middle_label
                anchors.centerIn: parent
                font.pixelSize: pixel_size
                color: Dex.CurrentTheme.foregroundColor2
                text: "0%"
            }

            DexTooltip
            {
                id: _middle_tooltip
                visible: _middle_btn_mousearea.containsMouse && middle_tooltip_text != ""

                contentItem: FloatingBackground
                {
                    anchors.top: parent.bottom
                    anchors.topMargin: 30
                    color: Dex.CurrentTheme.accentColor

                    DefaultText
                    {
                        text: middle_tooltip_text
                        font: Dex.DexTypo.caption
                        leftPadding: 10
                        rightPadding: 10
                        topPadding: 6
                        bottomPadding: 6
                    }
                }

                background: Rectangle {
                    width: 0
                    height: 0
                    color: "transparent"
                }
            }

            DefaultMouseArea
            {
                id: _middle_btn_mousearea
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    Item
    {
        id: _right_btn
        width: btn_width
        height: parent.height

        DefaultRectangle
        {
            id: _right_rect
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: Dex.CurrentTheme.tradeMarketModeSelectorNotSelectedBackgroundColor
        }

        DefaultText
        {
            id: _right_label
            anchors.centerIn: parent
            font.pixelSize: pixel_size
            color: Dex.CurrentTheme.foregroundColor2
            text: "+1%"
        }

        DexTooltip
        {
            id: _right_tooltip
            visible: _right_btn_mousearea.containsMouse && right_tooltip_text != ""


            contentItem: FloatingBackground
            {
                anchors.top: parent.bottom
                anchors.topMargin: 30
                color: Dex.CurrentTheme.accentColor

                DefaultText
                {
                    text: right_tooltip_text
                    font: Dex.DexTypo.caption
                    leftPadding: 10
                    rightPadding: 10
                    topPadding: 6
                    bottomPadding: 6
                }
            }

            background: Rectangle {
                width: 0
                height: 0
                color: "transparent"
            }
        }

        DefaultMouseArea
        {
            id: _right_btn_mousearea
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    Item { Layout.fillWidth: true }

    DefaultText
    {
        id: _fiat_label
        font.pixelSize: pixel_size
        color: Dex.CurrentTheme.foregroundColor2
        DefaultInfoTrigger { triggerModal: cex_info_modal }
    }
}