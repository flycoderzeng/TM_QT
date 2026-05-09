import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: treeComponent
    anchors.fill: parent

    property var treeData: null
    property var selectedNode: null
    property int dataRevision: 0

    property var onNodeSelected: null
    property var onNodeAdded: null
    property var onNodeDeleted: null
    property var onNodeCopied: null

    property var clipboardData: null

    // Initialize with default root node if not set from outside
    Component.onCompleted: {
        if (!treeData) {
            console.log("TreeComponent: Initializing default treeData");
            treeData = {
                nodeName: "root",
                type: "root",
                expanded: true,
                children: []
            };
        }
    }

    // 供外部(Main)绑定的信号，请求弹出添加对话框
    signal requestAddNode(var parentNode)

    function showContextMenu(node) {
        console.log("showContextMenu called with node:", node);
        if (!node) {
            console.log("Warning: showContextMenu called with null node");
            // 尝试从treeData获取根节点
            if (treeData) {
                console.log("Using treeData as fallback:", treeData);
                contextMenu.targetNode = treeData;
            } else {
                console.log("Error: No fallback node available");
                return;
            }
        } else {
            contextMenu.targetNode = node;
        }
        contextMenu.popup();
    }

    function findParent(root, target) {
        if (!root || !root.children) return null;
        for (var i = 0; i < root.children.length; i++) {
            if (root.children[i] === target) return root;
            var found = findParent(root.children[i], target);
            if (found) return found;
        }
        return null;
    }

    // 右键菜单
    Menu {
        id: contextMenu
        property var targetNode: null

        MenuItem {
            text: "添加子节点"
            onClicked: {
                console.log("Adding node, targetNode:", contextMenu.targetNode);
                if (contextMenu.targetNode) {
                    requestAddNode(contextMenu.targetNode);
                } else {
                    console.log("Error: targetNode is null when adding node");
                }
            }
        }
        MenuItem {
            text: "删除节点"
            enabled: contextMenu.targetNode && contextMenu.targetNode !== treeData
            onClicked: {
                if (contextMenu.targetNode && contextMenu.targetNode !== treeData) {
                    var parent = findParent(treeData, contextMenu.targetNode);
                    if (parent) {
                        var idx = parent.children.indexOf(contextMenu.targetNode);
                        if (idx !== -1) {
                            parent.children.splice(idx, 1);
                            if (selectedNode === contextMenu.targetNode) {
                                selectedNode = parent;
                                if (onNodeSelected) onNodeSelected(parent);
                            }
                            dataRevision++;
                            if (onNodeDeleted) onNodeDeleted(contextMenu.targetNode);
                        }
                    }
                }
            }
        }
        MenuItem {
            text: "复制节点"
            enabled: contextMenu.targetNode && contextMenu.targetNode !== treeData
            onClicked: {
                if (contextMenu.targetNode) {
                    clipboardData = contextMenu.targetNode;
                    if (onNodeCopied) onNodeCopied(contextMenu.targetNode);
                }
            }
        }
        MenuItem {
            text: "粘贴节点"
            enabled: contextMenu.targetNode && contextMenu.targetNode !== treeData && clipboardData !== null
            onClicked: {
                if (clipboardData && contextMenu.targetNode) {
                    function deepCopy(n) {
                        return {
                            nodeName: n.nodeName,
                            type: n.type,
                            expanded: false,
                            children: n.children.map(function(c) { return deepCopy(c); })
                        };
                    }
                    var newNode = deepCopy(clipboardData);
                    newNode.nodeName = clipboardData.nodeName + " (副本)";
                    contextMenu.targetNode.children.push(newNode);
                    contextMenu.targetNode.expanded = true;
                    dataRevision++;
                    if (onNodeAdded) onNodeAdded(contextMenu.targetNode, newNode);
                }
            }
        }
    }

    // 树视图
    ScrollView {
        anchors.fill: parent
        clip: true

        Column {
            id: treeColumn
            width: parent.width

            TreeNode {
                node: treeData
                depth: 0
                treeComp: treeComponent
                onNodeChanged: {
                    console.log("TreeComponent: TreeNode node changed to:", node);
                }
            }
        }
    }

    // 删除确认对话框
    Dialog {
        id: confirmDeleteDialog
        property var targetNode: null
        title: "确认删除"
        width: 300
        height: 120
        modal: true
        standardButtons: Dialog.Yes | Dialog.No

        contentItem: Item {
            anchors.fill: parent
            Text {
                text: "确认删除该节点吗？"
                anchors.centerIn: parent
                font.pixelSize: 14
            }
        }

        onAccepted: {
            if (confirmDeleteDialog.targetNode) {
                var parent = findParent(treeData, confirmDeleteDialog.targetNode);
                if (parent) {
                    var idx = parent.children.indexOf(confirmDeleteDialog.targetNode);
                    if (idx !== -1) {
                        parent.children.splice(idx, 1);
                        if (selectedNode === confirmDeleteDialog.targetNode) {
                            selectedNode = parent;
                            if (onNodeSelected) onNodeSelected(parent);
                        }
                        dataRevision++;
                        if (onNodeDeleted) onNodeDeleted(confirmDeleteDialog.targetNode);
                    }
                }
            }
        }
    }

    // Debug: Additional logging for node deletion
    function debugDeleteNode(node) {
        console.log("DEBUG: deleteNode called with node:", node);
        console.log("DEBUG: treeData:", treeData);
        if (node) {
            console.log("DEBUG: node has children:", node.children);
            if (node.children) {
                console.log("DEBUG: node children count:", node.children.length);
            }
        }
    }
}
