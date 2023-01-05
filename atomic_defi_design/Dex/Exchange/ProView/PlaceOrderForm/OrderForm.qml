import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.0

import "../../../Components"
import "../../../Constants"
import App 1.0
import Dex.Themes 1.0 as Dex

ColumnLayout
{
    id: root
    spacing: 8

    function focusVolumeField()
    {
        input_volume.forceActiveFocus()
    }

    readonly property double cex_price: General.formatDouble(API.app.trading_pg.cex_price)
    readonly property string total_amount: API.app.trading_pg.total_amount
    readonly property int input_height: 70
    readonly property int subfield_margin: 5


    // Will move to backend: Minimum Fee
    function getMaxBalance()
    {
        if (General.isFilled(base_ticker))
            return API.app.get_balance(base_ticker)
        return "0"
    }

    // Will move to backend: Minimum Fee
    function getMaxVolume()
    {
        // base in this orderbook is always the left side, so when it's buy, we want the right side balance (rel in the backend)
        const value = sell_mode ? API.app.trading_pg.orderbook.base_max_taker_vol.decimal :
            API.app.trading_pg.orderbook.rel_max_taker_vol.decimal

        if (General.isFilled(value))
            return value

        return getMaxBalance()
    }

    Connections
    {
        target: exchange_trade
        function onBackend_priceChanged() { input_price.text = exchange_trade.backend_price; }
        function onBackend_volumeChanged() { input_volume.text = exchange_trade.backend_volume; }
    }

    Connections {
        target: API.app.trading_pg

        function onMarketModeChanged() {
            General.setPrice(String(General.formatDouble(cex_price, 8)))
        }

        function onPriceChanged() {
            price_usd_value.left_rect.color = input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            price_usd_value.middle_rect.color = input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            price_usd_value.right_rect.color = input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            volume_usd_value.left_rect.color = input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            volume_usd_value.right_rect.color = input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled

            volume_usd_value.left_label = General.getVolumeShortcutLabel(0.25) ? qsTr("Min") : "25%"
            volume_usd_value.left_tooltip_text = input_price.text == "0" ? qsTr("Enter price first") : General.getVolumeShortcutLabel(0.25) ? qsTr("Use minimum order volume") : qsTr("Swap 25% of your tradable balance.")
            volume_usd_value.middle_label = General.getVolumeShortcutLabel(0.5) ? qsTr("Min") : "50%"
            volume_usd_value.middle_tooltip_text = input_price.text == "0" ? qsTr("Enter price first") : General.getVolumeShortcutLabel(0.5) ? qsTr("Use minimum order volume") : qsTr("Swap 50% of your tradable balance.")
            volume_usd_value.right_tooltip_text = input_price.text == "0" ? qsTr("Enter price first") : qsTr("Swap 100% of your tradable balance.")
            price_usd_value.left_tooltip_text = input_price.text == "0" ? qsTr("Enter price first") : qsTr("Reduce 1% relative to CEX market price.")
            price_usd_value.right_tooltip_text = input_price.text == "0" ? qsTr("Enter price first") : qsTr("Increase 1% relative to CEX market price.")
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_price

            left_text: qsTr("Price")
            right_text: right_ticker
            enabled: !(API.app.trading_pg.preferred_order.price !== undefined)
            color: enabled ? Dex.CurrentTheme.foregroundColor : Dex.CurrentTheme.foregroundColor2
            text: backend_price ? backend_price : cex_price
            width: parent.width
            height: 41
            radius: 18

            onTextChanged:
            {
                General.setPrice(text)
            }
            Component.onCompleted: text = cex_price ? cex_price : 1
        }

        OrderFormSubfield
        {
            id: price_usd_value
            anchors.top: input_price.bottom
            anchors.left: input_price.left
            anchors.topMargin: subfield_margin
            visible: !API.app.trading_pg.invalid_cex_price
            fiat_value: General.getFiatText(non_null_price, right_ticker)

            left_label: "-1%"
            left_tooltip_text: input_price.text == "0" ? qsTr("Enter price first") : qsTr("Reduce 1% relative to CEX market price.")
            left_btn_mousearea.onClicked:
            {
                if (input_price.text != "0")
                {
                    let price = General.formatDouble(parseFloat(input_price.text) - (cex_price * 0.01))
                    if (price < 0) price = 0
                    General.setPrice(String(price))
                }
            }

            middle_label: "0%"
            middle_tooltip_text: qsTr("Use CEX market price.")
            middle_btn_mousearea.onClicked:
            {
                    General.setPrice(String(cex_price))
            }

            right_label: "+1%"
            right_tooltip_text: input_price.text == "0" ? qsTr("Enter price first") : qsTr("Increase 1% relative to CEX market price.")
            right_btn_mousearea.onClicked:
            {
                if (input_price.text != "0")
                {
                    let price = General.formatDouble(parseFloat(input_price.text) + (cex_price * 0.01))
                    General.setPrice(String(price))
                }
            }
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_volume
            width: parent.width
            height: 41
            radius: 18
            left_text: qsTr("Volume")
            right_text: left_ticker
            placeholderText: sell_mode ? qsTr("Amount to sell") : qsTr("Amount to receive")
            text: API.app.trading_pg.volume
            onTextChanged: General.setVolume(input_volume.text)
        }

        OrderFormSubfield
        {
            id: volume_usd_value
            anchors.top: input_volume.bottom
            anchors.left: input_volume.left
            anchors.topMargin: subfield_margin
            left_btn_mousearea.onClicked:
            {
                if (input_price.text != "0")
                {
                    let volume = General.formatDouble(API.app.trading_pg.max_volume) * 0.25
                    General.setVolume(volume)
                }
            }
            middle_btn_mousearea.onClicked:
            {
                if (input_price.text != "0")
                {
                    let volume = middle_label == qsTr("Min") ? API.app.trading_pg.min_trade_vol : General.formatDouble(API.app.trading_pg.max_volume) * 0.5
                    General.setVolume(volume)
                }
            }
            right_btn_mousearea.onClicked:
            {
                if (input_price.text != "0")
                {
                    let volume = General.formatDouble(API.app.trading_pg.max_volume)
                    General.setVolume(volume)
                }
            }

            fiat_value: General.getFiatText(non_null_volume, left_ticker)
            left_label: qsTr("25%")
            middle_label: General.getVolumeShortcutLabel(0.5) ? qsTr("Min") : qsTr("50%")
            right_label:  qsTr("Max")
            left_rect.color: input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            middle_rect.color: input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            right_rect.color: input_price.text == "0" ? Dex.CurrentTheme.buttonColorDisabled : Dex.CurrentTheme.buttonColorEnabled
            left_tooltip_text: input_price.text == "0" ? "Enter price first" : qsTr("Swap 25% of your tradable balance.")
            middle_tooltip_text: input_price.text == "0" ? "Enter price first" : General.getVolumeShortcutLabel(0.5) ? qsTr("Use minimum order volume") : qsTr("Swap 50% of your tradable balance.")
            right_tooltip_text:  input_price.text == "0" ? "Enter price first" : qsTr("Swap 100% of your tradable balance.")
        }
    }

    Item
    {
        visible: _useCustomMinTradeAmountCheckbox.checked
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: input_height

        AmountField
        {
            id: input_minvolume
            width: parent.width
            height: 41
            radius: 18
            left_text: qsTr("Min Volume")
            right_text: left_ticker
            placeholderText: sell_mode ? qsTr("Min amount to sell") : qsTr("Min amount to receive")
            text: API.app.trading_pg.min_trade_vol
            onTextChanged: if (API.app.trading_pg.min_trade_vol != text) General.setMinimumAmount(text)
        }

        OrderFormSubfield
        {
            id: minvolume_usd_value
            anchors.top: input_minvolume.bottom
            anchors.left: input_minvolume.left
            anchors.topMargin: subfield_margin
            left_btn_mousearea.onClicked:
            {
                let volume = input_volume.text * 0.10
                General.setMinimumAmount(General.formatDouble(volume))
            }
            middle_btn_mousearea.onClicked:
            {
                let volume = input_volume.text * 0.25
                General.setMinimumAmount(General.formatDouble(volume))
            }
            right_btn_mousearea.onClicked:
            {
                let volume = input_volume.text * 0.50
                General.setMinimumAmount(General.formatDouble(volume))
            }
            fiat_value: General.getFiatText(API.app.trading_pg.min_trade_vol, left_ticker)
            left_label: "10%"
            middle_label: "25%"
            right_label: "50%"
            left_tooltip_text:  qsTr("Minimum accepted trade equals 10% of order volume.")
            middle_tooltip_text:  qsTr("Minimum accepted trade equals 25% of order volume.")
            right_tooltip_text:  qsTr("Minimum accepted trade equals 50% of order volume.")
        }
    }

    Item
    {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 30
        visible: !_useCustomMinTradeAmountCheckbox.checked

        DefaultText
        {
            id: minVolLabel
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 13
            text: qsTr("Min volume: ") + API.app.trading_pg.min_trade_vol
        }
    }

    RowLayout
    {
        Layout.rightMargin: 2
        Layout.leftMargin: 2
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 30
        spacing: 5

        DefaultCheckBox
        {
            id: _useCustomMinTradeAmountCheckbox
            boxWidth: 20
            boxHeight: 20
            labelWidth: 0
            onToggled: General.setMinimumAmount(0)
        }

        DefaultText
        {
            Layout.fillWidth: true
            height: _useCustomMinTradeAmountCheckbox.height
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            wrapMode: Label.WordWrap
            text: qsTr("Use custom minimum trade amount")
            color: Dex.CurrentTheme.foregroundColor3
            font.pixelSize: 13
        }
    }
}