import os
import csv
import shutil
import filter_replay
import copy

def copy_event(event, x, y, player_index=None):
    ev = copy.deepcopy(event)
    ev['position']['x'] = x
    ev['position']['y'] = y
    if player_index is not None:
        ev['player_index'] = player_index
    return ev

def unparse(obj):
    if isinstance(obj, dict):
        return '{' +  ', '.join(f'{k} = {unparse(v)}' for k, v in obj.items()) + '}'
    elif isinstance(obj, str):
        return f'"{obj}"'
    elif isinstance(obj, (int, float)):
        return str(obj)
    elif obj is True:
        return 'true'
    elif obj is False:
        return 'false'
    raise ValueError(str(obj))

def fix_event(event):
    if 'position' not in event:
        return [event]


    player_index = event['player_index']
    event_type = event['event_type']
    tick = event['tick']
    x, y = event['position']['x'], event['position']['y']
    
    '''
    if event_type != 'on_player_changed_position':
        if x >= 73 and x <= 89 and y >= 1 and y <= 11:
            event['position']['x'] += 1
    if x == 73.5 and y == -4.5 and event_type == 'on_player_mined_entity':
        return []
    if x in (73.5, 79.5) and y == -3.5 and player_index == 6 and event_type != 'on_built_entity':
        return []
    if x == 73.5 and tick in (18064, 19396):
        event['position']['x'] = 79.5
    if event_type in ('on_built_entity', 'on_player_mined_entity'):
        if x == 73.5 and y == -4.5:
            event['position']['y'] += 1
        if player_index == 8 and x >= 186.5 and x <= 210.5 and y >= 291.5 and y <= 311.5:
            event['position']['x'] -= 1
        if player_index == 8 and x >= 203.5 and x <= 204.5 and y >= 283.5 and y <= 289.5:
            event['position']['x'] -= 1
        if x == 215.5 and y in (299.5, 300.5, 301.5, 294.5, 295.5, 296.5):
            return [event, copy_event(event, x-4, y)]
        if x == 189.5 and y == 310.5:
            return []
        if x == 190.5 and y == 310.5:
            event['position']['x'] -= 1
        if x == 189.5 and y == 311.5:
            return []
        if x == 190.5 and y == 311.5:
            event['position']['x'] -= 1
        if player_index == 7 and x == 200.5 and y == 311.5:
            return []

    if event_type == 'on_built_entity':
        name = event['name']
        if x == 202.5 and y == -96.5 and name == 'entity-ghost':
            return []
        if x == 230.5 and y == 349.5:
            return [event, copy_event(event, x, y, player_index=8)]
        if x == 268.5 and y == 131.5:
            event['belt_to_ground_type'] = "output"
            event['direction'] = 6
        if x == 270.5 and y == 131.5:
            event['belt_to_ground_type'] = "input"
            event['direction'] = 6
        if x == 192.5 and y == 359.5:
            event['belt_to_ground_type'] = "output"
            event['direction'] = 6
        if x == 197.5 and y == 359.5:
            event['belt_to_ground_type'] = "input"
            event['direction'] = 6

    if event_type == 'on_marked_for_deconstruction':
        if x == 163.5 and y == 257.5:
            return []
        if x == 198 and y == 356:
            return []

    return [event]
    '''
    '''
    if (x == 280 and (y == 232.5 or y == 235.5)) and event_type == 'set_splitter':
        event['splitter_output_priority'] = 'right'
        event['splitter_input_priority'] = 'right'
        return [event]
    if event_type == 'on_built_entity':
        name = event['name']
        if x == 280.5 and y == 236.5:
            event['direction'] = 4
            return [event]
        if x >= 154.5 and x <= 158.5 and y >= 264.5 and y <= 321.5:
            return []
        if x >= 160.5 and x <= 162.5 and y >= 265.5 and y <= 320.5 and name not in ('pipe-to-ground', 'pipe'):
            return []
        if x >= 154.5 and x <= 163.5 and y >= 322.5 and y <= 324.5:
            return []
        if x >= 158.5 and x <= 168.5 and y >= 325.5 and y <= 352.5 and y != 349.5:
            return []
        if x >= 117.5 and x <= 123.5 and y >= 327.5 and y <= 332.5:
            return []
        if x == 201.5 and y in (365.5, 368.5):
            return []
        if x in (205.5, 208.5) and y == 368.5:
            return []
        if x == 201.5 and y == -96.5 and name == 'entity-ghost':
            return []
    if event_type == 'on_marked_for_deconstruction':
        if x >= 230.5 and x <= 237.5 and y >= 318.5 and y <= 323.5:
            return []
        '''

    '''
    # This underground is later reversed by dragging belt, but there's no events for that...
    # Prevent initial accidental rotation
    if event_type == 'on_player_rotated_entity' and event['name'] == "underground-belt" and tick == 148729:
        return []
    
    if event_type == 'set_recipe' and x == 317.5 and y == 292.5 and event['recipe'] == "copper-cable":
        event['recipe'] = 'electronic-circuit'
        return [event]
    
    if event_type == 'player_took' and tick in (4999, 5030, 5061, ):
        return []
    
    if event_type == 'on_built_entity':
        if x == 348.5 and y == 179.5:
            return [event, copy_event(event, 348.5, 182.5), copy_event(event, 348.5, 188.5)]
        if x == 92.5 and y == 170.5:
            return [copy_event(event, x, 171.5)]
        if x == 115.5 and y == 165.5:
            return [event, copy_event(event, 114.5, 165.5)]
        if x == 346.5 and y == 232.5:
            return [copy_event(event, 345.5, y)]
        if x == 331.5 and y == 232.5:
            return [copy_event(event, 330.5, y)]
        if x == 279.5 and y == 241.5:
            return [event, copy_event(event, 280.5, 241.5)]
        if x == 307.5 and y == 274.5:
            return [event, copy_event(event, 306.5, 274.5)]
        if x == 300.5 and y == 261.5:
            return [event, copy_event(event, 301.5, 261.5)]
        if x == 299.5 and y == 299.5:
            return [event, copy_event(event, 300.5, 299.5)]
        if x == 306.5 and y == 290.5:
            return [copy_event(event, 307.5, 290.5)]
        if x == 307.5 and y == 290.5:
            return [copy_event(event, 306.5, 290.5)]
        if player_index == 6 and ((x == 108.5 and y == 139.5) or (x in (107.5, 108.5) and y == 140.5)):
            event['direction'] = 4
            return [event, copy_event(event, x, y, player_index=4)]
        if player_index == 6 and x in (108.5, 109.5, 110.5) and y == 139.5:
            return []
        if player_index == 6 and x in (107.5, 108.5, 109.5) and y == 140.5:
            return []
        if player_index == 4 and x in (107.5, 108.5) and y >= 139.5 and y <= 148.5:
            return [event, copy_event(event, x, y, player_index=6)]
        if player_index == 6 and x == 42.5 and y >= 135.5 and y <= 139.5:
            return [event, copy_event(event, x, y, player_index=4)]
        if (x == 145.5 and y == 133):
            return [event, {'event_type': "set_splitter", 'name': "splitter", 'player_index': 4, 'position': {'x': x, 'y': y}, 'splitter_input_priority': "left", 'splitter_output_priority': "left", 'tick': tick, 'type': "splitter"}]
        if x == 329.5 and y == 229.5:
            event['direction'] = 2
            return [event]
        #if x == 49.5 and y == -30:
        #    return [event, {'count': 19, 'entity_name': "boiler", 'event_type': "player_dropped", 'item_name': "coal", 'player_index': 6, 'position': {'x': 49.5, 'y': -30}, 'tick': event['tick']},]

    if event_type == 'on_player_rotated_entity':
        if player_index == 4 and x in (107.5, 108.5) and y in (139.5, 140.5):
            return []

    # This underground is later reversed by dragging belt, but there's no events for that...
    # Prevent initial accidental rotation
    if event_type == 'on_player_rotated_entity' and event['name'] == "underground-belt" and tick == 96057:
        return []
    # Don't build/deconstruct bad miner.
    if x == 62.5 and y == 52.5:
        return []
        '''
        
    '''
    # iron line from heartosis to typical_guy
    if player_index == 7 and tick >= 167032:
        if event_type != 'on_player_changed_position':
            if x >= 232.5 and y <= -40.5:
                event['player_index'] = 5
                return [event]

    # prevent building bad belt since we can't pick up the steel that ended up here
    if x == 265.5 and y == -34.5 and tick in (154439,172338):
        return []
    if event_type == 'player_dropped':
        if event['item_name'] == 'productivity-module':
            # Copy modules from blue to green circuits
            if y in (76.5, 44.5) and x >= 317.5 and x <= 359.5:
                if y == 76.5:
                    y = 70.5
                else:
                    y = 50.5
                return [event, copy_event(event, x, y)]
    if event_type == 'on_built_entity':
        # prevent red circuits going the wrong way
        if x == 313.5 and y == 48.5:
            event['direction'] = 2
            return [event]
        # prevent building pipe that connects fluid systems since flushing isn't implemented
        if x == 156.5 and y == 153.5:
            return []
        # add 4 missing miners and power poles
        if x == 132.5 and y == 97.5:
            ce = copy_event(event, 133.5, 101.5)
            ce['direction'] = 0
            pe = copy_event(event, 144.5, 100.5)
            pe['direction'] = 0
            pe['name'] = 'small-electric-pole'
            pe['type'] = 'electric-pole'
            return[event, ce, copy_event(ce, 136.5, 101.5), copy_event(ce, 139.5, 101.5), copy_event(ce, 142.5, 101.5),
            pe, copy_event(pe, 139.5, 103.5), copy_event(pe, 133.5, 103.5)]
        # missing belt in miners for top steel
        if x == 228.5 and y == -111.5:
            return [event, copy_event(event, 228.5, -110.5)]
        # powerlane inserters
        if x == 110.5 and y in (36.5, 37.5, 38.5):
            ce = copy_event(event, x-2, y)
            ce['direction'] = 6
            return [event, ce]
    # Add more iron to chest for sticks
    if x == 252.5 and y == -5.5 and tick == 145103:
        event['count'] = 2000
    # Accidentally dropping steel plates in rail chests
    if x in (281.5, 285.5) and y == 6.5 and event_type == 'player_dropped' and event['item_name'] == 'steel-plate':
        return []
    '''
    return [event]

