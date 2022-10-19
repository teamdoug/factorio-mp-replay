import json

def parse_line(line):
    return parse_table_helper(line, 0)[0]

def parse_table_helper(line, start):
    i = start
    in_key = True
    in_value = False
    in_str = False
    cur_key = ''
    cur_val = ''
    result = {}
    if line[i] != '{':
        raise ValueError("Table doesn't start with '{'")
    i += 1
    while i < len(line):
        c = line[i]
        if c == ' ':
            if in_str:
                raise ValueError("Unexpected space")
            if in_key:
                in_key = False
                if line[i:i+3] != ' = ':
                    raise ValueError('Expected " = " after key')
                in_value = True
                cur_val = ''
                i += 3
                continue
            else:
                raise ValueError("Unexpected space")

        if c == ',':
            if in_str or not in_value:
                raise ValueError("Unexpected comma")
            if '.' in cur_val:
                result[cur_key] = float(cur_val)
            else:
                result[cur_key] = int(cur_val)
            cur_key = ''
            cur_val = ''
            in_key = True
            in_value = False
            if line[i+1] != ' ':
                raise ValueError("Expected space after comma")
            i += 2
            continue
        if c == '"':
            if in_str:
                in_str = False
                result[cur_key] = cur_val
                cur_key = ''
                cur_val = ''
                in_key = True
                in_value = False
                if line[i+1] == '}':
                    return result, i+2
                if line[i+1:i+3] != ', ':
                    raise ValueError("Expected comma+space after end quote")
                i += 3
                continue
            else:
                if not in_value or cur_val:
                    raise ValueError("Unexpected quote")
                in_str = True
                i += 1
                continue
        if c == "{":
            if in_str or not in_value or cur_val:
                raise ValueError("Unexpected {")
            val, index = parse_table_helper(line, i)
            result[cur_key] = val
            cur_key = ''
            cur_val = ''
            in_key = True
            in_value = False
            i = index
            if line[i] == '}':
                return result, i+1
            elif line[i:i+2] == ', ':
                i += 2
            else:
                raise ValueError("Expected ', ' or '}' after nested table")
            continue
        if c == "}":
            if in_str or not in_value or not cur_val:
                raise ValueError("Unexpected }")
            if '.' in cur_val:
                result[cur_key] = float(cur_val)
            else:
                result[cur_key] = int(cur_val)
            return result, i+1
        if in_key:
            cur_key += c
            i += 1
            continue
        if in_value:
            cur_val += c
            i += 1
            continue
        raise ValueError('i am lost')
    raise ValueError('unexpected end of line')
            

    



def main():
    with open('replay.log') as f:
        text = f.read()
    with open('filtered_replay.log', 'w') as f:
        for line in text.splitlines():
            if 'rlog: {' not in line:
                continue
            line = line[line.index('rlog: ') + 6:]
            parsed = parse_line(line)
            if not parsed.get('position'):
                continue
            x = parsed['position']['x']
            y = parsed['position']['y']
            if parsed['tick'] >= 167032 and parsed['player_index'] == 7:
                if parsed["event_type"] != 'on_player_changed_position':
                    f.write(line + '\n')
            
            if abs(x) > 420 or abs(y) > 355:
                print(x, y)
            continue
            if parsed["event_type"] == 'on_player_changed_position':
                continue
            #if parsed['event_type'] != 'player_dropped':
                #continue
            if parsed.get('player_index') != 6:
                continue
            f.write(line)
            f.write('\n')

if __name__ == '__main__':
    main()