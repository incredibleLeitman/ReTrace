tool
extends Node


#
# Notifies a specific group of the existence of a node which can be assigned to this one.
# The nodes in the group are notified via the function "set_groupname_node", e.g. "set_notifier_node",
#  which has the Node as an argument.
#


export(String) var group_name: String
export(NodePath) var node_to_send: NodePath


func _ready():
	var function_name = "set_%s_node" % [group_name.to_lower()]
	
	print("Calling %s" % [function_name])
	get_tree().call_group(group_name, function_name, get_node(node_to_send))


# Display a warning in the editor if the group or node is invalid
func _get_configuration_warning():
	if !get_tree().has_group(group_name):
		return "Group does not exist!"
	
	if !node_to_send:
		return "A node to send needs to be assigned!"
	
	return ""
