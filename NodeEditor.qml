import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// 树节点编辑组件
Item {
    id: nodeEditor
    width: parent.width
    height: parent.height

    property var node: null
    signal dataModified()

    StackLayout {
        anchors.fill: parent
        anchors.margins: 10
        ColumnLayout {
            // 节点信息标题
            Text {
                text: node ? node.nodeName : "请选择节点"
                font.pixelSize: 20
                font.bold: true

                // ✅ 固定高度，不被拉伸
                Layout.preferredHeight: 20
                Layout.fillWidth: true

                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // 编辑表单
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                // 节点名称
                Text {
                    text: "名称:"
                    Layout.alignment: Qt.AlignRight
                }
                TextField {
                    id: nameField
                    text: node ? node.nodeName : ""
                    Layout.fillWidth: true
                    onTextChanged: {
                        if (node && text !== node.nodeName) {
                            node.nodeName = text;
                            nodeEditor.dataModified();
                        }
                    }
                }

                // 操作按钮
                Button {
                    text: "保存"
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        if (node) {
                            console.log("保存节点信息:", node.nodeName);
                        }
                    }
                }
            }
        }
    }
}