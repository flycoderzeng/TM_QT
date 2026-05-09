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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        // 节点信息标题
        Text {
            text: node ? node.nodeName : "请选择节点"
            font.pixelSize: 20
            font.bold: true
            Layout.fillWidth: true
        }

        // 编辑表单
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            Layout.fillHeight: true

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

            // 节点类型
            Text {
                text: "类型:"
                Layout.alignment: Qt.AlignRight
            }
            TextField {
                id: typeField
                text: node ? node.type : ""
                Layout.fillWidth: true
                onTextChanged: {
                    if (node && text !== node.type) {
                        node.type = text;
                        nodeEditor.dataModified();
                    }
                }
            }

            // 节点描述
            Text {
                text: "描述:"
                Layout.alignment: Qt.AlignRight
            }
            TextArea {
                id: descriptionField
                text: node ? (node.description || "") : ""
                Layout.fillWidth: true
                Layout.fillHeight: true
                onTextChanged: {
                    if (node && text !== (node.description || "")) {
                        node.description = text;
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
