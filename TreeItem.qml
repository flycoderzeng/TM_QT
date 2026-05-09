import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: treeItem
    width: parent.width
    height: 30

    property var node: null
    property var onNodeSelected: null
    property var onNodeAdded: null
    property var onNodeDeleted: null
    property var onNodeCopied: null
    property var model: null
    property var selectedNode: null

    // 显示节点内容
    ItemDelegate {
        id: itemDelegate
        width: parent.width
        text: node.nodeName
        highlighted: treeItem.selectedNode === node
        onClicked: {
            selectedNode = node;
            if (onNodeSelected) {
                onNodeSelected(node);
            }
        }
        // 右键菜单
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                if (mouse.button === Qt.RightButton) {
                    selectedNode = node;
                    if (onNodeSelected) {
                        onNodeSelected(node);
                    }
                }
            }
        }
    }
}