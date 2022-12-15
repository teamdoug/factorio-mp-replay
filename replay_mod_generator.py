import csv
import shutil
import filter_replay
import copy

def copy_event(event, x, y):
    ev = copy.deepcopy(event)
    ev['position']['x'] = x
    ev['position']['y'] = y
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

    # This underground is later reversed by dragging belt, but there's no events for that...
    # Prevent initial accidental rotation
    if event_type == 'on_player_rotated_entity' and event['name'] == "underground-belt" and tick == 96057:
        return []
    # Don't build/deconstruct bad miner.
    if x == 62.5 and y == 52.5:
        return []
        
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
    with open(r'C:/Program Files/Factorio/mods/mp-replay/player_events.lua', 'w') as f:
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
    shutil.copy(r'C:/Program Files/Factorio/mods/mp-replay/player_events.lua', 'mp-replay/player_events.lua')
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