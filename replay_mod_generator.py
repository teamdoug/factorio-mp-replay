import json

def main():
    with open('replay.log') as f:
        text = f.read()
    with open(r'C:/Program Files/Factorio/mods/mp-replay/player_events.lua', 'w') as f:
        f.write('return {')
        first = True
        for line in text.splitlines():
            if ': rlog: {' not in line and not line.startswith('rlog: {'):
                continue
            if first:
                first = False
            else:
                f.write(',\n')
            line = line[line.index('rlog: ') + 6:]
            f.write(line)
        f.write('}')

if __name__ == '__main__':
    main()