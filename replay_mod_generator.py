
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
    raise ValueError(str(obj))

def fix_event(event):
    if 'position' not in event:
        return [event]
    player_index = event['player_index']
    event_type = event['event_type']
    tick = event['tick']
    x, y = event['position']['x'], event['position']['y']
    if player_index == 3 and 147881 <= tick <= 148453:
        return []
    if event_type == 'on_built_entity':
        if event['name'] == 'electric-mining-drill':
            if y == -13.5:
                if 26.5 <= x <= 59.5:
                    event['position']['x'] += 1
                    return [event]
                if x == 59.5:
                    return []
        elif event['name'] == 'small-electric-pole':
            if x == 38.5 and y == -11.5:
                event['position']['x'] -= 2
            if x == 62.5 and y == -11.5:
                event['position']['x'] -= 1
            if x == 63.5 and y == -15.5:
                return []
            if x == 271.5 and y == -47.5:
                event['position']['x'] -= 2
                event['position']['y'] -= 3
            if x == 113.5 and y == 47.5:
                event['position']['x'] = 109.5
                return [event, copy_event(event, 116.5, 47.5)]
        elif event['name'] == 'transport-belt':
            if tick > 183000 and 264.5 <= x <= 271.5 and -49.5 <= y <= -45.5:
                return []
            if x == 62.5 and y == -15.5 and event['direction'] == 6:
                return []
            if x == 269.5 and y == -47.5:
                event['position']['x'] = 271.5
                event['position']['y'] = -47.5
                return [event]
            if x == 249.5 and y in (-34.5, -7.5, -.5):
                return []
            if (x == 247.5 and y == 1.5):
                event['position']['x'] -= 1
                return [event]
            if (x == 267.5 and y == -51.5):
                return []
           # if (x == 246.5 and y == 1.5):
                #event['direction'] = 0
            if (x == 247.5 and y == -.5):
                event['direction'] = 2
            if x == 295.5 and y == 14.5:
                return [event, copy_event(event, 294.5, 14.5)]
            if player_index == 8 and tick < 75000:
                if x == 63.5 and y == -17.5:
                    event['position']['y'] += 6
                    event['direction'] = 0
                if x == 64.5 and y == -17.5:
                    event['position']['x'] -= 1
                    event['position']['y'] += 5
                    event['direction'] = 0
                if x == 64.5 and y == -16.5:
                    event['position']['x'] -= 1
                    event['position']['y'] += 3
                    event['direction'] = 0
                if x == 64.5 and y == -15.5:
                    event['position']['x'] -= 1
                    event['position']['y'] += 1
                    event['direction'] = 2
        elif event['name'] == 'underground-belt':
            if x == 63.5 and y in (-11.5, -16.5):
                return []
        elif event['name'] == 'pipe-to-ground':
            if (x in (258.5, 259.5) and y == -53.5) or (x == 272.5 and y == -55.5):
                return []
            if x in (265.5, 266.5) and y == -53.5:
                event['position']['x'] -= 2
                return [event]
            if x == 273.5 and y == -55.5:
                event['position']['x'] -= 1
        elif event['name'] == 'splitter':
            if x == 248 and y in (-1.5, .5):
                event['position']['x'] -= 1
        elif event['name'] == 'pipe':
            if x == 272.5 and y == -55.5:
                return []
    elif event_type == 'on_player_mined_entity':
        if event['name'] == 'transport-belt' and tick > 183000 and 264.5 <= x <= 271.5 and -49.5 <= y <= -45.5:
            return []
        if x == 62.5 and y == -15.5:
            return []
        if x == 64.5 and y == -15.5:
            return []
        if x == 269.5 and y == -46.5:
            return []
        if (x == 273.5 and y == -55.5) or (x == 272.5 and y == -55.5):
            return []
    elif event_type == 'set_splitter':
        if x == 248 and y in (-1.5, .5):
            event['position']['x'] -= 1

    if player_index == 7:
        if x == 246.5 and y == 17.5:
            return []
        if x == 247.5 and 1.5 <= y <= 17.5:
            event['position']['x'] -= 1

    if 266.5 <= x <= 270.5 and -50.5 <= y <= -47.5:
        event['position']['y'] -= 1
    elif 265.5 <= x <= 266.5 and y == -46.5:
        event['position']['x'] -= 1
        event['position']['y'] -= 1
    elif 267.5 <= x <= 272.5 and -46.5 <= y <= -40.5:
        event['position']['x'] -= 1
        event['position']['y'] -= 1
    elif 259.5 <= x <= 263.5 and -55.5 <= y <= -48.5:
        event['position']['x'] -= 1
    elif 259.5 <= x <= 269.5 and y == -47.5:
        event['position']['x'] -= 1
    elif 259.5 <= x <= 275.5 and -46.5 <= y <= -41.5:
        event['position']['x'] -= 1
    elif 249.5 <= x <= 281.5 and -40.5 <= y <= 0.5:
        event['position']['x'] -= 1
    elif 249.5 <= x <= 294.5 and 1.5 <= y <= 11.5:
        event['position']['x'] -= 1
    elif 256.5 <= x <= 294.5 and 12.5 <= y <= 15.5:
        event['position']['x'] -= 1
    elif x == 256.5 and y == 16.5:
        event['position']['x'] -= 1
    # My fix is so fucked lol.
    if event_type == 'on_built_entity' and event['name'] == 'transport-belt':
        x, y = event['position']['x'], event['position']['y']
        if x == 256.5 and y == 16.5:
            return []
        if x == 255.5 and y == 16.5:
            event['direction'] = 4
        if x == 271.5 and y == -39.5 and event['direction'] == 4:
            return [event, copy_event(event, 271.5, -40.5)]
        if x == 268.5 and y == -47.5:
            event['position']['x'] -= 1
            event['position']['y'] -= 1
        # Some of these are created while an assembler is in the way, so the next block fixes...
        if 266.5 <= x <= 268.5 and y == -48.5:
            event['position']['y'] += 1
            if x == 266.5:
                return [event, copy_event(event, 265.5, -47.5), copy_event(event, 264.5, -47.5)]
        if x == 269.5 and y== -47.5:
            return [event, copy_event(event, 268.5, -47.5), copy_event(event, 267.5, -47.5)]
        if x == 264.5 and y == -47.5:
            event['position']['y'] += 1
    if event_type == 'on_player_mined_entity' and event['name'] == 'transport-belt':
        x, y = event['position']['x'], event['position']['y']
        if x in (267.5, 268.5) and y == -47.5:
            return []
        if x == 255.5 and y == 16.5:
            return []
    return [event]

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
            if 'on_player_changed_position' in line:
                if first:
                    first = False
                else:
                    f.write(',\n')
                f.write(line)
                continue
            event = filter_replay.parse_line(line)
            events = fix_event(event)
            for event in events:
                if first:
                    first = False
                else:
                    f.write(',\n')
                f.write(unparse(event))
        f.write('}')

if __name__ == '__main__':
    main()