craft_queues = {i+1: [] for i in range(8)}

def main():
    with open('replay.log') as f:
        text = f.read()
    mod_file_path = 'mp-replay/player_events.lua'
    with open(mod_file_path, 'w') as f:
        f.write('return {')
        first = True
        for line in text.splitlines():
            if ': rlog: {' not in line and not line.startswith('rlog: {'):
                continue
            line = line[line.index('rlog: ') + 6:]
            # Don't try to fix player movement events
            if 'on_player_changed_position' in line:
                if first:
                    first = False
                else:
                    f.write(',\n')
                f.write(line)
                continue
            event = filter_replay.parse_line(line)
            if event['event_type'] in ('raw_on_player_cancelled_crafting',):
                continue
            if event['event_type'] in ('on_pre_player_crafted_item', 'on_player_cancelled_crafting'):
                craft_queue = craft_queues[event['player_index']]
                if event['event_type'] == 'on_pre_player_crafted_item':
                    craft_queue.append(event)
                else:
                    product = event['product']
                    delete_index = None
                    for index, item in enumerate(reversed(craft_queue)):
                        if item['product'] == product:
                            if event['cancel_count'] < item['queued_count']:
                                item['queued_count'] -= event['cancel_count']
                            else:
                                delete_index = len(craft_queue) - index - 1
                            break
                    else:
                        raise Exception('bad cancel: ' + str(event))
                    if delete_index is not None:
                        craft_queue.pop(delete_index)
                continue
            events = fix_event(event)
            for event in events:
                if first:
                    first = False
                else:
                    f.write(',\n')
                f.write(unparse(event))
        f.write('}')
    
    path = r'C:/Users/Doug/AppData/Roaming/Factorio/mods/mp-replay/player_events.lua'
    if os.path.exists(path):
        shutil.copy(mod_file_path, path)
    
    # Crafting queue generation disabled for now.
    return
    for player_index, craft_queue in craft_queues.items():
        squashed_queue = []
        for index, item in enumerate(craft_queue):
            if index == 0:
                squashed_queue.append(item)
                continue
            # Squash two crafts of the same thing within 10 seconds of each other. Sure.
            if item['product'] == squashed_queue[-1]['product'] and item['tick'] < squashed_queue[-1]['tick'] + 600:
                squashed_queue[-1]['queued_count'] += item['queued_count']
            else:
                squashed_queue.append(item)
        with open(f'queue_{player_index}.csv', 'w') as f:
            csvwriter = csv.DictWriter(f, fieldnames=['timestamp', 'quantity', 'image', 'name'], lineterminator='\n')
            csvwriter.writeheader()
            for item in squashed_queue:
                quantity = f'{item["queued_count"]}'
                if item['amount'] > 1:
                    quantity += f'x{item["amount"]}'
                fname = item['product'][0].upper() + item['product'][1:].replace('-', '_')
                fname = fname.replace('Long_handed', 'Long-handed')
                image = f'=image("https://wiki.factorio.com/images/thumb/{fname}.png/24px-{fname}.png")'
                csvwriter.writerow({'timestamp': f'{item["tick"]//3600:02d}:{(item["tick"]//60)%60:02d}', 'quantity': quantity, 'image': image, 'name': fname.replace('_', ' ')})


if __name__ == '__main__':
    main()