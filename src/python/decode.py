import mido

MEM_FILE = "./src/music.mem"
mid = mido.MidiFile("./src/python/mid/我和我的祖国.mid", clip=True)
select_track = 1

ticks_per_beat = 0
us_per_beat = 0

class Msg():
    def __init__(self, type, beat, note, velocity):
        self.type = type
        self.beat = beat
        self.note = note
        self.velocity = velocity

def getTime():
    global ticks_per_beat, us_per_beat
    ticks_per_beat = mid.ticks_per_beat
    for msg in mid.tracks[0]:
        if msg.type == "set_tempo":
            us_per_beat = msg.tempo
            break

def tick0s2ms(ticks):
    global ticks_per_beat, us_per_beat
    return int(round(ticks / ticks_per_beat * us_per_beat / 1000))

def ticks2beat(ticks):
    global ticks_per_beat, us_per_beat
    return ticks / ticks_per_beat


getTime()

music = []
for i, msg in enumerate(mid.tracks[select_track]):
    if msg.type == "note_on" and msg.velocity != 0:
        music.append(Msg(1, ticks2beat(msg.time), msg.note, msg.velocity))
    elif msg.type == "note_off" or (msg.type == "note_on" and msg.velocity == 0):
        music.append(Msg(0, ticks2beat(msg.time), msg.note, msg.velocity))
music[0].beat = 0


with open(MEM_FILE, "w") as f:
    for msg in music:
        beatx64 = min(round(msg.beat * 64), 255)
        note = (msg.note + 128) if msg.type else msg.note
        f.write("%02X%02X\n" % (beatx64, note))

print("MUSIC_LEN: %d" % len(music))
print("MS_PER_BEATX64: %d" % round(us_per_beat / 64 / 1000))