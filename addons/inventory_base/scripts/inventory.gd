#@tool
class_name Inventory
extends Resource
## A [Resource] to store an [Array] of [InventorySlotData].
##
## [b]Inventory[/b] is intended to store and manipulate an [Array] of [InventorySlotData] with each element representing a seperate slot.

## [Array] of [InventorySlotData], each element representing a seperate slot. An empty slot is represented as a [code]null[/code].
@export var items: Array[InventorySlotData] = []:
	set(value):
		#print("inventory: set_inventory")
		items = value
		#for item: InventorySlotData in items:
			#if item != null:
				#if not item.changed.is_connected(emit_changed):
					#item.changed.connect(emit_changed)
		#changed.emit()

## Adds [param slot_data] to [member items]. First attempts to add [param slot_data] to [member items] elements that hold the same [InventoryItem] as itself
## without exceeding that elements [member InventoryItem.max_stack]. If [param slot_data] is not fully consumed by this process [param slot_data]
## is added to the first empty element until [param slot_data] is fully consumed or the last element of [member items] is reached. Returns the remaining [InventoryItem]
## and amount represented as a [InventorySlotData] or [code]null[/code] if [param slot_data] was completely added.
func add_item(slot_data: InventorySlotData) -> InventorySlotData:
	for index in items.size():
		if slot_data == null:
			return null
		if items[index] == null:
			continue
		if items[index].item == slot_data.item:
			if items[index].amount < items[index].item.max_stack:
				var total_amount = items[index].amount + slot_data.amount
				if total_amount <= items[index].item.max_stack:
					items[index].amount = total_amount
					return null
				else:
					items[index].amount = items[index].item.max_stack
					slot_data.amount = total_amount - items[index].amount
	var empty_index = find_first_empty_slot()
	while empty_index != -1:
		if slot_data.amount <= slot_data.item.max_stack:
			items[empty_index] = slot_data
			return null
		else:
			var new_slot_data = InventorySlotData.new()
			new_slot_data.item = slot_data.item
			new_slot_data.amount = slot_data.item.max_stack
			items[empty_index] = new_slot_data
			slot_data.amount -= new_slot_data.amount
		empty_index = find_first_empty_slot()
	return slot_data

## Returns the index of the first empty slot in [member items] or [code]-1[/code] if all slots are full.
func find_first_empty_slot() -> int:
	for index in items.size():
		if items[index] == null:
			return index
	return -1

## Combines all elements of [member items] matching the one found at [member items][[param index]] until the end of items
## is reached or max stack is exceeded. These combined elements are then stored at [member items][[param index]].
func combine_slot(index: int):
	if items[index] == null:
		return
	else:
		var slot_data: InventorySlotData = items[index]
		items[index] = null
		for i in items.size():
			if slot_data.amount == slot_data.item.max_stack:
				break
			if items[i] != null:
				if items[i].item == slot_data.item:
					var total_amount = items[i].amount + slot_data.amount
					if total_amount <= slot_data.item.max_stack:
						slot_data.amount = total_amount
						items[i] = null
					else:
						slot_data.amount = slot_data.item.max_stack
						items[i].amount = total_amount - slot_data.amount
		items[index] = slot_data
