import QtQuick 2.15
import QtQuick.Controls 2.15

Column {
    id: treeNode
    width: parent ? parent.width : 0

    property var node: null
    property int depth: 0
    property var treeComp: null

    // 节点行
    Row {
        id: nodeRow
        width: parent.width
        height: 30
        spacing: 0

        // 缩进
        Item {
            width: depth * 20
            height: 1
        }

        // 展开/收缩箭头
        Text {
            width: 20
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (!treeComp || !node) return "";
                treeComp.dataRevision;
                return (node.children && node.children.length > 0)
                    ? (node.expanded ? "▾" : "▸") : "";
            }
            font.pixelSize: 14
            color: "gray"

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!node) return;
                    node.expanded = !node.expanded;
                    treeComp.dataRevision++;
                }
            }
        }

        // 节点标签
        Rectangle {
            width: parent.width - depth * 20 - 20
            height: parent.height
            color: treeComp.selectedNode?.nodeId === node.nodeId ? "#0078d7" : "transparent"
            radius: 3

            Text {
                anchors.fill: parent
                anchors.leftMargin: 6
                verticalAlignment: Text.AlignVCenter
                text: {
                    if (!treeComp || !node) return "";
                    treeComp.dataRevision;
                    return node.nodeName || node.title || "";
                }
                color: treeComp.selectedNode?.nodeId === node.nodeId ? "white" : "black"
                font.pixelSize: 13
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (!node) return;
                    treeComp.selectedNode = node;
                    if (treeComp.onNodeSelected) {
                        treeComp.onNodeSelected(node);
                    }
                    if (mouse.button === Qt.RightButton) {
                        treeComp.showContextMenu(node);
                    }
                }
                onDoubleClicked: {
                    if (!node) return;
                    if (node.children && node.children.length > 0) {
                        node.expanded = !node.expanded;
                        treeComp.dataRevision++;
                    }
                }
            }
        }
    }

    // 子节点（使用Loader避免直接递归实例化）
    Column {
        width: parent.width
        visible: {
            if (!treeComp || !node) return false;
            treeComp.dataRevision;
            return node.expanded;
        }

        Repeater {
            id: childRepeater
            model: {
                if (!treeComp || !node) return [];
                treeComp.dataRevision;
                return node.children ? node.children.slice() : [];
            }

            delegate: Loader {
                width: treeNode.width
                source: "TreeNode.qml"

                property var itemNode: modelData
                property int itemDepth: treeNode.depth + 1
                property var itemTreeComp: treeNode.treeComp

                onLoaded: {
                    if (item) {
                        item.node = itemNode;
                        item.depth = itemDepth;
                        item.treeComp = itemTreeComp;
                    }
                }
                onItemNodeChanged: if (item) item.node = itemNode
                onItemDepthChanged: if (item) item.depth = itemDepth
                onItemTreeCompChanged: if (item) item.treeComp = itemTreeComp
            }
        }
    }
}