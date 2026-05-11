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
                children: [],
                nodeId: Math.random()
            };
        }
    }

    // 供外部(Main)绑定的信号，请求弹出添加对话框
    signal requestAddNode(var parentNode)

    function showContextMenu(node) {
        console.log("showContextMenu called with node:", node.nodeName);
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
            // 使用 nodeId 来比较节点，而不是直接比较对象引用
            if (root.children[i].nodeId === target.nodeId) {
                return root;
            }
            var found = findParent(root.children[i], target);
            if (found) return found;
        }
        return null;
    }

    function findIndex(parent, target) {
        if (!parent || !parent.children) return -1;
        for (var i = 0; i < parent.children.length; i++) {
            // 使用 nodeId 来比较节点，而不是直接比较对象引用
            if (parent.children[i].nodeId === target.nodeId) {
                return i;
            }
        }
        return -1;
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
                    confirmDeleteDialog.targetNode = contextMenu.targetNode;
                    confirmDeleteDialog.open();
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
            enabled: contextMenu.targetNode && clipboardData !== null
            onClicked: {
                if (clipboardData && contextMenu.targetNode) {
                    function deepCopy(n) {
                        return {
                            nodeName: n.nodeName,
                            type: n.type,
                            expanded: false,
                            children: n.children.map(function(c) { return deepCopy(c); }),
                            nodeId: Math.random()
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
        title: "提示"
        width: 300
        height: 150
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        anchors.centerIn: Overlay.overlay

        contentItem: Item {
            anchors.fill: parent
            Text {
                text: "确认删除该节点吗？"
                anchors.centerIn: parent
                font.pixelSize: 14
            }
        }

        onAccepted: {
            console.log("Delete accepted, targetNode:", confirmDeleteDialog.targetNode);
            
            if (confirmDeleteDialog.targetNode) {
                var parent = findParent(treeData, confirmDeleteDialog.targetNode);
                console.log("Found parent:", parent);
                
                if (parent) {
                    var idx = findIndex(parent, confirmDeleteDialog.targetNode);
                    console.log("Node index:", idx);
                    
                    if (idx !== -1) {
                        parent.children.splice(idx, 1);
                        console.log("Node removed from parent");
                        
                        // 强制刷新，使 Repeater 更新
                        dataRevision++;
                        
                        if (selectedNode === confirmDeleteDialog.targetNode) {
                            selectedNode = parent;
                            if (onNodeSelected) onNodeSelected(parent);
                        }
                        if (onNodeDeleted) onNodeDeleted(confirmDeleteDialog.targetNode);
                        console.log("Node deleted successfully");
                    } else {
                        console.log("Error: Node index is -1");
                    }
                } else {
                    console.log("Error: parent is null");
                }
            }
        }

        onRejected: {
            console.log("Delete operation cancelled");
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
