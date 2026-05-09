import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 1400
    height: 800
    title: "TM-你的自动化测试帮手"

    property var selectedNode: null

    property var treeData: ({
        nodeName: "root",
        type: "root",
        expanded: true,
        children: []
    })

    RowLayout {
        anchors.fill: parent

        // 左侧树结构
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: "#f0f0f0"

            TreeComponent {
                id: treeComponent
                anchors.fill: parent
                treeData: treeData
                selectedNode: selectedNode
                onNodeSelected: function(node) {
                    selectedNode = node;
                }
                onNodeAdded: function(parentNode, newNode) {
                    console.log("添加节点:", newNode.nodeName);
                }
                onNodeDeleted: function(node) {
                    console.log("删除节点:", node.nodeName);
                }
                onNodeCopied: function(node) {
                    console.log("复制节点:", node.nodeName);
                }
                onRequestAddNode: function(parentNode) {
                    addNodeOverlay.targetNode = parentNode;
                    inputField.text = "";
                    addNodeOverlay.visible = true;
                    inputField.forceActiveFocus();
                }
            }
        }

        // 右侧编辑区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"

            NodeEditor {
                anchors.fill: parent
                node: selectedNode
                onDataModified: treeComponent.dataRevision++
            }
        }
    }

    // 添加节点弹窗（放在顶层窗口中，避免被裁剪）
    Rectangle {
        id: addNodeOverlay
        anchors.fill: parent
        color: "#80000000"
        visible: false
        z: 1000

        property var targetNode: null

        MouseArea {
            anchors.fill: parent
            onClicked: addNodeOverlay.visible = false
        }

        Rectangle {
            width: 280
            height: 140
            anchors.centerIn: parent
            color: "white"
            radius: 8

            MouseArea {
                anchors.fill: parent
                onClicked: mouse.accepted = true
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10

                Label {
                    text: "节点名称:"
                    font.pixelSize: 14
                }
                TextField {
                    id: inputField
                    Layout.fillWidth: true
                    placeholderText: "请输入节点名称"
                    focus: true
                    onAccepted: confirmAdd()
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 10
                    Button {
                        text: "确定"
                        onClicked: confirmAdd()
                    }
                    Button {
                        text: "取消"
                        onClicked: {
                            inputField.text = "";
                            addNodeOverlay.visible = false;
                        }
                    }
                }
            }
        }
    }

    function confirmAdd() {
        if (inputField.text.trim() !== "" && addNodeOverlay.targetNode) {
            addNodeOverlay.targetNode.children.push({
                nodeName: inputField.text.trim(),
                type: "folder",
                expanded: false,
                children: [],
                nodeId: Math.random()
            });
            addNodeOverlay.targetNode.expanded = true;
            treeComponent.dataRevision++;
            if (treeComponent.onNodeAdded) {
                treeComponent.onNodeAdded(addNodeOverlay.targetNode,
                    addNodeOverlay.targetNode.children[addNodeOverlay.targetNode.children.length - 1]);
            }
        }
        inputField.text = "";
        addNodeOverlay.visible = false;
    }

    Component.onCompleted: {
        selectedNode = treeData;
        console.log("Main.qml: selectedNode set to treeData:", treeData);
        console.log("Main.qml: treeData.nodeName:", treeData.nodeName);
    }
}
